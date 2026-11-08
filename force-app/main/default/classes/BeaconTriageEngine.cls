/**
 * Triage rules. Mirrors local/lib/engine.js (prompt v2 rules): same weights, thresholds and guardrails.
 * Deterministic on purpose: the LLM-facing step (classification) is replaceable by an Agentforce
 * Prompt Template, while scoring and guardrails stay auditable Apex.
 */
public with sharing class BeaconTriageEngine {
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
    }

    static final Map<String, Integer> SEV = new Map<String, Integer>{ 'Low' => 1, 'Medium' => 2, 'High' => 3, 'Critical' => 4 };
    static final Map<String, Integer> BONUS = new Map<String, Integer>{
        'malware' => 10, 'exposure' => 8, 'identity' => 8, 'privilege' => 8, 'phishing' => 5, 'drift' => 3, 'benign' => -25, 'other' => 0
    };
    static final List<String> CATS = new List<String>{ 'malware', 'phishing', 'identity', 'exposure', 'privilege', 'drift' };
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

    public static String classify(String text) {
        String t = (text == null ? '' : text).toLowerCase();
        if (NEGATION.matcher(t).find()) { return 'benign'; }
        for (String c : CATS) {
            for (String k : KW.get(c)) {
                if (t.contains(k)) { return c; }
            }
        }
        return 'other';
    }

    public static Result triage(Finding__c f, Asset__c asset, Control__c control) {
        Result r = new Result();
        String text = f.Title__c + '. ' + f.Description__c;
        Boolean injected = INJECTION.matcher(text.toLowerCase()).find();
        r.category = classify(text);
        Integer score = SEV.get(f.Severity__c) * 10 + BONUS.get(r.category);
        if (control != null && control.Criticality__c != null) { score += control.Criticality__c.intValue(); }
        if (asset != null) {
            score += (asset.Tier__c == 1 ? 15 : (asset.Tier__c == 2 ? 8 : 0));
            if (asset.Contains_PII__c) { score += 10; }
            if (asset.Internet_Facing__c) { score += 8; }
        }
        r.score = Math.max(0, Math.min(100, score));
        r.band = r.score >= 75 ? 'Critical' : (r.score >= 50 ? 'High' : (r.score >= 30 ? 'Medium' : 'Low'));
        r.confidence = 0.5 + (control != null ? 0.15 : 0) + (asset != null ? 0.15 : 0) + (r.category != 'other' ? 0.15 : 0) + 0.05;
        if (r.confidence > 1) { r.confidence = 1; }
        if (injected) { r.status = 'Blocked'; r.guardrails.add('G4_PROMPT_INJECTION'); }
        else if (r.band == 'Critical') { r.status = 'Pending Approval'; r.guardrails.add('G2_CRITICAL_REQUIRES_HUMAN'); }
        else if (r.confidence < 0.6) { r.status = 'Pending Approval'; r.guardrails.add('G3_LOW_CONFIDENCE_REQUIRES_HUMAN'); }
        else if (r.band == 'Low' && r.confidence >= 0.85) {
            if (asset != null && asset.Contains_PII__c) { r.status = 'Assigned'; r.guardrails.add('G1_PII_NO_AUTOCLOSE'); }
            else { r.status = 'Auto-Closed'; }
        } else { r.status = 'Assigned'; }
        r.minutesSaved = r.status == 'Auto-Closed' ? 17.5 : (r.status == 'Assigned' ? 14 : (r.status == 'Pending Approval' ? 12 : 0));
        r.recommendation = injected ? 'Content attempted to override agent policy. Quarantined; notify SOC.' : REC.get(r.category);
        r.tokens = (text.length() + r.recommendation.length()) / 4 + 380;
        r.latencyMs = 560 + Math.mod(Math.abs(f.External_Id__c == null ? 0 : f.External_Id__c.hashCode()), 120);
        return r;
    }
}
