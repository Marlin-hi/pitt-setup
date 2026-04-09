const { request } = require('./sage-http.cjs');
const [,, session_id, summary] = process.argv;
if (!session_id) { console.error('Usage: node durcharbeiten-end.cjs "session_id" ["summary"]'); process.exit(1); }
request('POST', '/api/durcharbeiten/end', { session_id, summary: summary || '' }).then(r => console.log(JSON.stringify(r)));
