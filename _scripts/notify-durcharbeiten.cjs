const { request } = require('./sage-http.cjs');
const [,, status, message, task, session_id] = process.argv;
if (!message) { console.error('Usage: node notify-durcharbeiten.cjs "status" "message" ["task"] ["session_id"]'); process.exit(1); }
request('POST', '/api/durcharbeiten', { status: status || 'Update', message, task: task || '', session_id: session_id || '' }).then(r => console.log(JSON.stringify(r)));
