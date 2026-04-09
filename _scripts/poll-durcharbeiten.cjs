const { request } = require('./sage-http.cjs');
const since = process.argv[2] || '';
const session_id = process.argv[3] || '';
const params = [];
if (since) params.push('since=' + encodeURIComponent(since));
if (session_id) params.push('session_id=' + encodeURIComponent(session_id));
const qs = params.length ? '?' + params.join('&') : '';
request('GET', '/api/durcharbeiten/replies' + qs).then(r => console.log(JSON.stringify(r)));
