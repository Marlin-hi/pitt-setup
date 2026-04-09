---
status: active
type: fork
---

# Fork: Bridge Poll

## Auftrag

Polle dauerhaft den Bridge-Channel und zeige Pitt was reinkommt. Dieser Tab laeuft unabhaengig vom Haupttab.

## Konfiguration

- **Channel:** pitt
- **URL:** https://bridge.hylox.org
- **Token:** ef095bae2d81d8dc86e0b477a9fa963c
- **Agent-Name:** sage

## Poll-Loop

Fuehre diesen Befehl endlos in einer Schleife aus:

```bash
curl -s "https://bridge.hylox.org/channel/pitt?since=LAST_MSG_ID" -H "Authorization: Bearer ef095bae2d81d8dc86e0b477a9fa963c"
```

- `LAST_MSG_ID` = ID der letzten empfangenen Nachricht (beim ersten Mal weglassen)
- Server haelt 30s offen (Long-Poll), dann erneut pollen
- Bei Fehlern: 5s warten, weiter pollen

## Senden

```bash
curl -s -X POST "https://bridge.hylox.org/channel/pitt" -H "Authorization: Bearer ef095bae2d81d8dc86e0b477a9fa963c" -H "Content-Type: application/json" -d '{"from":"sage","text":"NACHRICHT"}'
```

## Beim Start

Sofort senden: `{"from":"sage","text":"Online. Bridge-Poll laeuft."}`

## Bei eingehenden Nachrichten

- Anzeigen (Absender + Text)
- Wenn eine Aufgabe reinkommt: Pitt erklaeren was Mika will
- Wenn Pitt antworten will: ueber die Bridge senden
- Wenn ein vault-update kommt: `git pull --rebase` ausfuehren

## Wichtig

- **Nie stoppen.** Auch nicht bei Fehlern.
- **Nie auf Input warten** waehrend du pollst.
- Dieser Tab ist NUR fuer die Bridge. Keine andere Arbeit hier.
