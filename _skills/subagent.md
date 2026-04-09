# Subagent -- Sichtbare autonome Fenster

Sage kann autonome Claude-Instanzen in eigenen Terminal-Fenstern starten. Jeder Subagent arbeitet in einem violetten "Sage Subagent"-Fenster, sichtbar fuer Pitt.

## Wann Subagents nutzen

**Default ist Subagent.** Jede Aufgabe die Dateien lesen, Code schreiben oder mehrere Tool-Calls braucht, gehoert in einen Subagent. Der Hauptgrund ist nicht nur Parallelisierung, sondern **Kontext-Minimierung**: Der Kontext wird im Subagent-Fenster verbraucht, nicht im Haupttab.

**Entscheidungsregel:** Subagent, wenn Briefing + Ergebnisbericht weniger Kontext verbraucht als die Aufgabe selbst im Haupttab.

**Ausnahme:** Nur Aufgaben die staendigen Dialog oder Koordination ZWISCHEN Teilaufgaben brauchen, bleiben im Haupttab.

### Im Durcharbeiten-Modus

`/durcharbeiten` und `/durcharbeiten-plus` starten Subagents eigenstaendig -- die Subagent-Analyse ist Pflichtschritt vor Arbeitsbeginn. Der Haupttab wird zum Orchestrator: briefen, warten, Ergebnisse lesen, koordinieren.

## Zwei Subagent-Typen

### 1. Terminal-Subagents (wt.exe + subagent-launch.sh)

Eigene Terminal-Fenster (violett). Sichtbar fuer Pitt, intervenierbar. Voller TUI mit Live-Streaming.

**Wann:** Externe Projekt-Repos die eigene Worktrees brauchen, eigenes CLAUDE.md haben und wo Pitt den Fortschritt live sehen oder eingreifen will.

### 2. Interne Agents (Agent-Tool mit isolation: "worktree")

Claude Codes eingebautes Agent-Tool. Laufen im Hintergrund des Haupttabs, Ergebnisse kommen als Nachricht zurueck.

**Wann:** Aufgaben die im selben Repo wie der Haupttab stattfinden, keine eigene TUI brauchen und wo das Ergebnis (nicht der Prozess) zaehlt. Gut fuer parallele Recherche, File-Generierung, oder viele kleine unabhaengige Aufgaben.

**Wichtig:** `isolation: "worktree"` nutzen wenn der Agent Dateien schreibt -- das gibt ihm eine eigene Repo-Kopie und schuetzt master.

### Entscheidung

| Kriterium | Terminal-Subagent | Interner Agent |
|---|---|---|
| **Repo** | Externes Projekt-Repo | Gleiches Repo wie Haupttab |
| **Sichtbarkeit** | Eigenes Fenster, live sichtbar | Im Hintergrund, nur Ergebnis |
| **Intervention** | Pitt kann reintippen | Nicht moeglich |
| **Worktree** | Manuell via subagent-launch.sh | `isolation: "worktree"` |
| **Auto-Merge** | Ja (subagent-launch.sh merged nach master) | Nein (Worktree bleibt, manuell mergen) |
| **Signaling** | Signal-Datei fuer Dispatcher | Agent-Tool meldet Abschluss |

## Regeln

- **Richtigen Subagent-Typ waehlen** -- siehe Tabelle oben
- Fuer reines File-Writing und Recherche: `general-purpose`. GSD-Agents (`gsd-executor` etc.) nur wenn eine GSD-Roadmap/Phase existiert

## Terminal-Subagents: Wie es funktioniert

### Vorbereitung (Sage macht das)

1. **Projekt aufsetzen** -- Repo, CLAUDE.md mit komplettem Bauplan
2. **CLAUDE.md muss alles enthalten** -- der Subagent hat keinen Kontext ausser was in CLAUDE.md und den Projektdateien steht
3. **Reihenfolge definieren** -- nummerierte Schritte, jeder mit Build-Test
4. **"Aktueller Stand" Sektion** -- damit ein neuer Subagent weitermachen kann wo der letzte aufgehoert hat

### Permissions

Das Projekt braucht eine `.claude/settings.local.json` die alle noetigen Tools erlaubt:

```json
{
  "permissions": {
    "allow": ["Bash(*)", "Edit", "Write", "Read", "Glob", "Grep", "WebFetch", "WebSearch", "NotebookEdit", "Agent"]
  }
}
```

Damit laeuft der Subagent ohne Permission-Prompts durch. Kein `--dangerously-skip-permissions` noetig.

### Start

Subagents werden ueber ein Launch-Script gestartet -- `wt.exe` kann keine komplexen Inline-Commands zuverlaessig parsen.

**WICHTIG: Subagents arbeiten IMMER in Worktrees, nie direkt auf master.** Das zentrale Script `_scripts/subagent-launch.sh` kuemmert sich um alles: Worktree erstellen, Claude starten, nach Abschluss auf master mergen, Worktree aufraeumen, Signal senden.

