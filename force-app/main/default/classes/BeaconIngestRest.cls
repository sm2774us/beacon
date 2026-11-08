/**
 * Headless ingest endpoint: POST /services/apexrest/beacon/v1/findings
 * Body: JSON array of {id, src, sev, asset, control, title, detail}. Idempotent upsert on External_Id__c.
 * Invalid records are returned with a reason code (quarantine semantics), never silently dropped.
 */
@RestResource(urlMapping='/beacon/v1/findings/*')
global with sharing class BeaconIngestRest {
    static final Map<String, String> SEVMAP = new Map<String, String>{
        'low' => 'Low', 'sev1' => 'Low', 'medium' => 'Medium', 'sev2' => 'Medium', 'high' => 'High', 'sev3' => 'High',
        'crit' => 'Critical', 'critical' => 'Critical', 'sev4' => 'Critical'
    };
    global class Evt { global String id; global String src; global String sev; global String asset; global String control; global String title; global String detail; }
    global class Outcome { global Integer received; global Integer upserted; global List<String> quarantined = new List<String>(); }

    @HttpPost
    global static Outcome ingest() {
        List<Evt> events = (List<Evt>) JSON.deserialize(RestContext.request.requestBody.toString(), List<Evt>.class);
        Outcome o = new Outcome();
        o.received = events.size();
        Map<String, Id> assets = new Map<String, Id>();
        for (Asset__c a : [SELECT Id, Name FROM Asset__c WITH USER_MODE]) { assets.put(a.Name, a.Id); }
        Map<String, Id> controls = new Map<String, Id>();
        for (Control__c c : [SELECT Id, Control_Code__c FROM Control__c WITH USER_MODE]) { controls.put(c.Control_Code__c, c.Id); }
        Map<String, Finding__c> byExt = new Map<String, Finding__c>();
        for (Evt e : events) {
            if (String.isBlank(e.id) || String.isBlank(e.title)) { o.quarantined.add('missing_required_field'); continue; }
            String sev = SEVMAP.get(String.valueOf(e.sev).toLowerCase());
            if (sev == null) { o.quarantined.add(e.id + ':invalid_severity'); continue; }
            if (byExt.containsKey(e.id)) { o.quarantined.add(e.id + ':duplicate'); continue; }
            byExt.put(e.id, new Finding__c(External_Id__c = e.id, Title__c = e.title, Description__c = e.detail, Severity__c = sev,
                Source__c = e.src, Asset__c = assets.get(e.asset), Control__c = controls.get(e.control), Status__c = 'New'));
        }
        upsert as user byExt.values() Finding__c.External_Id__c;
        o.upserted = byExt.size();
        return o;
    }
}
