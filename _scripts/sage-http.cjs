const https = require('https');
const TOKEN = process.env.SAGE_AUTH_TOKEN || 'PLACEHOLDER_TOKEN_HERE';
const HOST = 'mobile-sage.de';
const TIMEOUT = 10000;
const MAX_RETRIES = 3;
function request(method, path, body) {
  const data = body ? JSON.stringify(body) : null;
  return new Promise(resolve => {
    function attempt(n) {
      const opts = { hostname: HOST, port: 443, path, method, timeout: TIMEOUT, headers: { 'Authorization': 'Bearer ' + TOKEN } };
      if (data) { opts.headers['Content-Type'] = 'application/json'; opts.headers['Content-Length'] = Buffer.byteLength(data); }
      const req = https.request(opts, res => { let buf = ''; res.on('data', c => buf += c); res.on('end', () => { try { resolve(JSON.parse(buf)); } catch { resolve({ ok: true, raw: buf }); } }); });
      req.on('timeout', () => { req.destroy(); retry(n); });
      req.on('error', () => retry(n));
      if (data) req.write(data);
      req.end();
    }
    function retry(n) { if (n < MAX_RETRIES) { setTimeout(() => attempt(n + 1), 1000 * n); } else { resolve({ ok: false, error: 'unreachable' }); } }
    attempt(1);
  });
}
module.exports = { request };
