'use strict';
const test = require('node:test'), assert = require('node:assert');
const store = require('../lib/store'), { runPipeline } = require('../lib/pipeline');
const st = id => { store.reset(); return store.run(id, 'v2'); };
test('pipeline quarantines 4 bad records with reasons', () => {
  const m = store.get().pipeline.metrics;
  assert.equal(m.quarantined, 4); assert.equal(m.accepted, 14); assert.ok(m.reasons.duplicate && m.reasons.malformed_json);
});
test('critical findings require a human (G2)', () => { assert.equal(st('E-1002').status, 'PENDING_APPROVAL'); assert.equal(st('E-1008').status, 'PENDING_APPROVAL'); });
test('prompt injection is blocked (G4)', () => assert.equal(st('E-1010').status, 'BLOCKED'));
test('PII asset is never auto-closed (G1)', () => { const r = st('E-1009'); assert.equal(r.status, 'ASSIGNED'); assert.ok(r.guardrails.includes('G1_PII_NO_AUTOCLOSE')); });
test('unknown asset/control -> low confidence -> human (G3)', () => assert.equal(st('E-1014').status, 'PENDING_APPROVAL'));
test('negated malware is benign and auto-closed', () => { const r = st('E-1003'); assert.equal(r.category, 'benign'); assert.equal(r.status, 'AUTO_CLOSED'); });
test('eval gate: v2 >= 95%, v1 < v2', () => { store.reset(); assert.ok(store.evaluate('v2').passRate >= 95); assert.ok(store.evaluate('v1').passRate < store.evaluate('v2').passRate); });
test('pipeline normalises severities', () => assert.equal(runPipeline('{"id":"a","title":"t","sev":"sev4"}').findings[0].severity, 'Critical'));
