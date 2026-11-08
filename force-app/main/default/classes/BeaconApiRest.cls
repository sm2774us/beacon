/**
 * Single source of truth for every UI. GET /services/apexrest/beacon/api/state returns the complete picture
 * (findings + latest run + KPIs + pipeline) in the same JSON shape the local web console uses.
 * POST /beacon/api/triage/{id} | /beacon/api/decision/{id}/{approve|reject} | /beacon/api/reset
 * The LWC Control Tower and the local web console (run-demo-salesforce.bat) both read from here, so they can never disagree.
 */
@RestResource(urlMapping='/beacon/api/*')
global with sharing class BeaconApiRest {
    static final Map<String, String> UI = new Map<String, String>{
        'New' => 'New', 'Auto-Closed' => 'AUTO_CLOSED', 'Assigned' => 'ASSIGNED', 'Pending Approval' => 'PENDING_APPROVAL',
        'Blocked' => 'BLOCKED', 'Approved' => 'APPROVED', 'Rejected' => 'REJECTED'
    };

    @HttpGet
    global static void doGet() {
        respond(state());
    }

    @HttpPost
    global static void doPost() {
        String path = RestContext.request.requestURI.substringAfter('/beacon/api/');
        List<String> p = path.split('/');
        String op = p[0];
        try {
            if (op == 'reset') { BeaconSeed.reset(); }
            else if (op == 'triage' && p.size() > 1) { BeaconKpiController.triageByRef(p[1]); }
            else if (op == 'decision' && p.size() > 2) { BeaconKpiController.decideByRef(p[1], p[2]); }
            else {
                RestContext.response.statusCode = 404;
                respond(new Map<String, Object>{ 'error' => 'unknown operation: ' + path });
                return;
            }
        } catch (BeaconKpiController.BeaconException e) {
            RestContext.response.statusCode = 409;
            respond(new Map<String, Object>{ 'error' => e.getMessage() });
            return;
        }
        respond(state());
    }

    static void respond(Object o) {
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(o));
    }

    public static Map<String, Object> state() {
        Map<Id, Asset__c> assets = new Map<Id, Asset__c>([SELECT Id, Tier__c, Contains_PII__c, Internet_Facing__c FROM Asset__c WITH USER_MODE]);
        Map<Id, Control__c> controls = new Map<Id, Control__c>([SELECT Id, Name, Control_Code__c, Framework__c, Criticality__c, Owner_Team__c FROM Control__c WITH USER_MODE]);
        Map<Id, Agent_Run__c> runs = new Map<Id, Agent_Run__c>();
        for (Agent_Run__c ar : [SELECT Finding__c, Minutes_Saved__c FROM Agent_Run__c WITH USER_MODE ORDER BY CreatedDate ASC]) { runs.put(ar.Finding__c, ar); }
        List<Finding__c> fs = [SELECT Id, Name, External_Id__c, Title__c, Description__c, Source__c, Severity__c, Status__c, Asset_Ref__c, Control_Ref__c, Asset__c, Control__c
                               FROM Finding__c WITH USER_MODE ORDER BY External_Id__c ASC];

        List<Map<String, Object>> items = new List<Map<String, Object>>();
        Integer n = 0; Integer auto = 0; Integer asg = 0; Integer pend = 0; Integer blk = 0; Integer appr = 0; Integer rej = 0; Integer guard = 0;
        Decimal mins = 0; Long lat = 0;
        for (Finding__c f : fs) {
            String st = UI.containsKey(f.Status__c) ? UI.get(f.Status__c) : 'New';
            Map<String, Object> m = new Map<String, Object>{
                'id' => f.External_Id__c, 'name' => f.Name, 'source' => f.Source__c, 'severity' => f.Severity__c, 'asset' => f.Asset_Ref__c,
                'control' => f.Control_Ref__c, 'title' => f.Title__c, 'description' => f.Description__c, 'status' => st, 'run' => null
            };
            Agent_Run__c run = runs.get(f.Id);
            if (st != 'New' && run != null) {
                BeaconTriageEngine.Result r = BeaconTriageEngine.triage(f, assets.get(f.Asset__c), controls.get(f.Control__c));
                List<Map<String, Object>> steps = new List<Map<String, Object>>();
                for (BeaconTriageEngine.Step s : r.steps) {
                    steps.add(new Map<String, Object>{ 'tool' => s.tool, 'input' => s.input, 'output' => s.output, 'ms' => s.ms });
                }
                Decimal saved = run.Minutes_Saved__c == null ? 0 : run.Minutes_Saved__c;
                m.put('run', new Map<String, Object>{
                    'findingId' => f.External_Id__c, 'promptVersion' => 'v2', 'category' => r.category, 'score' => r.score, 'band' => r.band,
                    'confidence' => r.confidence.doubleValue(), 'status' => st, 'guardrails' => r.guardrails, 'recommendation' => r.recommendation,
                    'steps' => steps, 'latencyMs' => r.latencyMs, 'tokens' => r.tokens, 'minutesSaved' => saved.doubleValue(), 'owner' => r.owner
                });
                n++; mins += saved; lat += r.latencyMs; guard += r.guardrails.size();
                if (st == 'AUTO_CLOSED') { auto++; }
                else if (st == 'ASSIGNED') { asg++; }
                else if (st == 'PENDING_APPROVAL') { pend++; }
                else if (st == 'BLOCKED') { blk++; }
                else if (st == 'APPROVED') { appr++; }
                else if (st == 'REJECTED') { rej++; }
            }
            items.add(m);
        }
        Integer decided = appr + rej;
        Double avgMin = 0;
        if (n > 0) { avgMin = (mins / n).setScale(1, RoundingMode.HALF_UP).doubleValue(); }
        Map<String, Object> kpis = new Map<String, Object>{
            'processed' => n, 'total' => fs.size(), 'autoClosed' => auto, 'assigned' => asg, 'pending' => pend, 'blocked' => blk,
            'approved' => appr, 'rejected' => rej, 'guardrailsFired' => guard,
            'avgLatencyMs' => n > 0 ? Math.roundToLong(lat * 1.0 / n).intValue() : 0,
            'hoursSaved' => (mins / 60).setScale(2, RoundingMode.HALF_UP).doubleValue(),
            'avgMinutesSaved' => avgMin,
            'manualMinutes' => 18,
            'dollarsSaved' => Math.roundToLong((mins / 60 * 85).doubleValue()).intValue(),
            'overrideRate' => decided > 0 ? Math.roundToLong(rej * 100.0 / decided).intValue() : 0,
            'humanInLoopRate' => n > 0 ? Math.roundToLong((pend + decided) * 100.0 / n).intValue() : 0
        };
        Map<String, Object> pipe = new Map<String, Object>{ 'received' => 0, 'accepted' => 0, 'quarantined' => 0, 'acceptRate' => 0, 'reasons' => new Map<String, Object>() };
        List<Object> quarantine = new List<Object>();
        List<Ingest_Batch__c> bs = [SELECT Received__c, Accepted__c, Quarantined__c, Reasons__c, Quarantine_Detail__c FROM Ingest_Batch__c WITH USER_MODE ORDER BY CreatedDate DESC LIMIT 1];
        if (!bs.isEmpty()) {
            Ingest_Batch__c b = bs[0];
            pipe.put('received', b.Received__c.intValue());
            pipe.put('accepted', b.Accepted__c.intValue());
            pipe.put('quarantined', b.Quarantined__c.intValue());
            if (b.Received__c > 0) { pipe.put('acceptRate', (b.Accepted__c * 100 / b.Received__c).setScale(1, RoundingMode.HALF_UP).doubleValue()); }
            if (b.Reasons__c != null) { pipe.put('reasons', JSON.deserializeUntyped(b.Reasons__c)); }
            if (b.Quarantine_Detail__c != null) { quarantine = (List<Object>) JSON.deserializeUntyped(b.Quarantine_Detail__c); }
        }
        return new Map<String, Object>{ 'findings' => items, 'kpis' => kpis, 'pipeline' => pipe, 'quarantine' => quarantine, 'source' => 'salesforce' };
    }

    /** Rows for the LWC data table. */
    public static List<Map<String, Object>> queue() {
        List<Map<String, Object>> rows = new List<Map<String, Object>>();
        for (Map<String, Object> f : (List<Map<String, Object>>) state().get('findings')) {
            Map<String, Object> run = (Map<String, Object>) f.get('run');
            String st = (String) f.get('status');
            rows.add(new Map<String, Object>{
                'id' => f.get('id'), 'name' => f.get('name'), 'title' => f.get('title'), 'severity' => f.get('severity'), 'status' => st,
                'category' => run == null ? (Object) '' : run.get('category'), 'score' => run == null ? (Object) null : run.get('score'),
                'recommendation' => run == null ? (Object) '' : run.get('recommendation'),
                'notRunnable' => st != 'New', 'notPending' => st != 'PENDING_APPROVAL'
            });
        }
        return rows;
    }

    /** One finding (by event id or record name) including its run trace, or null. */
    public static Map<String, Object> findingView(String ref) {
        for (Map<String, Object> f : (List<Map<String, Object>>) state().get('findings')) {
            if (ref == (String) f.get('id') || ref == (String) f.get('name')) { return f; }
        }
        return null;
    }
}
