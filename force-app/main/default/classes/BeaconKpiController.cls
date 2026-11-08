public with sharing class BeaconKpiController {
    public class Kpis {
        @AuraEnabled public Integer total;
        @AuraEnabled public Integer triaged;
        @AuraEnabled public Integer autoClosed;
        @AuraEnabled public Integer pending;
        @AuraEnabled public Integer blocked;
        @AuraEnabled public Integer guardrails;
        @AuraEnabled public Decimal hoursSaved;
        @AuraEnabled public Decimal avgLatencyMs;
    }

    @AuraEnabled(cacheable=true)
    public static Kpis getKpis() {
        Kpis k = new Kpis();
        k.total = 0; k.triaged = 0; k.autoClosed = 0; k.pending = 0; k.blocked = 0; k.guardrails = 0;
        for (AggregateResult ar : [SELECT Status__c s, COUNT(Id) c FROM Finding__c WITH USER_MODE GROUP BY Status__c]) {
            Integer c = (Integer) ar.get('c');
            String s = (String) ar.get('s');
            k.total += c;
            if (s != 'New') { k.triaged += c; }
            if (s == 'Auto-Closed') { k.autoClosed = c; }
            if (s == 'Pending Approval') { k.pending = c; }
            if (s == 'Blocked') { k.blocked = c; }
        }
        AggregateResult r = [SELECT SUM(Minutes_Saved__c) m, AVG(Latency_Ms__c) l FROM Agent_Run__c WITH USER_MODE];
        k.hoursSaved = r.get('m') == null ? 0 : ((Decimal) r.get('m')) / 60;
        k.avgLatencyMs = r.get('l') == null ? 0 : (Decimal) r.get('l');
        k.guardrails = [SELECT COUNT() FROM Agent_Run__c WHERE Guardrails_Triggered__c != null WITH USER_MODE];
        return k;
    }

    @AuraEnabled(cacheable=true)
    public static List<Finding__c> getQueue() {
        return [SELECT Id, Name, Title__c, Severity__c, Category__c, Risk_Score__c, Status__c, Agent_Recommendation__c
                FROM Finding__c WITH USER_MODE ORDER BY CreatedDate DESC LIMIT 50];
    }

    @AuraEnabled
    public static Integer triageNew() {
        List<BeaconTriageAction.Request> reqs = new List<BeaconTriageAction.Request>();
        for (Finding__c f : [SELECT Id FROM Finding__c WHERE Status__c = 'New' WITH USER_MODE LIMIT 200]) {
            BeaconTriageAction.Request q = new BeaconTriageAction.Request();
            q.findingId = f.Id;
            reqs.add(q);
        }
        if (!reqs.isEmpty()) { BeaconTriageAction.triage(reqs); }
        return reqs.size();
    }
}
