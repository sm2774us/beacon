'use strict';
// Live mode: the Salesforce org is the single source of truth. Uses the Salesforce CLI session (no secrets stored).
// Primary transport: `sf api request rest` (the CLI attaches/refreshes auth itself -> no INVALID_AUTH_HEADER / expired-token issues).
// Fallback transport: direct HTTPS with the access token from `sf org display --json` (older CLIs without `sf api`).
const { exec } = require('child_process');
const SAFE_ALIAS = /^[A-Za-z0-9_.@-]+$/, SAFE_PATH = /^[A-Za-z0-9_\-./]+$/;
let auth = null, authAt = 0, cliApi = null; // cliApi: null=unknown, true/false after first probe

function sh(cmd, stdin) {
  return new Promise(res => {
    const c = exec(cmd, { windowsHide: true, maxBuffer: 50 * 1024 * 1024, timeout: 120000 }, (err, stdout, stderr) => res({ err, out: String(stdout || ''), errText: String(stderr || '') }));
    if (stdin !== undefined) { c.stdin.on('error', () => {}); c.stdin.end(stdin); }
  });
}
function parseJson(s) { // tolerate CLI banners/warnings around the JSON payload
  s = String(s || '').trim();
  try { return JSON.parse(s); } catch (_) {}
  const i = Math.min(...['{', '['].map(ch => { const k = s.indexOf(ch); return k < 0 ? Infinity : k; }));
  if (i !== Infinity) { for (let e = s.length; e > i; e--) { const ch = s[e - 1]; if (ch !== '}' && ch !== ']') continue; try { return JSON.parse(s.slice(i, e)); } catch (_) {} } }
  throw new Error('not json');
}
function check(alias) { if (!SAFE_ALIAS.test(alias || '')) throw new Error(`Invalid org alias "${alias}"`); }

function getAuth(alias, force) {
  if (process.env.SF_MOCK_URL) return Promise.resolve({ token: 'mock', url: process.env.SF_MOCK_URL });
  check(alias);
  if (!force && auth && Date.now() - authAt < 5 * 60 * 1000) return Promise.resolve(auth);
  return sh(`sf org display --target-org ${alias} --json`).then(({ out, errText }) => {
    try {
      const j = parseJson(out);
      if (j.status !== 0 || !j.result) throw new Error(j.message || 'sf returned an error');
      const token = String(j.result.accessToken || '').replace(/\s+/g, ''), url = String(j.result.instanceUrl || '').replace(/\/+$/, '');
      if (!url) throw new Error('no instanceUrl in sf output');
      auth = { token, url }; authAt = Date.now(); return auth;
    } catch (x) { throw new Error(`Cannot read Salesforce CLI session for alias "${alias}". Run deploy-to-salesforce.bat (or: sf org login web --alias ${alias}). Detail: ${x.message} ${errText.slice(0, 120)}`); }
  });
}

function shape(text, status) {
  let j;
  try { j = parseJson(text); } catch { throw new Error(`Unexpected response from org (HTTP ${status}). Is the latest code deployed (deploy-to-salesforce.bat)? ${String(text).slice(0, 200)}`); }
  const errMsg = j && ((typeof j.error === 'string' && j.error) || (Array.isArray(j) && j[0] && (j[0].message || j[0].errorCode)));
  if (errMsg) { const e = new Error(errMsg); e.status = status >= 400 ? status : 502; throw e; }
  return j;
}

async function viaCli(alias, path, method) {
  const url = `/services/apexrest/beacon/api/${path}`;
  const cmd = `sf api request rest "${url}" --method ${method} --target-org ${alias}` + (method === 'POST' ? ' --body -' : '');
  const { err, out, errText } = await sh(cmd, method === 'POST' ? '{}' : undefined);
  const blob = out + '\n' + errText;
  if (/command api:request:rest not found|is not a sf command|Warning: api request rest is not|Unknown command/i.test(blob) && !out.trim().startsWith('{') && !out.trim().startsWith('[')) return { unsupported: true };
  if (err && !out.trim()) {
    if (/No authorization information found|NamedOrgNotFound|expired access\/refresh token|invalid_grant/i.test(blob)) throw new Error(`Salesforce CLI session for alias "${alias}" is missing or expired. Run: sf org login web --alias ${alias} (or deploy-to-salesforce.bat). ${errText.slice(0, 160)}`);
    return { unsupported: true, why: errText.slice(0, 200) };
  }
  return { value: shape(out, err ? 400 : 200) };
}

async function viaToken(alias, path, method, retried) {
  const a = await getAuth(alias, retried);
  if (!a.token) throw new Error('Salesforce CLI returned no access token. Run: sf org login web --alias ' + alias);
  const r = await fetch(`${a.url}/services/apexrest/beacon/api/${path}`, { method, headers: { Authorization: 'Bearer ' + a.token, 'Content-Type': 'application/json', Accept: 'application/json' }, body: method === 'POST' ? '{}' : undefined });
  if ((r.status === 401 || r.status === 403) && !retried) { await sh(`sf org display --target-org ${alias} --json`); return viaToken(alias, path, method, true); }
  const text = await r.text();
  if (r.status === 401) throw new Error(`Salesforce rejected the CLI session (${text.slice(0, 120)}). Run: sf org login web --alias ${alias}`);
  return shape(text, r.status);
}

async function call(alias, path, method) {
  method = method || 'GET';
  if (process.env.SF_MOCK_URL) return viaToken(alias, path, method, true);
  check(alias);
  if (cliApi !== false && SAFE_PATH.test(path)) {
    const r = await viaCli(alias, path, method);
    if (!r.unsupported) { cliApi = true; return r.value; }
    if (cliApi === true) throw new Error('Salesforce CLI call failed. ' + (r.why || ''));
    cliApi = false;
  }
  return viaToken(alias, path, method, false);
}
module.exports = { call, getAuth };
