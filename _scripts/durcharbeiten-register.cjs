const { request } = require('./sage-http.cjs');
const [,, session_id, task, limit, url] = process.argv;
if (!session_id || !task) { console.error('Usage: node durcharbeiten-register.cjs "session_id" "task" [limit_minutes] [url]'); process.exit(1); }
const body = { session_id, task, limit_minutes: parseInt(limit) || 60 };
if (url) body.url = url;
request('POST', '/api/durcharbeiten/register', body).then(r => console.log(JSON.stringify(r)));
