# Skill: Forks

**Wann**: Wenn ein Thema einen eigenen Tab braucht -- abgezweigt aus einer laufenden Konversation.

## Wann Forks nutzen

- Wenn in einer Konversation ein Problem auftaucht, das in einem eigenen Tab geloest werden soll
- Wenn ein Sprint mehrere unabhaengige Items hat, die parallel abgearbeitet werden koennen
- Wenn ein Thema zu gross wird und einen eigenen Fokus braucht

## Fork erstellen (im Ursprungs-Tab)

1. Pitt sagt "fork das" (oder "fork Item X")
2. Sage erstellt ein Briefing in `_forks/fork-name.md` (name = ein Wort das das Problem sofort erkennen laesst, z.B. `fork-links`, `fork-workout`, `fork-hydro`):

```markdown
---
created: YYYY-MM-DDTHH:MM
status: offen
origin: tab-XXXX
---

# Fork: Titel

## Kontext
Zusammenfassung: wo stehen wir, was ist der Hintergrund.

## Aufgabe
Was konkret zu tun ist.

## Relevante Dateien
- Datei 1
- Datei 2

## Ergebnis
_(wird vom Fork-Tab ausgefuellt)_
```

3. Commit + Push (damit der neue Tab es sieht)

## Fork-Tab starten

### Option A: Sage startet den Fork (sichtbares Fenster)

Sage kann Forks direkt als eigene Terminal-Fenster starten -- gruenes "Sage Fork"-Profil mit Acrylic-Effekt.

```bash
wt.exe --window new -p "Sage Fork" --title "Fork: fork-name" -- "C:/Program Files/Git/bin/bash.exe" --login "/c/Users/qbk/Sage/_scripts/launch-fork.sh" "fork-name" &
```

Das Launch-Script (`_scripts/launch-fork.sh`) startet eine interaktive Claude-Session im Vault mit `fork-name` als erster Nachricht. Pitt kann danach ganz normal weiterarbeiten -- Permissions bestaetigen, reinschauen, eingreifen.

### Option B: Pitt startet den Fork (manuell)

Pitt oeffnet einen neuen Tab und sagt: **"fork-name"**

### In beiden Faellen

Der Tab erkennt das (erste Nachricht beginnt mit `fork-`) und:
1. Liest `_forks/fork-name.md` statt normales Onboarding
2. Liest trotzdem `_arbeit.md` (Dateikonflikte vermeiden)
3. Erstellt Worktree, traegt sich in `_arbeit.md` ein -- wie ueblich
4. Arbeitet die Aufgabe ab

## Visuelle Pruefung (bei Webseiten-Arbeit)

Wenn der Fork an einer Webseite arbeitet: **vor dem Abschluss visuell pruefen.**

Nutze das Playwright-MCP oder ein Screenshot-Tool um das Ergebnis visuell zu verifizieren. Mach das mindestens einmal vor dem Abschluss -- nur "Build erfolgreich" reicht bei visuellen Aenderungen nicht.

## Fork abschliessen

1. Fork-Tab schreibt eine kurze Ergebnis-Notiz in die Fork-Datei (## Ergebnis ausfuellen)
2. Status auf `erledigt` setzen
3. Merge + Push wie ueblich
4. Pitt meldet im Ursprungs-Tab: "fork-XXXX ist fertig"
5. Ursprungs-Tab **verifiziert** das Ergebnis (siehe unten)

### Automatischer Abschluss (Durcharbeiten-Modus)

Wenn ein Fork waehrend einer aktiven Durcharbeiten-Session gestartet wird, ergaenzt der Ursprungs-Tab im Briefing:

```markdown
## Modus
Durcharbeiten -- schliesse dich nach Erledigung selbst ab (Ergebnis schreiben, Status erledigt, Merge + Push, Session beenden). Nicht auf Pitt warten.
```

Der Fork fuehrt dann Schritte 1-3 eigenstaendig aus und beendet seine Session.

## Verifikation (Ursprungs-Tab)

Wenn ein Fork als fertig gemeldet wird, prueft der Ursprungs-Tab **bevor er abhakt**:

1. **Ergebnis lesen**: Fork-Datei oeffnen, ## Ergebnis lesen
2. **Drei Prueffragen**:
   - **Ziel erreicht?** -- Hat der Fork die Aufgabe aus dem Briefing tatsaechlich geloest?
   - **Vollstaendig?** -- Fehlt etwas Wesentliches, das im Briefing stand aber im Ergebnis nicht auftaucht?
   - **Konsistent?** -- Passt das Ergebnis zum Rest des Vaults (keine Widersprueche, Links korrekt)?
3. **Entscheidung**:
   - Alles gut -> abhaken, weiter
   - Luecke gefunden -> Pitt informieren, ggf. neuen Fork oder Nacharbeit
   - Widerspruch -> Pitt fragen welche Version gilt

Verifikation soll kurz sein -- keine Audit-Buerokratie. Drei Fragen, ehrliche Antwort, fertig.

## Worker-Briefings

Manche Projekte haben ein **Worker-Briefing** statt einzelner Fork-Briefings.

- Pitt oeffnet einen Tab und sagt: **"worker: [Feature-Beschreibung]"**
- Der Tab liest das Worker-Briefing
- Der Tab kennt damit die gesamte Architektur und Koordinationsregeln
- Das Feature wird direkt aus Pitts Nachricht entnommen, kein separates Briefing noetig
- Am Ende: kein Ergebnis in die Worker-Datei schreiben (die ist ein Template), nur `_arbeit.md` aufraeumen

## Terminal-Profil

- **Name:** Sage Fork
- **Design:** Gruen (Sage Fork Color Scheme), Acrylic, Hintergrund
- **Tab-Titel:** Wird dynamisch gesetzt per `--title "Fork: name"`
- **Launch-Script:** `_scripts/launch-fork.sh`

## Unterschied zum normalen Tab-Start

|  | Normaler Tab | Fork-Tab |
|---|---|---|
| Erste Nachricht | Frei | "fork-name" |
| Onboarding | Normales Onboarding, Aufgabe waehlen | Fork-Briefing lesen, Aufgabe steht fest |
| `_arbeit.md` | Ja | Ja |
| Worktree | Ja | Ja |
| Am Ende | Normales Wrap-up | Ergebnis in Fork-Datei schreiben |

## Archiv

Erledigte Forks werden nach `_forks/_archiv/` verschoben. Kriterien:
- Fork ist abgeschlossen (Ergebnis liegt vor oder wurde verworfen)
- Aelter als 2 Wochen ohne Aktivitaet

Convention: Nach Abschluss eines Forks -> `git mv _forks/fork-name.md _forks/_archiv/`
