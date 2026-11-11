/**
 * Single source of truth for every UI. GET /services/apexrest/beacon/api/state returns the complete picture
 * (findings + latest run + KPIs + pipeline) in the same JSON shape the local web console uses.
 * POST /beacon/api/triage/{id}[/v1|v2] | /beacon/api/triageall/{v1|v2} | /beacon/api/decision/{id}/{approve|reject} | /beacon/api/reset
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
        if (RestContext.request.requestURI.endsWith('/compare')) { respond(compare()); return; }
        respond(state());
    }

    @HttpPost
    global static void doPost() {
        String path = RestContext.request.requestURI.substringAfter('/beacon/api/');
        List<String> p = path.split('/');
        String op = p[0];
        try {
            if (op == 'reset') { BeaconSeed.reset(); }
            else if (op == 'triage' && p.size() > 1) {
                String ver = p.size() > 2 ? p[2] : RestContext.request.params.get('prompt');
                BeaconKpiController.triageByRef(p[1], ver);
            }
            else if (op == 'triageall') {
                BeaconKpiController.triageAll(p.size() > 1 ? p[1] : 'v2', true);
            }
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
        for (Agent_Run__c ar : [SELECT Finding__c, Minutes_Saved__c, Prompt_Version__c FROM Agent_Run__c WITH USER_MODE ORDER BY CreatedDate ASC]) { runs.put(ar.Finding__c, ar); }
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
                String pv = run.Prompt_Version__c == 'v1' ? 'v1' : 'v2';
                BeaconTriageEngine.Result r = BeaconTriageEngine.triage(f, assets.get(f.Asset__c), controls.get(f.Control__c), pv);
                List<Map<String, Object>> steps = new List<Map<String, Object>>();
                for (BeaconTriageEngine.Step s : r.steps) {
                    steps.add(new Map<String, Object>{ 'tool' => s.tool, 'input' => s.input, 'output' => s.output, 'ms' => s.ms });
                }
                Decimal saved = run.Minutes_Saved__c == null ? 0 : run.Minutes_Saved__c;
                m.put('run', new Map<String, Object>{
                    'findingId' => f.External_Id__c, 'promptVersion' => pv, 'category' => r.category, 'score' => r.score, 'band' => r.band,
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

    class Agg {
        Integer pass = 0; Integer auto = 0; Integer asg = 0; Integer pend = 0; Integer blk = 0; Integer other = 0; Integer n = 0;
        Decimal score = 0; Decimal conf = 0; Decimal mins = 0; Long lat = 0; Long tok = 0;
        void add(BeaconTriageEngine.Result r, Boolean ok) {
            n++; score += r.score; conf += r.confidence; mins += r.minutesSaved; lat += r.latencyMs; tok += r.tokens;
            if (ok) { pass++; }
            if (r.category == 'other') { other++; }
            if (r.status == 'Auto-Closed') { auto++; } else if (r.status == 'Assigned') { asg++; }
            else if (r.status == 'Pending Approval') { pend++; } else if (r.status == 'Blocked') { blk++; }
        }
        Map<String, Object> out(Integer golden) {
            Decimal d = n == 0 ? 1 : Decimal.valueOf(n);
            return new Map<String, Object>{
                'passRate' => golden > 0 ? (Decimal.valueOf(pass) * 100 / golden).setScale(1, RoundingMode.HALF_UP).doubleValue() : 0.0,
                'passed' => pass, 'total' => golden, 'autoClosed' => auto, 'assigned' => asg, 'pending' => pend, 'blocked' => blk,
                'avgScore' => (score / d).setScale(1, RoundingMode.HALF_UP).doubleValue(), 'avgConfidence' => (conf / d).setScale(2, RoundingMode.HALF_UP).doubleValue(),
                'avgLatencyMs' => Math.roundToLong((lat / d).doubleValue()).intValue(), 'avgTokens' => Math.roundToLong((tok / d).doubleValue()).intValue(),
                'avgMinutesSaved' => (mins / d).setScale(1, RoundingMode.HALF_UP).doubleValue(), 'hoursSaved' => (mins / 60).setScale(2, RoundingMode.HALF_UP).doubleValue(),
                'otherBucket' => other
            };
        }
    }

    static Map<String, Object> view(BeaconTriageEngine.Result r, Boolean ok) {
        List<Map<String, Object>> steps = new List<Map<String, Object>>();
        for (BeaconTriageEngine.Step s : r.steps) { steps.add(new Map<String, Object>{ 'tool' => s.tool, 'output' => s.output, 'ms' => s.ms }); }
        return new Map<String, Object>{
            'category' => r.category, 'score' => r.score, 'band' => r.band, 'confidence' => r.confidence.doubleValue(),
            'status' => UI.containsKey(r.status) ? UI.get(r.status) : r.status, 'guardrails' => r.guardrails, 'latencyMs' => r.latencyMs, 'tokens' => r.tokens,
            'minutesSaved' => r.minutesSaved.doubleValue(), 'owner' => r.owner, 'pass' => ok, 'steps' => steps
        };
    }

    /** What-if: triage EVERY finding with BOTH prompt versions in memory (no DML), so the demo never needs a reset. Same JSON shape as GET /api/compare locally. */
    public static Map<String, Object> compare() {
        Map<Id, Asset__c> assets = new Map<Id, Asset__c>([SELECT Id, Tier__c, Contains_PII__c, Internet_Facing__c FROM Asset__c WITH USER_MODE]);
        Map<Id, Control__c> controls = new Map<Id, Control__c>([SELECT Id, Name, Control_Code__c, Framework__c, Criticality__c, Owner_Team__c FROM Control__c WITH USER_MODE]);
        List<Finding__c> fs = [SELECT Id, External_Id__c, Title__c, Description__c, Severity__c, Asset_Ref__c, Control_Ref__c, Asset__c, Control__c
                               FROM Finding__c WITH USER_MODE ORDER BY External_Id__c ASC];
        Agg a1 = new Agg(); Agg a2 = new Agg();
        Integer golden = 0; Integer catChanged = 0; Integer outChanged = 0;
        List<Map<String, Object>> rows = new List<Map<String, Object>>();
        for (Finding__c f : fs) {
            BeaconTriageEngine.Result r1 = BeaconTriageEngine.triage(f, assets.get(f.Asset__c), controls.get(f.Control__c), 'v1');
            BeaconTriageEngine.Result r2 = BeaconTriageEngine.triage(f, assets.get(f.Asset__c), controls.get(f.Control__c), 'v2');
            String exp = BeaconTriageEngine.GOLDEN.get(f.External_Id__c);
            if (exp != null) { golden++; }
            Boolean ok1 = exp != null && r1.category == exp;
            Boolean ok2 = exp != null && r2.category == exp;
            a1.add(r1, ok1); a2.add(r2, ok2);
            Boolean cc = r1.category != r2.category;
            Boolean oc = r1.status != r2.status;
            if (cc) { catChanged++; }
            if (oc) { outChanged++; }
            rows.add(new Map<String, Object>{
                'id' => f.External_Id__c, 'title' => f.Title__c, 'severity' => f.Severity__c, 'description' => f.Description__c, 'expected' => exp,
                'v1' => view(r1, ok1), 'v2' => view(r2, ok2), 'categoryChanged' => cc, 'outcomeChanged' => oc
            });
        }
        return new Map<String, Object>{ 'rows' => rows, 'summary' => new Map<String, Object>{
            'v1' => a1.out(golden), 'v2' => a2.out(golden), 'categoryChanged' => catChanged, 'outcomeChanged' => outChanged, 'total' => fs.size() } };
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
                'promptVersion' => run == null ? (Object) '' : run.get('promptVersion'),
                'notRunnable' => st == 'APPROVED' || st == 'REJECTED', 'notPending' => st != 'PENDING_APPROVAL'
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
