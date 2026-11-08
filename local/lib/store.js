'use strict';
const fs = require('fs'), path = require('path');
const { triage, evaluate, MANUAL_MIN } = require('./engine');
const { runPipeline } = require('./pipeline');
const D = f => path.join(__dirname, '..', 'data', f);
const load = () => {
  const controls = JSON.parse(fs.readFileSync(D('controls.json'), 'utf8'));
  const assets = JSON.parse(fs.readFileSync(D('assets.json'), 'utf8'));
  const pipeline = runPipeline(fs.readFileSync(D('raw_events.jsonl'), 'utf8'));
  return { controls, assets, pipeline, findings: pipeline.findings, runs: {} };
};
let S = load();
const reset = () => { S = load(); };
const ctx = f => ({ asset: S.assets.find(a => a.name === f.asset), control: S.controls.find(c => c.code === f.control) });
function run(id, ver = 'v2') {
  const f = S.findings.find(x => x.id === id); if (!f) return null;
  const r = triage(f, ctx(f), ver); S.runs[id] = r;
  f.status = r.status; return r;
}
function decide(id, decision) {
  const r = S.runs[id], f = S.findings.find(x => x.id === id);
  if (!r || r.status !== 'PENDING_APPROVAL') return null;
  r.status = decision === 'approve' ? 'APPROVED' : 'REJECTED'; if (decision !== 'approve') r.minutesSaved = 0;
  f.status = r.status; return r;
}
function kpis() {
  const rs = Object.values(S.runs), n = rs.length, c = s => rs.filter(r => r.status === s).length;
  const saved = rs.reduce((a, r) => a + r.minutesSaved, 0) / 60;
  const decided = c('APPROVED') + c('REJECTED');
  return { processed: n, total: S.findings.length, autoClosed: c('AUTO_CLOSED'), assigned: c('ASSIGNED'), pending: c('PENDING_APPROVAL'), blocked: c('BLOCKED'),
    approved: c('APPROVED'), rejected: c('REJECTED'), guardrailsFired: rs.reduce((a, r) => a + r.guardrails.length, 0),
    avgLatencyMs: n ? Math.round(rs.reduce((a, r) => a + r.latencyMs, 0) / n) : 0, hoursSaved: +saved.toFixed(2),
    avgMinutesSaved: n ? +(saved * 60 / n).toFixed(1) : 0, manualMinutes: MANUAL_MIN, dollarsSaved: Math.round(saved * 85),
    overrideRate: decided ? +(c('REJECTED') / decided * 100).toFixed(0) : 0, humanInLoopRate: n ? +((c('PENDING_APPROVAL') + decided) / n * 100).toFixed(0) : 0 };
}
module.exports = { get: () => S, reset, run, decide, kpis, evaluate: v => evaluate(S.findings, v), ctx };
