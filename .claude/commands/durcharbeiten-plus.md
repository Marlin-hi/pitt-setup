Aktiviere den Durcharbeiten-Plus-Modus -- baut UND poliert bis die Zeit um ist, kommuniziert ueber mobile-sage.

Argumente: $ARGUMENTS (Format: "Zeitlimit Aufgabenbeschreibung", z.B. "3h Showcase polieren")

Wie `/durcharbeiten`, aber mit erzwungener Polish-Phase und kein vorzeitiges Aufhoeren.

**Dashboard:** `https://mobile-sage.de/durcharbeiten.html`

Anweisungen:

1. Parse das erste Argument als Zeitlimit (z.B. "30m", "1h", "3h"). Default: 1h. Der Rest ist die Aufgabenbeschreibung.
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
mode=plus
polishing=false
last_checkup=0
launched=true
```

5. **Registriere die Session beim Dashboard:**
   ```bash
   node _scripts/durcharbeiten-register.cjs "<session_id>" "<Aufgabenbeschreibung>" "<Minuten>"
   ```

6. **Kuerze die Aufgabe auf max. 6 Woerter** fuer den Tab-Titel.

7. **Starte den Fork-Tab (mit Env-Variable fuer Session-Zuordnung):**
   ```bash
   wt.exe --window new -p "Sage Fork" --title "Sage: <Aufgabe gekuerzt>" -d "%USERPROFILE%\Sage" -- "C:/Program Files/Git/bin/bash.exe" -c "DURCHARBEITEN_SESSION=<session_id> claude '/durcharbeiten-plus $ARGUMENTS'" &
   ```

8. Bestaetige: "Fork gestartet: **<Aufgabe>** ([Zeitlimit]). Dashboard: mobile-sage.de/durcharbeiten.html" -- **FERTIG. Dieser Tab ist frei.**

---

**WORKER-MODUS (ab Schritt 9):**

9. Lies die State-Datei: `.claude/durcharbeiten-$DURCHARBEITEN_SESSION.state` (aus Env-Variable) fuer session_id, task, limit_minutes etc.
   Setze den Terminal-Fenstertitel: `printf '\033]0;Sage: <Aufgabe gekuerzt auf 6 Woerter>\007'`
   Bestaetige: "Durcharbeiten-Plus: [Zeitlimit] fuer [Aufgabe]. Dashboard: mobile-sage.de/durcharbeiten.html"

10. **Subagent-Analyse (PFLICHT vor Arbeitsbeginn):**
    Lies `_skills/subagent.md` -- dort steht wie Subagents funktionieren, gestartet und koordiniert werden.
    - Zerlege die Aufgabe in Teilaufgaben
    - **Default ist Subagent.** Jede Teilaufgabe die Dateien lesen, Code schreiben oder mehrere Tool-Calls braucht, gehoert in einen Subagent -- auch wenn sie nicht parallelisierbar ist. Der Kontext wird im Subagent-Fenster verbraucht, nicht im Haupttab
    - **Ausnahme:** Nur Aufgaben die staendigen Dialog oder Koordination ZWISCHEN Teilaufgaben brauchen, bleiben im Haupttab

11. **Zwei-Phasen-Ablauf pro Modul:**

    **Phase 1 -- Bauen:**
    - Arbeite die Aufgabe ab (direkt oder ueber Subagents)
    - Sende Heartbeats (alle ~3 Min oder bei Meilensteinen):
      ```bash
      node _scripts/durcharbeiten-heartbeat.cjs "<session_id>" "Was ich gerade mache" "Fortschritt"
      ```
    - **Nach jedem abgeschlossenen Arbeitspaket:** Pruefe auf Pitts Input:
      ```bash
      node _scripts/poll-durcharbeiten.cjs "" "<session_id>"
      ```
      Wenn Input da: ausfuehren. Wenn nicht: naechstes Paket.
    - Wenn fertig: `<fertig>Was ich gebaut habe</fertig>`
    - Der Hook blockiert und startet Phase 2

    **Phase 2 -- Polieren:**
    - Der Hook gibt dir eine Validierungs-Checkliste:
      - Visuell geprueft (Screenshot-Tool)
      - Alle Links/Buttons funktionieren
      - Mobile-Viewport (375x812)
      - Keine Console-Errors
      - Texte auf Tippfehler
      - Theme/Design konsistent
      - Ladezeit akzeptabel
      - Edge Cases (leere Daten, lange Texte)
    - Finde und fixe Probleme
    - Wenn ALLES sauber: `<poliert>Zusammenfassung</poliert>`
    - Erst dann laesst der Hook dich durch

12. **NICHT VOR DER ZEIT AUFHOEREN.** Du arbeitest die volle Zeit ab, Punkt.
    - Pruefe: Kann etwas besser sein? Komplett neu bauen wenn noetig.
    - Pruefe: Gibt es Nebenbereiche, die profitieren?
    - Zeitcheck: `node _scripts/durcharbeiten-timecheck.cjs`

13. **Am Ende der Session:**
    ```bash
    node _scripts/notify-durcharbeiten.cjs "Fertig" "Zusammenfassung" "Aufgabe" "<session_id>"
    node _scripts/durcharbeiten-end.cjs "<session_id>" "Zusammenfassung"
    ```
    - `.claude/durcharbeiten-<session_id>.state` loeschen
