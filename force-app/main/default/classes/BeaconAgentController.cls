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
    static final Pattern VER_PAT = Pattern.compile('(?i)\\bv([12])\\b');
    static final String HELP = 'Try: "triage E-1002", "triage E-1002 with v1", "compare E-1002", "compare all", "why is E-1010 blocked", "approve E-1002", "reject E-1008", "triage all new", "status", "reset".';

    @AuraEnabled
    public static Reply ask(String message) {
        Reply r = new Reply();
        String msg = message == null ? '' : message;
        String m = msg.toLowerCase();
        Matcher mt = ID_PAT.matcher(msg);
        String ref = mt.find() ? mt.group(1).toUpperCase() : null;

        Matcher vm = VER_PAT.matcher(msg);
        String ver = vm.find() ? 'v' + vm.group(1) : 'v2';
        if (ref == null) {
            if (m.contains('compare')) {
                Map<String, Object> s = (Map<String, Object>) BeaconApiRest.compare().get('summary');
                Map<String, Object> s1 = (Map<String, Object>) s.get('v1');
                Map<String, Object> s2 = (Map<String, Object>) s.get('v2');
                r.text = 'v1 vs v2 on ' + s.get('total') + ' findings: golden accuracy ' + s1.get('passRate') + '% vs ' + s2.get('passRate') + '%; auto-closed '
                    + s1.get('autoClosed') + ' vs ' + s2.get('autoClosed') + '; "other" bucket ' + s1.get('otherBucket') + ' vs ' + s2.get('otherBucket') + '; '
                    + s.get('categoryChanged') + ' category change(s), ' + s.get('outcomeChanged') + ' outcome change(s). Open the V1 vs V2 Lab tab for detail.';
                r.status = 'Done';
            } else if (m.contains('reset')) {
                BeaconSeed.reset();
                r.text = 'Demo reset to a clean slate: all findings are New and all telemetry is cleared.';
                r.status = 'Done';
            } else if (m.contains('triage all') || m.contains('run all') || m.contains('all new')) {
                Integer n = BeaconKpiController.triageAll(ver, m.contains('re-run') || m.contains('rerun') || m.contains('run all'));
                r.text = 'Triaged ' + n + ' finding(s) with prompt ' + ver + '. Critical and low-confidence items are waiting for human approval.';
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
            if (m.contains('compare')) {
                for (Object co : (List<Object>) BeaconApiRest.compare().get('rows')) {
                    Map<String, Object> row = (Map<String, Object>) co;
                    if (ref != (String) row.get('id')) { continue; }
                    Map<String, Object> a = (Map<String, Object>) row.get('v1');
                    Map<String, Object> b = (Map<String, Object>) row.get('v2');
                    r.text = ref + ' (golden: ' + row.get('expected') + ')  v1 => ' + a.get('category') + ', score ' + a.get('score') + ', ' + a.get('status')
                        + '   |   v2 => ' + b.get('category') + ', score ' + b.get('score') + ', ' + b.get('status') + '. Nothing was changed in the queue.';
                    r.status = 'Done';
                    return r;
                }
                r.text = 'No finding matches ' + ref + '.';
                return r;
            }
            Map<String, Object> prior = BeaconApiRest.findingView(ref);
            if (prior == null) { r.text = 'No finding matches ' + ref + '. Say "reset" to reload the demo data.'; return r; }
            Boolean explain = (m.contains('why') || m.contains('explain')) && (String) prior.get('status') != 'New';
            if (!explain) { BeaconKpiController.triageByRef(ref, ver); }
            Map<String, Object> f = BeaconApiRest.findingView(ref);
            Map<String, Object> run = (Map<String, Object>) f.get('run');
            for (Object so : (List<Object>) run.get('steps')) {
                Map<String, Object> s = (Map<String, Object>) so;
                r.steps.add(String.valueOf(s.get('tool')) + '(' + String.valueOf(s.get('input')) + ') ' + String.valueOf(s.get('ms')) + 'ms -> ' + String.valueOf(s.get('output')));
            }
            String st = (String) f.get('status');
            r.text = ref + ' => ' + st + ' (prompt ' + String.valueOf(run.get('promptVersion')) + '). ' + String.valueOf(run.get('recommendation')) + ' Owner: ' + String.valueOf(run.get('owner')) + '.'
                + (st == 'PENDING_APPROVAL' ? ' A human must say "approve ' + ref + '" or "reject ' + ref + '".' : '');
            r.status = st;
        } catch (BeaconKpiController.BeaconException e) {
            r.text = e.getMessage();
        }
        return r;
    }
}
