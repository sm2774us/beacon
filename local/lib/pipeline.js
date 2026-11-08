'use strict';
// Ingest pipeline (stands in for Data 360 / Snowflake ingestion): validate -> normalise -> dedupe -> quarantine.
const SEVMAP = { low: 'Low', sev1: 'Low', medium: 'Medium', sev2: 'Medium', high: 'High', sev3: 'High', crit: 'Critical', critical: 'Critical', sev4: 'Critical' };
function runPipeline(raw) {
  const seen = new Set(), findings = [], quarantine = [];
  const reasons = {};
  const q = (line, reason) => { quarantine.push({ line: line.slice(0, 80), reason }); reasons[reason] = (reasons[reason] || 0) + 1; };
  const lines = raw.split(/\r?\n/).filter(l => l.trim());
  for (const line of lines) {
    let e; try { e = JSON.parse(line); } catch { q(line, 'malformed_json'); continue; }
    if (!e.id || !e.title) { q(line, 'missing_required_field'); continue; }
    const sev = SEVMAP[String(e.sev).toLowerCase()];
    if (!sev) { q(line, 'invalid_severity'); continue; }
    if (seen.has(e.id)) { q(line, 'duplicate'); continue; }
    seen.add(e.id);
    findings.push({ id: e.id, source: e.src, severity: sev, asset: e.asset, control: e.control, title: e.title, description: e.detail || '', status: 'New' });
  }
  return { findings, quarantine, metrics: { received: lines.length, accepted: findings.length, quarantined: quarantine.length,
    acceptRate: +(findings.length / lines.length * 100).toFixed(1), reasons } };
}
module.exports = { runPipeline };
