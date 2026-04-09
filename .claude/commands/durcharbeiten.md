Aktiviere den Durcharbeiten-Modus -- baut bis die Zeit um ist, kommuniziert ueber mobile-sage.

Argumente: $ARGUMENTS (Format: "Zeitlimit Aufgabenbeschreibung", z.B. "30m Flags abarbeiten")

**Dashboard:** `https://mobile-sage.de/durcharbeiten.html`

Anweisungen:

1. Parse das erste Argument als Zeitlimit (z.B. "30m", "1h", "45m"). Default: 30m. Der Rest ist die Aufgabenbeschreibung.
2. **Pruefe ob die Env-Variable `DURCHARBEITEN_SESSION` gesetzt ist:**
   - **JA -> Du bist der WORKER (Fork-Tab). Springe zu Schritt 9.**
   - **NEIN -> Du bist der LAUNCHER. Weiter mit Schritt 3.**

---

**LAUNCHER-MODUS (Schritte 3-8):**

3. Generiere eine Session-ID: `da-` + 6 zufaellige Hex-Zeichen.
4. Erstelle `.claude/durcharbeiten-<session_id>.state`:

```
session_id=<session_id>
start_time=<Unix-Timestamp>
limit_minutes=<Minuten>
task=<Aufgabenbeschreibung>
mode=standard
launched=true
```

Nutze `node -e "console.log(Math.floor(Date.now()/1000))"` fuer den Unix-Timestamp.

5. **Registriere die Session beim Dashboard:**
   ```bash
   node _scripts/durcharbeiten-register.cjs "<session_id>" "<Aufgabenbeschreibung>" "<Minuten>"
   ```

6. **Kuerze die Aufgabe auf max. 6 Woerter** fuer den Tab-Titel.

7. **Starte den Fork-Tab (mit Env-Variable fuer Session-Zuordnung):**
   ```bash
   wt.exe --window new -p "Sage Fork" --title "Sage: <Aufgabe gekuerzt>" -d "%USERPROFILE%\Sage" -- "C:/Program Files/Git/bin/bash.exe" -c "DURCHARBEITEN_SESSION=<session_id> claude '/durcharbeiten $ARGUMENTS'" &
   ```

8. Bestaetige: "Fork gestartet: **<Aufgabe>** ([Zeitlimit]). Dashboard: mobile-sage.de/durcharbeiten.html" -- **FERTIG. Dieser Tab ist frei.**

---

**WORKER-MODUS (ab Schritt 9):**

9. Lies die State-Datei: `.claude/durcharbeiten-$DURCHARBEITEN_SESSION.state` (aus Env-Variable) fuer session_id, task, limit_minutes etc.
   Setze den Terminal-Fenstertitel: `printf '\033]0;Sage: <Aufgabe gekuerzt auf 6 Woerter>\007'`
   Bestaetige: "Durcharbeiten: [Zeitlimit] fuer [Aufgabe]. Dashboard: mobile-sage.de/durcharbeiten.html"

10. **Subagent-Analyse (PFLICHT vor Arbeitsbeginn):**
    Lies `_skills/subagent.md` -- dort steht wie Subagents funktionieren, gestartet und koordiniert werden.
    - Zerlege die Aufgabe in Teilaufgaben
    - **Default ist Subagent.** Jede Teilaufgabe die Dateien lesen, Code schreiben oder mehrere Tool-Calls braucht, gehoert in einen Subagent -- auch wenn sie nicht parallelisierbar ist. Der Kontext wird im Subagent-Fenster verbraucht, nicht im Haupttab
    - **Ausnahme:** Nur Aufgaben die staendigen Dialog oder Koordination ZWISCHEN Teilaufgaben brauchen, bleiben im Haupttab

11. **Arbeitsablauf:**
    - Arbeite die Aufgabe ab (direkt oder ueber Subagents)
    - Sende Heartbeats waehrend der Arbeit (alle ~3 Min oder bei Meilensteinen):
      ```bash
      node _scripts/durcharbeiten-heartbeat.cjs "<session_id>" "Was ich gerade mache" "Fortschritt"
      ```
    - **Nach jedem abgeschlossenen Arbeitspaket:** Pruefe auf Pitts Input:
      ```bash
      node _scripts/poll-durcharbeiten.cjs "" "<session_id>"
      ```
      Wenn Input da: ausfuehren. Wenn nicht: naechstes Paket.
    - Wenn fertig: `<fertig>Zusammenfassung</fertig>`

12. **Am Ende der Session:**
    ```bash
    node _scripts/notify-durcharbeiten.cjs "Fertig" "Zusammenfassung" "Aufgabe" "<session_id>"
    node _scripts/durcharbeiten-end.cjs "<session_id>" "Zusammenfassung"
    ```
    - `.claude/durcharbeiten-<session_id>.state` loeschen
