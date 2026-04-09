const { request } = require('./sage-http.cjs');
const [,, session_id, current_work, progress, status] = process.argv;
if (!session_id) { console.error('Usage: node durcharbeiten-heartbeat.cjs "session_id" "current_work" ["progress"] ["status"]'); process.exit(1); }
request('POST', '/api/durcharbeiten/heartbeat', { session_id, current_work: current_work || '', progress: progress || '', status: status || 'running' }).then(r => console.log(JSON.stringify(r)));
