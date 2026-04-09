# Bridge -- Dauerhafter Kommunikationskanal

Dieser Skill startet den dauerhaften Bridge-Poll in einem eigenen Tab.

## Trigger

Wenn Pitt die Bruecke erwaehnt ("Bruecke", "Bridge", "oeffne die Bruecke", "starte die Bridge").

## Was du tust

1. Starte einen neuen Terminal-Tab mit dem Bridge-Poll:

```powershell
powershell -ExecutionPolicy Bypass -File "_scripts/launch-bridge.ps1"
```

2. Der neue Tab pollt dauerhaft den Channel `pitt` auf bridge.hylox.org
3. Dein Haupttab bleibt frei fuer Pitts Arbeit -- du wirst NICHT unterbrochen

## Alternativ (falls launch-bridge.ps1 nicht funktioniert)

```powershell
wt.exe -w 0 nt --title "Bridge" -- powershell -NoExit -Command "cd '$PWD'; claude 'Du bist als Fork-Tab gestartet. Lies _forks/bridge-poll.md und arbeite es ab.'"
```

## Im Haupttab

Nach dem Fork-Start:
- Pitt arbeitet normal mit dir weiter
- Bridge-Nachrichten erscheinen im separaten Bridge-Tab
- Pitt kann jederzeit in den Bridge-Tab wechseln um zu antworten
- Der Bridge-Tab laeuft unabhaengig und wird nicht durch Nachrichten hier unterbrochen

## Direkt senden (ohne Fork-Tab)

```bash
curl -s -X POST "https://bridge.hylox.org/channel/pitt" -H "Authorization: Bearer ef095bae2d81d8dc86e0b477a9fa963c" -H "Content-Type: application/json" -d '{"from":"sage","text":"NACHRICHT"}'
```
