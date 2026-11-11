'use strict';
// Zero-dependency server. Run: node local/server.js  (or run-demo.bat)
const http = require('http'), fs = require('fs'), path = require('path');
const store = require('./lib/store');
const { runPipeline } = require('./lib/pipeline');
const PORT = process.env.PORT || 8080;
const SF_ORG = process.env.SF_ORG || ((process.argv.find(a => a.startsWith('--org=')) || '').slice(6)) || '';
const sf = SF_ORG ? require('./lib/sf') : null;
const json = (res, o, c = 200) => { res.writeHead(c, { 'Content-Type': 'application/json' }); res.end(JSON.stringify(o)); };
const body = req => new Promise(r => { let b = ''; req.on('data', d => b += d); req.on('end', () => { try { r(JSON.parse(b || '{}')); } catch { r({}); } }); });
const state = () => { const s = store.get(); return { findings: s.findings.map(f => ({ ...f, run: s.runs[f.id] || null })), kpis: store.kpis(), pipeline: s.pipeline.metrics, quarantine: s.pipeline.quarantine, controls: s.controls, assets: s.assets }; };
async function orgRoute(req, res, p) { // live mode: proxy to the Salesforce org (single source of truth)
  let m;
  if (p === '/api/state') return json(res, await sf.call(SF_ORG, 'state'));
  if (p === '/api/compare') return json(res, await sf.call(SF_ORG, 'compare'));
  if (p === '/api/reset' && req.method === 'POST') return json(res, await sf.call(SF_ORG, 'reset', 'POST'));
  if (p === '/api/run-all' && req.method === 'POST') {
    const pv = new URL(req.url, 'http://x').searchParams.get('prompt') === 'v1' ? 'v1' : 'v2';
    await sf.call(SF_ORG, 'triageall/' + pv, 'POST'); return json(res, await sf.call(SF_ORG, 'state'));
  }
  if ((m = p.match(/^\/api\/findings\/([^/]+)\/run$/)) && req.method === 'POST') {
    const pv = new URL(req.url, 'http://x').searchParams.get('prompt') === 'v1' ? 'v1' : 'v2';
    const st = await sf.call(SF_ORG, 'triage/' + encodeURIComponent(m[1]) + '/' + pv, 'POST'); const f = st.findings.find(x => x.id === m[1]);
    return json(res, { run: f && f.run, kpis: st.kpis });
  }
  if ((m = p.match(/^\/api\/findings\/([^/]+)\/(approve|reject)$/)) && req.method === 'POST') {
    const st = await sf.call(SF_ORG, `decision/${encodeURIComponent(m[1])}/${m[2]}`, 'POST'); const f = st.findings.find(x => x.id === m[1]);
    return json(res, { run: f && f.run, kpis: st.kpis });
  }
  return false;
}
http.createServer(async (req, res) => {
  const u = new URL(req.url, 'http://x'), p = u.pathname;
  if (p === '/api/mode') { let url = ''; if (sf) { try { url = (await sf.getAuth(SF_ORG)).url; } catch (e) { url = 'NOT CONNECTED: ' + e.message; } } return json(res, { mode: sf ? 'salesforce' : 'local', org: SF_ORG, url }); }
  if (sf && p.startsWith('/api/') && p !== '/api/evals') {
    try { const r = await orgRoute(req, res, p); if (r !== false) return; } catch (e) { return json(res, { error: e.message }, e.status || 502); }
  }
  if (p === '/api/state') return json(res, state());
  if (p === '/api/reset' && req.method === 'POST') { store.reset(); return json(res, state()); }
  if (p === '/api/compare') return json(res, store.compare());
  if (p === '/api/run-all' && req.method === 'POST') {
    const pv = u.searchParams.get('prompt') === 'v1' ? 'v1' : 'v2';
    store.get().findings.filter(f => f.status !== 'APPROVED' && f.status !== 'REJECTED').forEach(f => store.run(f.id, pv)); return json(res, state());
  }
  if (p === '/api/evals') return json(res, store.evaluate(u.searchParams.get('prompt') || 'v2'));
  let m;
  if ((m = p.match(/^\/api\/findings\/([^/]+)\/run$/)) && req.method === 'POST') {
    const r = store.run(m[1], u.searchParams.get('prompt') || 'v2'); return r ? json(res, { run: r, kpis: store.kpis() }) : json(res, { error: 'not found' }, 404);
  }
  if ((m = p.match(/^\/api\/findings\/([^/]+)\/(approve|reject)$/)) && req.method === 'POST') {
    const r = store.decide(m[1], m[2]); return r ? json(res, { run: r, kpis: store.kpis() }) : json(res, { error: 'not pending' }, 409);
  }
  if (p === '/api/v1/findings' && req.method === 'POST') { // mirrors Apex REST /services/apexrest/beacon/v1/findings
    const b = await body(req);
    const out = runPipeline((Array.isArray(b) ? b : [b]).map(x => JSON.stringify(x)).join('\n'));
    const s = store.get(); let added = 0;
    out.findings.forEach(f => { if (!s.findings.find(x => x.id === f.id)) { s.findings.push(f); added++; } });
    return json(res, { added, ...out.metrics });
  }
  const file = path.join(__dirname, 'public', p === '/' ? 'index.html' : p.replace(/\.\./g, ''));
  fs.readFile(file, (e, d) => { if (e) { res.writeHead(404); return res.end('Not found'); } res.writeHead(200, { 'Content-Type': file.endsWith('.html') ? 'text/html' : 'text/plain' }); res.end(d); });
}).listen(PORT, () => console.log(`Beacon Control Tower running -> http://localhost:${PORT}  [${sf ? 'LIVE: Salesforce org alias ' + SF_ORG : 'LOCAL sandbox (not connected to an org)'}]`));
