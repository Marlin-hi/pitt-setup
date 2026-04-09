#!/bin/bash
FORK_NAME="$1"
if [ -z "$FORK_NAME" ]; then echo "Fehler: Kein Fork-Name angegeben."; echo "Usage: launch-fork.sh <fork-name>"; exit 1; fi
MSG="Du bist als Fork-Tab gestartet. Lies _forks/${FORK_NAME}.md und arbeite es ab."
wt.exe -w 0 nt -p "Sage Fork" -- "$HOME/Sage/_scripts/fork-launcher.bat" "$MSG"
