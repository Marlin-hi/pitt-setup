# Bridge-Tab starten -- oeffnet einen neuen Windows Terminal Tab mit dem Bridge-Poll
$VaultDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$msg = "Du bist als Fork-Tab gestartet. Lies _forks/bridge-poll.md und arbeite es ab."
$gitBash = "C:\Program Files\Git\bin\bash.exe"
wt.exe -w 0 nt --title "Bridge" -p "Sage Fork" -- $gitBash --login -c "cd '$VaultDir' && claude '$msg'"
