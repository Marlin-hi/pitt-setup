Pausiere die aktuelle Durcharbeiten-Session sauber.

Argumente: $ARGUMENTS (optional: Grund fuer die Pause)

Anweisungen:
1. Lies die aktive State-Datei (`.claude/durcharbeiten-<session_id>.state`, gefunden ueber `$DURCHARBEITEN_SESSION` oder Scan). Wenn keine aktive Session: Melde "Keine aktive Durcharbeiten-Session."
2. Berechne die verstrichene Zeit und verbleibende Zeit.
3. Erstelle eine Uebergabe in `Uebergaben/` mit:
   - Was bisher erledigt wurde
   - Was als Naechstes ansteht
   - Offene Fragen oder Blocker
   - Verbleibende Zeit
4. Aktualisiere die State-Datei:
   - Setze `paused=true`
   - Setze `paused_at=<Unix-Timestamp>`
   - Setze `remaining_minutes=<verbleibende Minuten>`
5. Committe alle offenen Aenderungen.
6. Bestaetige: "Session pausiert. [X] Minuten verbleiben. Uebergabe: [Dateiname]"
7. Beende die Session NICHT -- Pitt entscheidet wann der Tab geschlossen wird.
