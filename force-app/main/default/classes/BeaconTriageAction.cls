/**
 * Agent action: exposed to Agentforce (Agent Builder > Add Action > Apex) and callable from Flow.
 * Bulk-safe: one SOQL per object, one DML per object, regardless of batch size.
 */
public with sharing class BeaconTriageAction {
    public class Request {
        @InvocableVariable(label='Finding Id' description='Id of the Finding__c record to triage' required=true)
        public Id findingId;
    }
    public class Response {
        @InvocableVariable(label='Status') public String status;
        @InvocableVariable(label='Risk Band') public String band;
        @InvocableVariable(label='Risk Score') public Integer score;
        @InvocableVariable(label='Category') public String category;
        @InvocableVariable(label='Recommendation') public String recommendation;
        @InvocableVariable(label='Guardrails Triggered') public String guardrails;
    }

    @InvocableMethod(label='Triage Security Finding' description='Scores a GRC finding, applies guardrails and routes it (auto-close, assign or human approval).' category='Beacon')
    public static List<Response> triage(List<Request> requests) {
        Set<Id> ids = new Set<Id>();
        for (Request q : requests) { ids.add(q.findingId); }
        Map<Id, Finding__c> findings = new Map<Id, Finding__c>([
            SELECT Id, External_Id__c, Title__c, Description__c, Severity__c, Asset__c, Control__c
            FROM Finding__c WHERE Id IN :ids WITH USER_MODE
        ]);
        Set<Id> assetIds = new Set<Id>();
        Set<Id> controlIds = new Set<Id>();
        for (Finding__c f : findings.values()) { assetIds.add(f.Asset__c); controlIds.add(f.Control__c); }
        Map<Id, Asset__c> assets = new Map<Id, Asset__c>([SELECT Id, Tier__c, Contains_PII__c, Internet_Facing__c FROM Asset__c WHERE Id IN :assetIds WITH USER_MODE]);
        Map<Id, Control__c> controls = new Map<Id, Control__c>([SELECT Id, Criticality__c FROM Control__c WHERE Id IN :controlIds WITH USER_MODE]);

        List<Finding__c> updates = new List<Finding__c>();
        List<Agent_Run__c> runs = new List<Agent_Run__c>();
        Map<Id, Response> out = new Map<Id, Response>();
        for (Finding__c f : findings.values()) {
            BeaconTriageEngine.Result r = BeaconTriageEngine.triage(f, assets.get(f.Asset__c), controls.get(f.Control__c));
            updates.add(new Finding__c(Id = f.Id, Category__c = r.category, Risk_Score__c = r.score, Risk_Band__c = r.band,
                Confidence__c = r.confidence, Status__c = r.status, Agent_Recommendation__c = r.recommendation,
                Requires_Approval__c = r.status == 'Pending Approval'));
            runs.add(new Agent_Run__c(Finding__c = f.Id, Outcome__c = r.status, Latency_Ms__c = r.latencyMs, Tokens__c = r.tokens,
                Minutes_Saved__c = r.minutesSaved, Guardrails_Triggered__c = String.join(r.guardrails, ','), Prompt_Version__c = 'v2'));
            Response resp = new Response();
            resp.status = r.status; resp.band = r.band; resp.score = r.score; resp.category = r.category;
            resp.recommendation = r.recommendation; resp.guardrails = String.join(r.guardrails, ',');
            out.put(f.Id, resp);
        }
        update as user updates;
        insert as user runs;
        List<Response> ordered = new List<Response>();
        for (Request q : requests) { ordered.add(out.get(q.findingId)); }
        return ordered;
    }
}
