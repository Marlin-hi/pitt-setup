# Pitts zweites Gehirn -- Setup (Windows PowerShell)
# Run: irm https://raw.githubusercontent.com/Marlin-hi/pitt-setup/main/setup.ps1 | iex

$ErrorActionPreference = "Stop"

$STEPS = 5
function Write-Step($n, $text) {
    $pct = [math]::Round(($n - 1) / $STEPS * 100)
    $filled = [math]::Round($pct / 5)
    $empty = 20 - $filled
    $bar = ("$([char]0x2588)" * $filled) + ("$([char]0x2591)" * $empty)
    Write-Host ""
    Write-Host "  $bar  $pct%" -ForegroundColor DarkCyan
    Write-Host "  ==> $n/$STEPS $text" -ForegroundColor Cyan
}
function Write-Ok($text) { Write-Host "  [OK]   $text" -ForegroundColor Green }
function Write-Warn($text) { Write-Host "  [WARN] $text" -ForegroundColor Yellow }
function Write-Fail($text) { Write-Host "  [FAIL] $text" -ForegroundColor Red; exit 1 }
function Write-Done() {
    $bar = "$([char]0x2588)" * 20
    Write-Host ""
    Write-Host "  $bar  100%" -ForegroundColor Green
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Zweites Gehirn -- Setup" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Obsidian + Claude Code + Git" -ForegroundColor Gray
Write-Host ""

$VaultName = Read-Host "  Wie soll dein Vault heissen? (z.B. Pitt, Notizen, Brain)"
if ([string]::IsNullOrWhiteSpace($VaultName)) { $VaultName = "Vault" }
$VaultName = $VaultName.Trim()
$VaultDir = "$HOME\$VaultName"

# ---- 1. Node.js ----
Write-Step 1 "Node.js"

if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Ok "Node.js $(node --version)"
} else {
    Write-Host "  Installiere Node.js..." -ForegroundColor Yellow
    try {
        winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements 2>$null
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    } catch {}
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Write-Fail "Node.js konnte nicht installiert werden. Bitte manuell von https://nodejs.org installieren."
    }
    Write-Ok "Node.js installiert"
}

# ---- 2. Git ----
Write-Step 2 "Git"

if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Ok "Git $(git --version)"
} else {
    Write-Host "  Installiere Git..." -ForegroundColor Yellow
    try {
        winget install Git.Git --accept-package-agreements --accept-source-agreements 2>$null
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    } catch {}
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Fail "Git konnte nicht installiert werden. Bitte manuell von https://git-scm.com installieren."
    }
    Write-Ok "Git installiert"
}

# ---- 3. Claude Code ----
Write-Step 3 "Claude Code"

if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Ok "Claude Code bereits installiert"
} else {
    Write-Host "  Installiere Claude Code..." -ForegroundColor Blue
    $installerPath = "$env:TEMP\claude-install.ps1"
    Invoke-WebRequest -Uri "https://claude.ai/install.ps1" -OutFile $installerPath -UseBasicParsing
    & powershell -ExecutionPolicy Bypass -File $installerPath
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    if (Test-Path "$HOME\.local\bin\claude.exe") { $env:Path = "$HOME\.local\bin;" + $env:Path }
    if (Test-Path "$env:LOCALAPPDATA\Programs\claude-code\claude.exe") { $env:Path = "$env:LOCALAPPDATA\Programs\claude-code;" + $env:Path }
    # PATH persistent setzen
    $claudePath = $null
    if (Test-Path "$HOME\.local\bin\claude.exe") { $claudePath = "$HOME\.local\bin" }
    elseif (Test-Path "$env:LOCALAPPDATA\Programs\claude-code\claude.exe") { $claudePath = "$env:LOCALAPPDATA\Programs\claude-code" }
    if ($claudePath) {
        $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        if ($userPath -notlike "*$claudePath*") {
            [System.Environment]::SetEnvironmentVariable("Path", "$userPath;$claudePath", "User")
        }
        $env:Path = "$claudePath;" + $env:Path
        Write-Ok "Claude Code installiert"
    } else {
        Write-Warn "Claude Code installiert, aber nicht im PATH. PowerShell neu starten nach dem Setup."
    }
}

# ---- 4. Obsidian ----
Write-Step 4 "Obsidian"

$obsidianInstalled = (Get-Command obsidian -ErrorAction SilentlyContinue) -or
    (Test-Path "$env:LOCALAPPDATA\Obsidian\Obsidian.exe") -or
    (Test-Path "$env:PROGRAMFILES\Obsidian\Obsidian.exe")

