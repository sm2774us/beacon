'use strict';
// Beacon triage engine: mirrors force-app BeaconTriageEngine.cls (same rules, same thresholds).
const SEV = { Low: 1, Medium: 2, High: 3, Critical: 4 };
const CATS = ['malware', 'phishing', 'identity', 'exposure', 'privilege', 'drift'];
const BONUS = { malware: 10, exposure: 8, identity: 8, privilege: 8, phishing: 5, drift: 3, benign: -25, other: 0 };
const KW = {
  v1: { malware: ['malware', 'ransomware', 'c2 beacon'], phishing: ['phish'], identity: [], exposure: ['exposed'], privilege: ['sudo', 'admin role'], drift: ['drift'] },
  v2: { malware: ['malware', 'ransomware', 'c2 '], phishing: ['phish', 'credential harvest'], identity: ['impossible travel', 'mfa disabled'],
        exposure: ['public-read', 'publicly accessible', '0.0.0.0/0', 'unencrypted', 'exposed'], privilege: ['sudo', 'admin role', 'root account', 'privilege'], drift: ['drift', 'baseline'] }
};
const NEGATION = /(no evidence of|false positive|came back clean|not malicious)/;
const INJECTION = /(ignore (all )?(previous|prior) instructions|system prompt|disregard (the )?policy)/;
const MANUAL_MIN = 18;
const REC = {
  malware: 'Isolate host, snapshot memory, open IR ticket and notify SOC lead.',
  phishing: 'Block sender/URL, force credential reset for clickers, run mailbox purge.',
  identity: 'Revoke sessions, enforce MFA, verify with the account owner.',
  exposure: 'Remove public exposure / enable encryption, confirm data classification, raise change ticket.',
  privilege: 'Revert elevated role, review change record, attest with control owner.',
  drift: 'Re-apply baseline via IaC pipeline; no customer impact expected.',
  benign: 'Likely false positive; document evidence and tune detection rule.',
  other: 'Route to control owner for review.'
};
const hash = s => [...s].reduce((a, c) => (a * 31 + c.charCodeAt(0)) >>> 0, 7);

function classify(text, ver = 'v2') {
  const t = text.toLowerCase();
  if (ver === 'v2' && NEGATION.test(t)) return { category: 'benign', matched: 'negation', why: 'Negation pattern found; treated as false positive.' };
  for (const c of CATS) {
    const hit = KW[ver][c].find(k => t.includes(k));
    if (hit) return { category: c, matched: hit, why: `Matched "${hit}" -> ${c}` };
  }
  return { category: 'other', matched: null, why: 'No keyword matched' };
}
const band = s => (s >= 75 ? 'Critical' : s >= 50 ? 'High' : s >= 30 ? 'Medium' : 'Low');

function triage(f, ctx, ver = 'v2') {
  const asset = ctx.asset, control = ctx.control, steps = [];
  const step = (tool, input, output, base) => steps.push({ tool, input, output, ms: base + (hash(f.id + tool) % 40) });
  step('get_asset_context', f.asset, asset ? `tier ${asset.tier}, pii=${asset.pii}, internet=${asset.internet}` : 'UNKNOWN ASSET', 60);
  step('lookup_control', f.control, control ? `${control.framework} ${control.code} ${control.name} (criticality ${control.criticality})` : 'UNMAPPED CONTROL', 45);
  const text = `${f.title}. ${f.description}`;
  const injected = INJECTION.test(text.toLowerCase());
  const cl = classify(text, ver);
  step('classify_llm', `prompt ${ver}`, cl.why, 420);
  let score = SEV[f.severity] * 10 + BONUS[cl.category] + (control ? control.criticality : 0);
  if (asset) score += (asset.tier === 1 ? 15 : asset.tier === 2 ? 8 : 0) + (asset.pii ? 10 : 0) + (asset.internet ? 8 : 0);
  score = Math.max(0, Math.min(100, score));
  const b = band(score);
  step('score_risk', `sev=${f.severity}`, `score ${score} -> ${b}`, 20);
  const confidence = Math.min(1, 0.5 + (control ? 0.15 : 0) + (asset ? 0.15 : 0) + (cl.category !== 'other' ? 0.15 : 0) + 0.05);
  const guardrails = []; let status;
  if (injected) { status = 'BLOCKED'; guardrails.push('G4_PROMPT_INJECTION'); }
  else if (b === 'Critical') { status = 'PENDING_APPROVAL'; guardrails.push('G2_CRITICAL_REQUIRES_HUMAN'); }
  else if (confidence < 0.6) { status = 'PENDING_APPROVAL'; guardrails.push('G3_LOW_CONFIDENCE_REQUIRES_HUMAN'); }
  else if (b === 'Low' && confidence >= 0.85) {
    if (asset && asset.pii) { status = 'ASSIGNED'; guardrails.push('G1_PII_NO_AUTOCLOSE'); } else status = 'AUTO_CLOSED';
  } else status = 'ASSIGNED';
  step('policy_guardrail', `conf=${confidence.toFixed(2)}`, guardrails.length ? guardrails.join(',') : 'no guardrail fired', 15);
  const minutesSaved = { AUTO_CLOSED: 17.5, ASSIGNED: 14, PENDING_APPROVAL: 12, BLOCKED: 0 }[status];
  const recommendation = injected ? 'Content attempted to override agent policy. Quarantined; notify SOC.' : REC[cl.category];
  const latencyMs = steps.reduce((a, s) => a + s.ms, 0);
  const tokens = Math.round((text.length + recommendation.length) / 4) + 380;
  return { findingId: f.id, promptVersion: ver, category: cl.category, score, band: b, confidence: +confidence.toFixed(2),
    status, guardrails, recommendation, steps, latencyMs, tokens, minutesSaved, owner: control ? control.owner : 'GRC Office (unmapped)' };
}

// Golden set for LLM evaluation (engineering rigor): expected category per event id.
const GOLDEN = { 'E-1001': 'identity', 'E-1002': 'exposure', 'E-1003': 'benign', 'E-1004': 'drift', 'E-1005': 'privilege', 'E-1006': 'phishing', 'E-1007': 'exposure',
  'E-1008': 'malware', 'E-1009': 'other', 'E-1010': 'other', 'E-1011': 'exposure', 'E-1012': 'other', 'E-1013': 'privilege', 'E-1014': 'other' };
function evaluate(findings, ver) {
  const rows = findings.filter(f => GOLDEN[f.id]).map(f => {
    const r = classify(`${f.title}. ${f.description}`, ver);
    return { id: f.id, title: f.title, expected: GOLDEN[f.id], got: r.category, pass: r.category === GOLDEN[f.id], why: r.why };
  });
  const passed = rows.filter(r => r.pass).length;
  return { promptVersion: ver, total: rows.length, passed, passRate: +(passed / rows.length * 100).toFixed(1), rows };
}
module.exports = { triage, classify, evaluate, MANUAL_MIN, SEV };
