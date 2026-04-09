const fs = require('fs');
const path = require('path');
const claudeDir = path.join(__dirname, '..', '.claude');
const sessionArg = process.argv[2] || process.env.DURCHARBEITEN_SESSION || '';
function findStateFile() {
  if (sessionArg) { const f = path.join(claudeDir, 'durcharbeiten-' + sessionArg + '.state'); if (fs.existsSync(f)) return f; }
  const legacy = path.join(claudeDir, 'durcharbeiten.state');
  if (fs.existsSync(legacy)) return legacy;
  const files = fs.readdirSync(claudeDir).filter(f => /^durcharbeiten-da-[a-f0-9]+\.state$/.test(f));
  if (files.length === 1) return path.join(claudeDir, files[0]);
  if (files.length > 1) { console.log(files.length + ' aktive Sessions:'); for (const f of files) { const c = fs.readFileSync(path.join(claudeDir, f), 'utf8'); const sid = (c.match(/session_id=(.+)/) || [])[1] || '?'; const task = (c.match(/task=(.+)/) || [])[1] || '?'; console.log('  ' + sid + ': ' + task); } return null; }
  return null;
}
const stateFile = findStateFile();
if (!stateFile) { if (!sessionArg) console.log('Keine aktive Session'); process.exit(0); }
try {
  const s = fs.readFileSync(stateFile, 'utf8');
  const m = s.match(/start_time=(\d+)/);
  const l = s.match(/limit_minutes=(\d+)/);
  if (!m || !l) { console.log('State-Datei unvollstaendig'); process.exit(1); }
  const elapsed = Math.round((Date.now() / 1000 - m[1]) / 60);
  const left = Math.round(l[1] - elapsed);
  if (left <= 0) { console.log('Zeit abgelaufen (' + Math.abs(left) + ' Min ueber Limit)'); }
  else { console.log(left + ' Minuten uebrig (von ' + l[1] + ', ' + elapsed + ' Min vergangen)'); }
  if (elapsed >= 30) {
    console.log('\n--- REMINDER (Context-Refresh) ---');
    console.log('Du kannst: Fork-Tabs starten (wt.exe -p "Sage Fork"), Subagents starten,');
    console.log('Screenshots machen, Flags setzen (/flag), Playwright nutzen,');
    console.log('Dateien im Vault lesen/schreiben.');
    console.log('Bei Unsicherheit: _skills/ lesen fuer Details.');
    console.log('----------------------------------');
  }
} catch (e) { console.log('Keine aktive Session'); }