if ($obsidianInstalled) {
    Write-Ok "Obsidian bereits installiert"
} else {
    Write-Host "  Installiere Obsidian..." -ForegroundColor Yellow
    $ErrorActionPreference = "Continue"
    winget install Obsidian.Obsidian --accept-package-agreements --accept-source-agreements 2>$null
    $ErrorActionPreference = "Stop"
    Write-Ok "Obsidian installiert"
}

# ---- 5. Vault anlegen ----
Write-Step 5 "Vault anlegen"

if (Test-Path $VaultDir) {
    Write-Warn "Ordner existiert bereits: $VaultDir"
} else {
    New-Item -ItemType Directory -Path $VaultDir -Force | Out-Null
    Write-Ok "Vault-Ordner erstellt: $VaultDir"
}

# Git init
Push-Location $VaultDir
if (-not (Test-Path ".git")) {
    git init 2>$null
    Write-Ok "Git initialisiert"
} else {
    Write-Ok "Git bereits initialisiert"
}

# Git user config setzen falls noch nicht vorhanden
$gitUserName = git config user.name 2>$null
if (-not $gitUserName) {
    git config user.name $VaultName
    git config user.email "$($VaultName.ToLower())@local"
    Write-Ok "Git User konfiguriert: $VaultName"
}

# Erste Notiz
$welcomePath = "$VaultDir\Willkommen.md"
if (-not (Test-Path $welcomePath)) {
    @"
# Willkommen

Das ist dein Vault. Hier sammelst du alles was dir wichtig ist.

## Wie es funktioniert

- **Obsidian** ist dein Editor. Oeffne diesen Ordner als Vault in Obsidian
- **Claude Code** ist deine KI im Terminal. Starte es mit ``claude`` in diesem Ordner
- **Markdown** (.md Dateien) sind einfache Textdateien. Sie gehoeren dir

## Erste Schritte

- Schreib einfach drauflos
- Verlinke Notizen mit ``[[Doppelte Klammern]]``
- Frag Claude Code wenn du Hilfe brauchst
"@ | Out-File -FilePath $welcomePath -Encoding utf8
    Write-Ok "Erste Notiz erstellt: Willkommen.md"
}

# .gitignore
$gitignorePath = "$VaultDir\.gitignore"
if (-not (Test-Path $gitignorePath)) {
    @"
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.trash/
"@ | Out-File -FilePath $gitignorePath -Encoding utf8
}

# Initial commit
$ErrorActionPreference = "Continue"
$hasCommits = git log --oneline -1 2>$null
if (-not $hasCommits) {
    git add -A 2>$null
    git commit -m "Vault angelegt" 2>$null
    Write-Ok "Erster Commit erstellt"
}
$ErrorActionPreference = "Stop"
Pop-Location

Write-Done

# ---- Desktop Shortcut ----
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  Fertig!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Vault: $VaultDir" -ForegroundColor Blue
Write-Host ""

$createShortcut = Read-Host "  Desktop-Shortcut fuer Claude Code erstellen? (j/n)"
if ($createShortcut -eq "j" -or $createShortcut -eq "y") {
    $ErrorActionPreference = "Continue"
    $shell = New-Object -ComObject WScript.Shell

    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $desktopLnk = $shell.CreateShortcut("$desktopPath\$VaultName.lnk")
    $desktopLnk.TargetPath = "powershell.exe"
    $desktopLnk.Arguments = "-NoExit -Command `"cd '$VaultDir'; claude`""
    $desktopLnk.WorkingDirectory = $VaultDir
    $desktopLnk.Description = "$VaultName -- Claude Code"
    $desktopLnk.Save()
    Write-Ok "Desktop-Shortcut erstellt"

    $startMenuDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
    $startLnk = $shell.CreateShortcut("$startMenuDir\$VaultName.lnk")
    $startLnk.TargetPath = "powershell.exe"
    $startLnk.Arguments = "-NoExit -Command `"cd '$VaultDir'; claude`""
    $startLnk.WorkingDirectory = $VaultDir
    $startLnk.Description = "$VaultName -- Claude Code"
    $startLnk.Save()
    Write-Ok "Startmenue-Shortcut erstellt (Windows-Taste -> $VaultName)"
    $ErrorActionPreference = "Stop"
}

Write-Host ""
Write-Host "  Naechste Schritte:" -ForegroundColor Yellow
Write-Host ""
Write-Host "    1. Obsidian oeffnen -> '$VaultDir' als Vault oeffnen" -ForegroundColor White
Write-Host "    2. PowerShell oeffnen:" -ForegroundColor White
Write-Host "       cd $VaultDir" -ForegroundColor Cyan
Write-Host "       claude" -ForegroundColor Cyan
Write-Host ""
