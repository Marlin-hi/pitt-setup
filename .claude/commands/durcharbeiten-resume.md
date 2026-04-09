Setze eine pausierte Durcharbeiten-Session fort.

Argumente: $ARGUMENTS (optional: Anpassungen an der Aufgabe)

Anweisungen:
1. Lies die aktive State-Datei (`.claude/durcharbeiten-<session_id>.state`, gefunden ueber `$DURCHARBEITEN_SESSION` oder Scan). Wenn `paused=true`:
   - Lies die zugehoerige Uebergabe
   - Berechne die verbleibende Zeit aus `remaining_minutes`
   - Setze `paused=false`, aktualisiere `start_time` auf jetzt, `limit_minutes` auf die verbleibende Zeit
2. Wenn keine pausierte Session: Melde "Keine pausierte Session gefunden."
3. Zeige Zusammenfassung:
   - Urspruengliche Aufgabe
   - Was bisher erledigt wurde
   - Was als Naechstes ansteht
   - Verbleibende Zeit
4. Bestaetige: "Session fortgesetzt. [X] Minuten verbleiben. Naechster Schritt: [was ansteht]"
5. Arbeite weiter wie im Original-Modus (durcharbeiten oder durcharbeiten-plus).
