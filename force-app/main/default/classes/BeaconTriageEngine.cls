/**
 * Triage rules. Mirrors local/lib/engine.js (prompt v1 AND v2): same weights, thresholds, guardrails, step trace and latency model,
 * so the Lightning app and the local console show identical numbers.
 */
public with sharing class BeaconTriageEngine {
    public class Step {
        public String tool;
        public String input;
        public String output;
        public Integer ms;
    }
    public class Result {
        public String category;
        public Integer score;
        public String band;
        public Decimal confidence;
        public String status;
        public List<String> guardrails = new List<String>();
        public String recommendation;
        public Decimal minutesSaved;
        public Integer latencyMs;
        public Integer tokens;
        public String owner;
        public List<Step> steps = new List<Step>();
    }

    static final Map<String, Integer> SEV = new Map<String, Integer>{ 'Low' => 1, 'Medium' => 2, 'High' => 3, 'Critical' => 4 };
    static final Map<String, Integer> BONUS = new Map<String, Integer>{
        'malware' => 10, 'exposure' => 8, 'identity' => 8, 'privilege' => 8, 'phishing' => 5, 'drift' => 3, 'benign' => -25, 'other' => 0
    };
    static final List<String> CATS = new List<String>{ 'malware', 'phishing', 'identity', 'exposure', 'privilege', 'drift' };
    static final Map<String, List<String>> KW_V1 = new Map<String, List<String>>{
        'malware' => new List<String>{ 'malware', 'ransomware', 'c2 beacon' },
        'phishing' => new List<String>{ 'phish' },
        'identity' => new List<String>(),
        'exposure' => new List<String>{ 'exposed' },
        'privilege' => new List<String>{ 'sudo', 'admin role' },
        'drift' => new List<String>{ 'drift' }
    };
    static final Map<String, List<String>> KW = new Map<String, List<String>>{
        'malware' => new List<String>{ 'malware', 'ransomware', 'c2 ' },
        'phishing' => new List<String>{ 'phish', 'credential harvest' },
        'identity' => new List<String>{ 'impossible travel', 'mfa disabled' },
        'exposure' => new List<String>{ 'public-read', 'publicly accessible', '0.0.0.0/0', 'unencrypted', 'exposed' },
        'privilege' => new List<String>{ 'sudo', 'admin role', 'root account', 'privilege' },
        'drift' => new List<String>{ 'drift', 'baseline' }
    };
    static final Map<String, String> REC = new Map<String, String>{
        'malware' => 'Isolate host, snapshot memory, open IR ticket and notify SOC lead.',
        'phishing' => 'Block sender/URL, force credential reset for clickers, run mailbox purge.',
        'identity' => 'Revoke sessions, enforce MFA, verify with the account owner.',
        'exposure' => 'Remove public exposure / enable encryption, confirm data classification, raise change ticket.',
        'privilege' => 'Revert elevated role, review change record, attest with control owner.',
        'drift' => 'Re-apply baseline via IaC pipeline; no customer impact expected.',
        'benign' => 'Likely false positive; document evidence and tune detection rule.',
        'other' => 'Route to control owner for review.'
    };
    static final Pattern NEGATION = Pattern.compile('(no evidence of|false positive|came back clean|not malicious)');
    static final Pattern INJECTION = Pattern.compile('(ignore (all )?(previous|prior) instructions|system prompt|disregard (the )?policy)');

    /** Returns {category, why}. */
    public static List<String> classifyDetail(String text) {
        return classifyDetail(text, 'v2');
    }

    /** Prompt-version aware classifier. v1: smaller vocabulary and no negation pre-check. v2: full vocabulary plus negation. */
    public static List<String> classifyDetail(String text, String ver) {
        String t = (text == null ? '' : text).toLowerCase();
        Map<String, List<String>> kws = ver == 'v1' ? KW_V1 : KW;
        if (ver != 'v1' && NEGATION.matcher(t).find()) {
            return new List<String>{ 'benign', 'Negation pattern found; treated as false positive.' };
        }
        for (String c : CATS) {
            for (String k : kws.get(c)) {
                if (t.contains(k)) { return new List<String>{ c, 'Matched "' + k + '" -> ' + c }; }
            }
        }
        return new List<String>{ 'other', 'No keyword matched' };
    }

    public static String classify(String text) {
        return classifyDetail(text)[0];
    }

    static Long hash(String s) {
        Long h = 7;
        for (Integer i = 0; i < s.length(); i++) {
            h = Math.mod(h * 31 + s.charAt(i), 4294967296L);
        }
        return h;
    }

    static void addStep(Result r, String id, String tool, String input, String output, Integer base) {
        Step st = new Step();
        st.tool = tool;
        st.input = input;
        st.output = output;
        st.ms = base + Math.mod(hash(id + tool), 40L).intValue();
        r.steps.add(st);
    }

    public static Result triage(Finding__c f, Asset__c asset, Control__c control) {
        return triage(f, asset, control, 'v2');
    }

    /** Golden labels (expected category per event id) used by the eval harness and the v1 vs v2 comparison. */
    public static final Map<String, String> GOLDEN = new Map<String, String>{
        'E-1001' => 'identity', 'E-1002' => 'exposure', 'E-1003' => 'benign', 'E-1004' => 'drift', 'E-1005' => 'privilege', 'E-1006' => 'phishing',
        'E-1007' => 'exposure', 'E-1008' => 'malware', 'E-1009' => 'other', 'E-1010' => 'other', 'E-1011' => 'exposure', 'E-1012' => 'other',
        'E-1013' => 'privilege', 'E-1014' => 'other'
    };

    public static Result triage(Finding__c f, Asset__c asset, Control__c control, String ver) {
        String pv = ver == 'v1' ? 'v1' : 'v2';
        Result r = new Result();
        String id = f.External_Id__c == null ? '' : f.External_Id__c;
        String descText = f.Description__c == null ? '' : f.Description__c;
        String text = f.Title__c + '. ' + descText;
        Boolean injected = INJECTION.matcher(text.toLowerCase()).find();

        addStep(r, id, 'get_asset_context', f.Asset_Ref__c == null ? '' : f.Asset_Ref__c,
            asset == null ? 'UNKNOWN ASSET' : 'tier ' + asset.Tier__c.intValue() + ', pii=' + asset.Contains_PII__c + ', internet=' + asset.Internet_Facing__c, 60);
        addStep(r, id, 'lookup_control', f.Control_Ref__c == null ? '' : f.Control_Ref__c,
            control == null ? 'UNMAPPED CONTROL' : control.Framework__c + ' ' + control.Control_Code__c + ' ' + control.Name + ' (criticality ' + control.Criticality__c.intValue() + ')', 45);
        List<String> cl = classifyDetail(text, pv);
        r.category = cl[0];
        addStep(r, id, 'classify_llm', 'prompt ' + pv, cl[1], 420);

        Integer score = SEV.get(f.Severity__c) * 10 + BONUS.get(r.category);
        if (control != null && control.Criticality__c != null) { score += control.Criticality__c.intValue(); }
        if (asset != null) {
            score += (asset.Tier__c == 1 ? 15 : (asset.Tier__c == 2 ? 8 : 0));
            if (asset.Contains_PII__c) { score += 10; }
            if (asset.Internet_Facing__c) { score += 8; }
        }
        r.score = Math.max(0, Math.min(100, score));
        r.band = r.score >= 75 ? 'Critical' : (r.score >= 50 ? 'High' : (r.score >= 30 ? 'Medium' : 'Low'));
        addStep(r, id, 'score_risk', 'sev=' + f.Severity__c, 'score ' + r.score + ' -> ' + r.band, 20);

        r.confidence = 0.5 + (control != null ? 0.15 : 0) + (asset != null ? 0.15 : 0) + (r.category != 'other' ? 0.15 : 0) + 0.05;
        if (r.confidence > 1) { r.confidence = 1; }
        if (injected) { r.status = 'Blocked'; r.guardrails.add('G4_PROMPT_INJECTION'); }
        else if (r.band == 'Critical') { r.status = 'Pending Approval'; r.guardrails.add('G2_CRITICAL_REQUIRES_HUMAN'); }
        else if (r.confidence < 0.6) { r.status = 'Pending Approval'; r.guardrails.add('G3_LOW_CONFIDENCE_REQUIRES_HUMAN'); }
        else if (r.band == 'Low' && r.confidence >= 0.85) {
            if (asset != null && asset.Contains_PII__c) { r.status = 'Assigned'; r.guardrails.add('G1_PII_NO_AUTOCLOSE'); }
            else { r.status = 'Auto-Closed'; }
        } else { r.status = 'Assigned'; }
        addStep(r, id, 'policy_guardrail', 'conf=' + r.confidence.setScale(2), r.guardrails.isEmpty() ? 'no guardrail fired' : String.join(r.guardrails, ','), 15);

        r.minutesSaved = r.status == 'Auto-Closed' ? 17.5 : (r.status == 'Assigned' ? 14 : (r.status == 'Pending Approval' ? 12 : 0));
        r.recommendation = injected ? 'Content attempted to override agent policy. Quarantined; notify SOC.' : REC.get(r.category);
        Integer lat = 0;
        for (Step s : r.steps) { lat += s.ms; }
        r.latencyMs = lat;
        r.tokens = Math.roundToLong((text.length() + r.recommendation.length()) / 4.0).intValue() + 380;
        r.owner = (control != null && control.Owner_Team__c != null) ? control.Owner_Team__c : 'GRC Office (unmapped)';
        return r;
    }
}
