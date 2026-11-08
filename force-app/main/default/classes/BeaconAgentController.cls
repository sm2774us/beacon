/**
 * In-org "agent" for orgs WITHOUT Agentforce (free Developer Edition, basic Trailhead Playground).
 * Same pattern as an Agentforce topic: parse intent -> call the SAME action (BeaconTriageAction) -> show tool trace.
 * No LLM, no licence, no callouts.
 */
public with sharing class BeaconAgentController {
    public class Reply {
        @AuraEnabled public String text;
        @AuraEnabled public List<String> steps = new List<String>();
        @AuraEnabled public String status;
    }
    static final Pattern ID_PAT = Pattern.compile('(?i)\\b(F-\\d{5}|E-\\d{4})\\b');
    static final String HELP = 'Try: "triage E-1002", "why is E-1010 blocked", "approve E-1002", "reject E-1008", "triage all new", "status", "reset".';

    @AuraEnabled
    public static Reply ask(String message) {
        Reply r = new Reply();
        String msg = message == null ? '' : message;
        String m = msg.toLowerCase();
        Matcher mt = ID_PAT.matcher(msg);
        String ref = mt.find() ? mt.group(1).toUpperCase() : null;

        if (ref == null) {
            if (m.contains('reset')) {
                BeaconSeed.reset();
                r.text = 'Demo reset to a clean slate: all findings are New and all telemetry is cleared.';
                r.status = 'Done';
            } else if (m.contains('triage all') || m.contains('run all') || m.contains('all new')) {
                Integer n = BeaconKpiController.triageNew();
                r.text = 'Triaged ' + n + ' new finding(s). Critical and low-confidence items are waiting for human approval.';
                r.status = 'Done';
            } else if (m.contains('status') || m.contains('kpi') || m.contains('summary')) {
                Map<String, Object> k = BeaconKpiController.getKpis();
                r.text = String.valueOf(k.get('processed')) + '/' + String.valueOf(k.get('total')) + ' triaged | ' + String.valueOf(k.get('autoClosed')) + ' auto-closed | '
                    + String.valueOf(k.get('pending')) + ' awaiting approval | ' + String.valueOf(k.get('blocked')) + ' blocked | '
                    + String.valueOf(k.get('hoursSaved')) + ' analyst hours saved (~$' + String.valueOf(k.get('dollarsSaved')) + ').';
                r.status = 'Done';
            } else {
                r.text = HELP;
            }
            return r;
        }
        try {
            if (m.contains('approve') || m.contains('reject')) {
                Boolean ok = m.contains('approve');
                BeaconKpiController.decideByRef(ref, ok ? 'approve' : 'reject');
                r.text = 'Human decision recorded: ' + ref + ' ' + (ok ? 'APPROVED' : 'REJECTED (counts as an override)') + '.';
                r.status = ok ? 'Approved' : 'Rejected';
                return r;
            }
            Map<String, Object> prior = BeaconApiRest.findingView(ref);
            if (prior == null) { r.text = 'No finding matches ' + ref + '. Say "reset" to reload the demo data.'; return r; }
            Boolean explain = (m.contains('why') || m.contains('explain')) && (String) prior.get('status') != 'New';
            if (!explain) { BeaconKpiController.triageByRef(ref); }
            Map<String, Object> f = BeaconApiRest.findingView(ref);
            Map<String, Object> run = (Map<String, Object>) f.get('run');
            for (Object so : (List<Object>) run.get('steps')) {
                Map<String, Object> s = (Map<String, Object>) so;
                r.steps.add(String.valueOf(s.get('tool')) + '(' + String.valueOf(s.get('input')) + ') ' + String.valueOf(s.get('ms')) + 'ms -> ' + String.valueOf(s.get('output')));
            }
            String st = (String) f.get('status');
            r.text = ref + ' => ' + st + '. ' + String.valueOf(run.get('recommendation')) + ' Owner: ' + String.valueOf(run.get('owner')) + '.'
                + (st == 'PENDING_APPROVAL' ? ' A human must say "approve ' + ref + '" or "reject ' + ref + '".' : '');
            r.status = st;
        } catch (BeaconKpiController.BeaconException e) {
            r.text = e.getMessage();
        }
        return r;
    }
}
