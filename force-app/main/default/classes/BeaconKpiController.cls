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

    @AuraEnabled
    public static void triageOne(String ref) {
        try { triageByRef(ref); } catch (BeaconException e) { throw aura(e.getMessage()); }
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
        Finding__c f = findFinding(ref);
        BeaconTriageAction.Request q = new BeaconTriageAction.Request();
        q.findingId = f.Id;
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
