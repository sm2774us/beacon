/**
 * Headless ingest endpoint: POST /services/apexrest/beacon/v1/findings  (body: JSON array of events).
 * Same semantics as local/lib/pipeline.js: validate, normalise, dedupe, quarantine with reason codes.
 * Idempotent upsert on External_Id__c; re-ingest never resets the status of an already-triaged finding.
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
        String body = RestContext.request.requestBody.toString();
        Object parsed = JSON.deserializeUntyped(body);
        List<Object> items = parsed instanceof List<Object> ? (List<Object>) parsed : new List<Object>{ parsed };
        List<String> lines = new List<String>();
        for (Object o : items) { lines.add(JSON.serialize(o)); }
        return processLines(lines);
    }

    global static Outcome processLines(List<String> lines) {
        Outcome o = new Outcome();
        o.received = lines.size();
        Map<String, Id> assets = new Map<String, Id>();
        for (Asset__c a : [SELECT Id, Name FROM Asset__c WITH USER_MODE]) { assets.put(a.Name, a.Id); }
        Map<String, Id> controls = new Map<String, Id>();
        for (Control__c c : [SELECT Id, Control_Code__c FROM Control__c WITH USER_MODE]) { controls.put(c.Control_Code__c, c.Id); }

        Map<String, Evt> accepted = new Map<String, Evt>();
        Map<String, Integer> reasons = new Map<String, Integer>();
        List<Map<String, String>> detail = new List<Map<String, String>>();
        Map<String, String> sevByExt = new Map<String, String>();
        for (String line : lines) {
            Evt e = null;
            String reason = null;
            try { e = (Evt) JSON.deserialize(line, Evt.class); } catch (Exception ex) { reason = 'malformed_json'; }
            if (reason == null && (e == null || String.isBlank(e.id) || String.isBlank(e.title))) { reason = 'missing_required_field'; }
            String sev = null;
            if (reason == null) {
                sev = e.sev == null ? null : SEVMAP.get(e.sev.toLowerCase());
                if (sev == null) { reason = 'invalid_severity'; }
            }
            if (reason == null && accepted.containsKey(e.id)) { reason = 'duplicate'; }
            if (reason != null) {
                o.quarantined.add((e == null || e.id == null) ? reason : e.id + ':' + reason);
                reasons.put(reason, (reasons.containsKey(reason) ? reasons.get(reason) : 0) + 1);
                Map<String, String> d = new Map<String, String>();
                d.put('reason', reason);
                d.put('line', line.length() > 80 ? line.substring(0, 80) : line);
                detail.add(d);
                continue;
            }
            accepted.put(e.id, e);
            sevByExt.put(e.id, sev);
        }
        Set<String> existing = new Set<String>();
        for (Finding__c x : [SELECT External_Id__c FROM Finding__c WHERE External_Id__c IN :accepted.keySet() WITH USER_MODE]) { existing.add(x.External_Id__c); }
        List<Finding__c> recs = new List<Finding__c>();
        for (String k : accepted.keySet()) {
            Evt e = accepted.get(k);
            Finding__c f = new Finding__c(External_Id__c = e.id, Title__c = e.title, Description__c = e.detail, Severity__c = sevByExt.get(k),
                Source__c = e.src, Asset__c = assets.get(e.asset), Control__c = controls.get(e.control), Asset_Ref__c = e.asset, Control_Ref__c = e.control);
            if (!existing.contains(k)) { f.Status__c = 'New'; }
            recs.add(f);
        }
        upsert as user recs Finding__c.External_Id__c;
        o.upserted = recs.size();
        insert as user new Ingest_Batch__c(Received__c = o.received, Accepted__c = recs.size(), Quarantined__c = o.quarantined.size(),
            Reasons__c = JSON.serialize(reasons), Quarantine_Detail__c = JSON.serialize(detail));
        return o;
    }
}
