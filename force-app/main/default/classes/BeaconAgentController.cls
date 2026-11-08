/**
 * In-org "agent" for orgs WITHOUT Agentforce (free Developer Edition, basic Trailhead Playground).
 * Same pattern as an Agentforce topic: parse intent -> call the SAME action (BeaconTriageAction) -> show tool trace.
 * No LLM, no licence, no callouts. Swap-in path: Agentforce topic calling BeaconTriageAction directly.
 */
public with sharing class BeaconAgentController {
    public class Reply {
        @AuraEnabled public String text;
        @AuraEnabled public List<String> steps = new List<String>();
        @AuraEnabled public String status;
    }
    static final Pattern ID_PAT = Pattern.compile('(?i)\\b(F-\\d{5}|E-\\d{4})\\b');
    static final String HELP = 'Try: "triage E-1002", "why is E-1010 blocked", "approve E-1002", "reject E-1008", "triage all new", "status".';

    @AuraEnabled
    public static Reply ask(String message) {
        Reply r = new Reply();
        String msg = message == null ? '' : message;
        String m = msg.toLowerCase();
        Matcher mt = ID_PAT.matcher(msg);
        String ref = mt.find() ? mt.group(1).toUpperCase() : null;

        if (ref == null) {
            if (m.contains('triage all') || m.contains('run all') || m.contains('all new')) {
                Integer n = BeaconKpiController.triageNew();
                r.text = 'Triaged ' + n + ' new finding(s). Critical and low-confidence items are waiting for human approval.';
                r.status = 'Done';
            } else if (m.contains('status') || m.contains('kpi') || m.contains('summary')) {
                BeaconKpiController.Kpis k = BeaconKpiController.getKpis();
                r.text = k.triaged + '/' + k.total + ' triaged | ' + k.autoClosed + ' auto-closed | ' + k.pending + ' awaiting approval | '
                    + k.blocked + ' blocked | ' + k.hoursSaved.setScale(2) + ' analyst hours saved (~$' + Math.round(k.hoursSaved * 85) + ').';
                r.status = 'Done';
            } else {
                r.text = HELP;
            }
            return r;
        }
        List<Finding__c> found = [SELECT Id, Name, Status__c FROM Finding__c WHERE Name = :ref OR External_Id__c = :ref WITH USER_MODE LIMIT 1];
        if (found.isEmpty()) { r.text = 'No finding matches ' + ref + '. Run scripts/apex/seed.apex first.'; return r; }
        Finding__c f = found[0];

        if (m.contains('approve') || m.contains('reject')) {
            if (f.Status__c != 'Pending Approval') { r.text = ref + ' is "' + f.Status__c + '", not Pending Approval. Nothing to decide.'; r.status = f.Status__c; return r; }
            Boolean ok = m.contains('approve');
            update as user new Finding__c(Id = f.Id, Status__c = ok ? 'Approved' : 'Rejected', Requires_Approval__c = false);
            if (!ok) {
                List<Agent_Run__c> runs = [SELECT Id FROM Agent_Run__c WHERE Finding__c = :f.Id WITH USER_MODE];
                for (Agent_Run__c a : runs) { a.Minutes_Saved__c = 0; a.Outcome__c = 'Rejected'; }
                update as user runs;
            }
            r.text = 'Human decision recorded: ' + ref + ' ' + (ok ? 'APPROVED' : 'REJECTED (counts as an override)') + '.';
            r.status = ok ? 'Approved' : 'Rejected';
            return r;
        }
        Boolean explain = (m.contains('why') || m.contains('explain')) && f.Status__c != 'New';
        String guardrails;
        if (!explain) {
            BeaconTriageAction.Request q = new BeaconTriageAction.Request();
            q.findingId = f.Id;
            guardrails = BeaconTriageAction.triage(new List<BeaconTriageAction.Request>{ q })[0].guardrails;
        } else {
            List<Agent_Run__c> last = [SELECT Guardrails_Triggered__c FROM Agent_Run__c WHERE Finding__c = :f.Id WITH USER_MODE ORDER BY CreatedDate DESC LIMIT 1];
            guardrails = last.isEmpty() ? null : last[0].Guardrails_Triggered__c;
        }
        Finding__c a = [SELECT Name, Status__c, Category__c, Risk_Score__c, Risk_Band__c, Confidence__c, Agent_Recommendation__c,
                               Asset__r.Name, Asset__r.Tier__c, Asset__r.Contains_PII__c, Asset__r.Internet_Facing__c,
                               Control__r.Control_Code__c, Control__r.Name, Control__r.Criticality__c, Control__r.Owner_Team__c
                        FROM Finding__c WHERE Id = :f.Id WITH USER_MODE];
        r.steps.add('get_asset_context -> ' + (a.Asset__r == null ? 'UNKNOWN ASSET' : a.Asset__r.Name + ' tier ' + a.Asset__r.Tier__c
            + ', pii=' + a.Asset__r.Contains_PII__c + ', internet=' + a.Asset__r.Internet_Facing__c));
        r.steps.add('lookup_control -> ' + (a.Control__r == null ? 'UNMAPPED CONTROL' : 'SOC2 ' + a.Control__r.Control_Code__c + ' ' + a.Control__r.Name
            + ' (criticality ' + a.Control__r.Criticality__c + ')'));
        r.steps.add('classify -> ' + a.Category__c);
        r.steps.add('score_risk -> ' + a.Risk_Score__c + ' (' + a.Risk_Band__c + '), confidence ' + a.Confidence__c);
        r.steps.add('policy_guardrail -> ' + (String.isBlank(guardrails) ? 'none fired' : guardrails));
        String owner = a.Control__r == null ? 'GRC Office (unmapped)' : a.Control__r.Owner_Team__c;
        r.text = a.Name + ' => ' + a.Status__c.toUpperCase() + '. ' + a.Agent_Recommendation__c + ' Owner: ' + owner + '.'
            + (a.Status__c == 'Pending Approval' ? ' A human must say "approve ' + ref + '" or "reject ' + ref + '".' : '');
        r.status = a.Status__c;
        return r;
    }
}
