'use strict';
// Terminal demo for cmd.exe / Windows Terminal. Usage: node local/cli/demo.js [--fast]
const store = require('../lib/store');
const fast = process.argv.includes('--fast');
const sleep = ms => new Promise(r => setTimeout(r, fast ? 0 : ms));
const C = { r: '\x1b[31m', g: '\x1b[32m', y: '\x1b[33m', b: '\x1b[36m', m: '\x1b[35m', d: '\x1b[90m', x: '\x1b[0m', B: '\x1b[1m' };
const col = s => ({ AUTO_CLOSED: C.g, ASSIGNED: C.b, PENDING_APPROVAL: C.y, BLOCKED: C.r }[s] || C.x);
const hr = t => console.log(`\n${C.B}${C.b}=== ${t} ===${C.x}`);
(async () => {
  console.log(`${C.B}BEACON - Agentic GRC Control Tower (local FDE demo)${C.x}`);
  const S = store.get(), m = S.pipeline.metrics;
  hr('1. DATA PIPELINE'); await sleep(500);
  console.log(`received=${m.received} accepted=${C.g}${m.accepted}${C.x} quarantined=${C.r}${m.quarantined}${C.x} reasons=${JSON.stringify(m.reasons)}`);
  hr('2. PROMPT EVALS (golden set)'); await sleep(500);
  for (const v of ['v1', 'v2']) { const e = store.evaluate(v); console.log(`prompt ${v}: ${e.passRate >= 95 ? C.g : C.r}${e.passRate}%${C.x} (${e.passed}/${e.total})`);
    if (v === 'v1') e.rows.filter(r => !r.pass).forEach(r => console.log(`${C.d}   miss ${r.id}: expected ${r.expected}, got ${r.got} - ${r.why}${C.x}`)); }
  hr('3. AGENT RUN (prompt v2)');
  for (const f of S.findings) {
    const r = store.run(f.id, 'v2');
    console.log(`\n${C.B}${f.id}${C.x} ${f.title} ${C.d}[${f.source} | ${f.asset} | ${f.severity}]${C.x}`);
    for (const s of r.steps) { await sleep(180); console.log(`  ${C.m}${s.tool}${C.x}(${s.input}) ${C.d}${s.ms}ms${C.x} -> ${s.output}`); }
    console.log(`  ${col(r.status)}${r.status}${C.x} category=${r.category} score=${r.score}/${r.band} conf=${r.confidence} owner=${r.owner}`);
    console.log(`  ${C.d}${r.recommendation}${C.x}`);
    if (r.status === 'PENDING_APPROVAL') { await sleep(250); store.decide(f.id, 'approve'); console.log(`  ${C.y}human approver -> APPROVED${C.x}`); }
  }
  hr('4. KPIs'); const k = store.kpis();
  console.log(`triaged ${k.processed}/${k.total} | auto-closed ${k.autoClosed} | human-gated ${k.approved} | blocked ${k.blocked} | guardrails fired ${k.guardrailsFired}`);
  console.log(`${C.g}${k.hoursSaved} analyst hours saved (~$${k.dollarsSaved}) | avg latency ${k.avgLatencyMs} ms | ${k.avgMinutesSaved} of ${k.manualMinutes} min saved per finding${C.x}`);
})();
