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
function compare() { // pure what-if: run BOTH prompt versions on every finding without touching live state
  const ev = { v1: evaluate(S.findings, 'v1'), v2: evaluate(S.findings, 'v2') };
  const exp = {}; ev.v2.rows.forEach(r => { exp[r.id] = r.expected; });
  const rows = S.findings.map(f => {
    const c = ctx(f), v1 = triage(f, c, 'v1'), v2 = triage(f, c, 'v2');
    return { id: f.id, title: f.title, severity: f.severity, description: f.description, source: f.source, asset: f.asset, expected: exp[f.id] || null, v1, v2,
      categoryChanged: v1.category !== v2.category, scoreChanged: v1.score !== v2.score, outcomeChanged: v1.status !== v2.status };
  });
  const agg = v => { const rs = rows.map(r => r[v]), n = rs.length || 1, sum = fn => rs.reduce((a, r) => a + fn(r), 0), st = x => rs.filter(r => r.status === x).length;
    return { passRate: ev[v].passRate, passed: ev[v].passed, total: ev[v].total, autoClosed: st('AUTO_CLOSED'), assigned: st('ASSIGNED'), pending: st('PENDING_APPROVAL'), blocked: st('BLOCKED'),
      avgScore: +(sum(r => r.score) / n).toFixed(1), avgConfidence: +(sum(r => r.confidence) / n).toFixed(2), avgLatencyMs: Math.round(sum(r => r.latencyMs) / n),
      avgTokens: Math.round(sum(r => r.tokens) / n), avgMinutesSaved: +(sum(r => r.minutesSaved) / n).toFixed(1), hoursSaved: +(sum(r => r.minutesSaved) / 60).toFixed(2),
      otherBucket: rs.filter(r => r.category === 'other').length }; };
  return { rows, summary: { v1: agg('v1'), v2: agg('v2'), categoryChanged: rows.filter(r => r.categoryChanged).length, outcomeChanged: rows.filter(r => r.outcomeChanged).length, total: rows.length } };
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
module.exports = { get: () => S, reset, run, compare, decide, kpis, evaluate: v => evaluate(S.findings, v), ctx };