**Pattern:** Projekt braucht ein `launch-agent.sh` im Root:

```bash
#!/bin/bash
# Wrapper -- delegiert an das zentrale Subagent-Script
/c/Users/qbk/Sage/_scripts/subagent-launch.sh \
  /c/Users/qbk/pfad/zum/projekt \
  aufgabenname \
  agent-prompt.txt \
  signal-name
```

Parameter-Details und Ablauf stehen direkt im Script-Header von `_scripts/subagent-launch.sh`.

Dazu `agent-prompt.txt` mit dem Prompt (z.B. "Lies CLAUDE.md und arbeite alle Schritte ab.").

**Agent-Prompts: Keine Setup-Sektion mehr noetig.** Der Agent befindet sich bereits im Worktree mit funktionierenden Symlinks. Er muss nur noch seine Aufgabe erledigen und committen.

**Jeder Prompt muss am Ende diese Anweisung enthalten:**

```
Wenn du komplett fertig bist, schreibe als allerletzte Nachricht exakt:

=== SUBAGENT FERTIG ===
```

**Verhalten:** Normaler interaktiver Modus. Voller TUI mit Live-Streaming. Laeuft autonom durch, Pitt kann jederzeit intervenieren (reintippen), muss aber nicht.

**Start-Command:**

```bash
wt.exe --window new -p "Sage Subagent" --title "Aufgabentitel" -- "C:/Program Files/Git/bin/bash.exe" --login "/c/Users/qbk/pfad/zum/projekt/launch-agent.sh" &
```

**Wichtig:**
- `unset CLAUDECODE` wird von `subagent-launch.sh` gesetzt
- `export SAGE_SUBAGENT=1` wird von `subagent-launch.sh` gesetzt -- aktiviert den Stop-Hook, der verhindert dass der Agent vorzeitig stoppt
- `.worktrees/` muss in der `.gitignore` des Projekts stehen

### Kontext-Management

- Jeder Subagent hat einen **frischen 200k-Kontext** -- kein Context Rot
- Der State liegt in **CLAUDE.md** (Sektion "Aktueller Stand"), nicht im Chat
- Wenn der Kontext voll wird oder der Subagent fertig ist: neuen Subagent starten, der CLAUDE.md liest und weitermacht
- **Commits nach jedem Schritt** sichern den Fortschritt (auf dem Worktree-Branch, nicht master)

## Terminal-Profil

- **Name:** Sage Subagent
- **Design:** Violett (Sage Violet Color Scheme), Acrylic, Hintergrund
- **Tab-Titel:** Wird dynamisch gesetzt per `--title "Aufgabe"`

## Abgrenzung zu Forks

| | Fork | Subagent |
|---|---|---|
| **Modus** | Interaktiv -- erwartet Pitts Input | Autonom -- laeuft durch, Pitt kann intervenieren |
| **Scope** | Aufgaben die Pitts Entscheidungen brauchen | Jede Aufgabe die autonom abarbeitbar ist (klein bis gross) |
| **Zweck** | Dialog mit Pitt | Kontext-Minimierung + Parallelisierung |
| **State** | Fork-Briefing in `_forks/` | CLAUDE.md im Projekt-Repo oder agent-prompt.txt |
| **Erlaubnis** | Nur mit Pitts OK | Sage darf eigenstaendig starten |
| **Design** | Gruen Acrylic, Hintergrund | Violett Acrylic, Hintergrund |

## Dispatcher

Am Session-Start kann Sage einen Dispatcher-Fork starten. Der Dispatcher:

1. Scannt Projekte nach offener Arbeit
2. Legt Pitt eine Liste vor
3. Startet genehmigte Aufgaben als Subagents (mehrere parallel moeglich)
4. Ueberwacht Fortschritt, startet naechste wenn einer fertig ist
5. Meldet Gesamtergebnis

**Start:** Sage launcht den Dispatcher im goldenen Fenster (Profil "Sage Dispatcher", Hintergrund).

```bash
wt.exe --window new -p "Sage Dispatcher" --title "Dispatcher" -- "C:/Program Files/Git/bin/bash.exe" --login "/c/Users/qbk/Sage/_scripts/launch-dispatcher.sh" &
```

## Checkliste vor Start (Terminal-Subagents)

- [ ] Projekt-Repo existiert mit CLAUDE.md
- [ ] CLAUDE.md enthaelt kompletten Bauplan mit Reihenfolge
- [ ] CLAUDE.md hat "Aktueller Stand" Sektion
- [ ] `.claude/settings.local.json` mit erlaubten Tools
- [ ] `.worktrees/` in `.gitignore` des Projekts
- [ ] Dependencies sind installiert
