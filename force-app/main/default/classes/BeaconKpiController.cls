public with sharing class BeaconKpiController {
    public class BeaconException extends Exception {}

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getKpis() {
        return (Map<String, Object>) BeaconApiRest.state().get('kpis');
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getQueue() {
        return BeaconApiRest.queue();
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCompare() {
        return BeaconApiRest.compare();
    }

    public static Integer triageNew() {
        return triageAll('v2', false);
    }

    /** Runs the agent with the chosen prompt version. includeTriaged=true re-runs everything not yet approved/rejected (switch version with no reset). */
    @AuraEnabled
    public static Integer triageAll(String ver, Boolean includeTriaged) {
        List<BeaconTriageAction.Request> reqs = new List<BeaconTriageAction.Request>();
        List<Finding__c> fs = includeTriaged == true
            ? [SELECT Id FROM Finding__c WHERE Status__c NOT IN ('Approved', 'Rejected') WITH USER_MODE LIMIT 200]
            : [SELECT Id FROM Finding__c WHERE Status__c = 'New' WITH USER_MODE LIMIT 200];
        for (Finding__c f : fs) {
            BeaconTriageAction.Request q = new BeaconTriageAction.Request();
            q.findingId = f.Id;
            q.promptVersion = ver;
            reqs.add(q);
        }
        if (!reqs.isEmpty()) { BeaconTriageAction.triage(reqs); }
        return reqs.size();
    }

    @AuraEnabled
    public static void triageOne(String ref, String ver) {
        try { triageByRef(ref, ver); } catch (BeaconException e) { throw aura(e.getMessage()); }
    }

    @AuraEnabled
    public static void decide(String ref, String decision) {
        try { decideByRef(ref, decision); } catch (BeaconException e) { throw aura(e.getMessage()); }
    }

    @AuraEnabled
    public static void resetDemo() {
        BeaconSeed.reset();
    }

    public static Finding__c findFinding(String ref) {
        List<Finding__c> l = [SELECT Id, Name, External_Id__c, Status__c FROM Finding__c WHERE External_Id__c = :ref OR Name = :ref WITH USER_MODE LIMIT 1];
        if (l.isEmpty()) { throw new BeaconException('No finding matches ' + ref); }
        return l[0];
    }

    public static void triageByRef(String ref) {
        triageByRef(ref, 'v2');
    }

    public static void triageByRef(String ref, String ver) {
        Finding__c f = findFinding(ref);
        BeaconTriageAction.Request q = new BeaconTriageAction.Request();
        q.findingId = f.Id;
        q.promptVersion = ver;
        BeaconTriageAction.triage(new List<BeaconTriageAction.Request>{ q });
    }

    public static void decideByRef(String ref, String decision) {
        if (decision != 'approve' && decision != 'reject') { throw new BeaconException('Decision must be approve or reject'); }
        Finding__c f = findFinding(ref);
        if (f.Status__c != 'Pending Approval') { throw new BeaconException(ref + ' is "' + f.Status__c + '", not Pending Approval.'); }
        Boolean ok = decision == 'approve';
        update as user new Finding__c(Id = f.Id, Status__c = ok ? 'Approved' : 'Rejected', Requires_Approval__c = false);
        List<Agent_Run__c> runs = [SELECT Id FROM Agent_Run__c WHERE Finding__c = :f.Id WITH USER_MODE];
        for (Agent_Run__c a : runs) {
            a.Outcome__c = ok ? 'Approved' : 'Rejected';
            if (!ok) { a.Minutes_Saved__c = 0; }
        }
        update as user runs;
    }

    static AuraHandledException aura(String msg) {
        AuraHandledException e = new AuraHandledException(msg);
        e.setMessage(msg);
        return e;
    }
}
