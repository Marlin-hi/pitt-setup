# Sage Terminal Setup Script
# Run ONCE to install Windows Terminal profiles and color schemes for Sage.
# Usage: powershell -ExecutionPolicy Bypass -File setup-terminal.ps1

$ErrorActionPreference = "Stop"

# Find Windows Terminal settings.json
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (-not (Test-Path $settingsPath)) {
    # Try Windows Terminal Preview
    $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
}
if (-not (Test-Path $settingsPath)) {
    # Try unpackaged installation
    $settingsPath = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
}
if (-not (Test-Path $settingsPath)) {
    Write-Error "Windows Terminal settings.json nicht gefunden. Ist Windows Terminal installiert?"
    exit 1
}

Write-Host "Windows Terminal settings.json gefunden: $settingsPath"

# Backup
$backupPath = "$settingsPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Copy-Item $settingsPath $backupPath
Write-Host "Backup erstellt: $backupPath"

# Read current settings
$settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

# --- COLOR SCHEMES ---

$colorSchemes = @(
    @{
        name = "Sage Fork"
        background = "#0A1E14"
        foreground = "#DCF0E8"
        cursorColor = "#84FCC0"
        selectionBackground = "#3AED7C"
        black = "#0A1E14"
        blue = "#8CF8C1"
        brightBlack = "#1D4C3A"
        brightBlue = "#B4FCD5"
        brightCyan = "#8BFAA7"
        brightGreen = "#B5FDC4"
        brightPurple = "#D5FFE9"
        brightRed = "#FDA4AF"
        brightWhite = "#F3FFF5"
        brightYellow = "#FDE68A"
        cyan = "#5CF68B"
        green = "#78FAA7"
        purple = "#84FCC0"
        red = "#F472B6"
        white = "#DCF0E8"
        yellow = "#FBBF24"
    },
    @{
        name = "Sage Violet"
        background = "#1E0A2E"
        foreground = "#E8DCF0"
        cursorColor = "#C084FC"
        selectionBackground = "#7C3AED"
        black = "#1E0A2E"
        blue = "#818CF8"
        brightBlack = "#4C1D95"
        brightBlue = "#A5B4FC"
        brightCyan = "#A78BFA"
        brightGreen = "#C4B5FD"
        brightPurple = "#E9D5FF"
        brightRed = "#FDA4AF"
        brightWhite = "#F5F3FF"
        brightYellow = "#FDE68A"
        cyan = "#8B5CF6"
        green = "#A78BFA"
        purple = "#C084FC"
        red = "#F472B6"
        white = "#E8DCF0"
        yellow = "#FBBF24"
    },
    @{
        name = "Sage Dispatcher"
        background = "#3D2B08"
        foreground = "#F5E6C8"
        cursorColor = "#FFD700"
        selectionBackground = "#B8860B"
        black = "#2E2006"
        blue = "#DAA520"
        brightBlack = "#5C4A1E"
        brightBlue = "#FFD700"
        brightCyan = "#F0C040"
        brightGreen = "#E8C860"
        brightPurple = "#FFE4A0"
        brightRed = "#E8A060"
        brightWhite = "#FFF8E0"
        brightYellow = "#FFD700"
        cyan = "#CDA030"
        green = "#D4AA40"
        purple = "#E8C050"
        red = "#D08040"
        white = "#F5E6C8"
        yellow = "#FFD700"
    },
    @{
        name = "Sage Ember"
        background = "#1A0A00"
        foreground = "#FFD4B8"
        cursorColor = "#FF6B35"
        selectionBackground = "#C44D1A"
        black = "#1A0A00"
        blue = "#FF8C5A"
        brightBlack = "#4D2800"
        brightBlue = "#FFB088"
        brightCyan = "#FFA070"
        brightGreen = "#FFB880"
        brightPurple = "#FFD0A8"
        brightRed = "#FF6B35"
        brightWhite = "#FFF0E0"
        brightYellow = "#FFD700"
        cyan = "#FF9050"
        green = "#FFA060"
        purple = "#FFB080"
        red = "#E85020"
        white = "#FFD4B8"
        yellow = "#FBBF24"
    }
)

# Ensure schemes array exists
if (-not $settings.schemes) {
    $settings | Add-Member -NotePropertyName "schemes" -NotePropertyValue @()
}

foreach ($scheme in $colorSchemes) {
    # Remove existing scheme with same name
    $settings.schemes = @($settings.schemes | Where-Object { $_.name -ne $scheme.name })
    # Add new scheme
    $schemeObj = [PSCustomObject]$scheme
    $settings.schemes += $schemeObj
    Write-Host "Color Scheme hinzugefuegt: $($scheme.name)"
}

# --- PROFILES ---

$vaultPath = "$env:USERPROFILE\Sage"
$gitBash = "C:\Program Files\Git\bin\bash.exe"

$profiles = @(
    @{
        guid = "{c94e8f4a-2d33-5f9b-c7f3-02db61ca0f01}"
        name = "Sage"
        commandline = "claude"
        startingDirectory = $vaultPath
        colorScheme = "Sage Violet"
        useAcrylic = $true
        acrylicOpacity = 0.85
        backgroundImage = "BACKGROUND_URL_PLACEHOLDER"
        backgroundImageOpacity = 0.15
        backgroundImageStretchMode = "uniformToFill"
        font = @{ face = "Cascadia Code"; size = 11 }
        hidden = $false
    },
    @{
        guid = "{c94e8f4a-2d33-5f9b-c7f3-02db61ca0f02}"
        name = "Sage Fork"
        commandline = "$gitBash --login"
        startingDirectory = $vaultPath
        colorScheme = "Sage Fork"
        useAcrylic = $true
        acrylicOpacity = 0.85
        backgroundImage = "BACKGROUND_URL_PLACEHOLDER"
        backgroundImageOpacity = 0.15
        backgroundImageStretchMode = "uniformToFill"
        font = @{ face = "Cascadia Code"; size = 11 }
        hidden = $false
    },
    @{
        guid = "{c94e8f4a-2d33-5f9b-c7f3-02db61ca0f03}"
        name = "Sage Subagent"
        commandline = "$gitBash --login"
        startingDirectory = $vaultPath
        colorScheme = "Sage Violet"
        useAcrylic = $true
        acrylicOpacity = 0.85
        backgroundImage = "BACKGROUND_URL_PLACEHOLDER"
        backgroundImageOpacity = 0.15
        backgroundImageStretchMode = "uniformToFill"
        font = @{ face = "Cascadia Code"; size = 11 }
        hidden = $false
    },
    @{
        guid = "{c94e8f4a-2d33-5f9b-c7f3-02db61ca0f04}"
        name = "Sage Dispatcher"
        commandline = "$gitBash --login"
        startingDirectory = $vaultPath
        colorScheme = "Sage Dispatcher"
        useAcrylic = $true
        acrylicOpacity = 0.85
        backgroundImage = "BACKGROUND_URL_PLACEHOLDER"
        backgroundImageOpacity = 0.15
        backgroundImageStretchMode = "uniformToFill"
        font = @{ face = "Cascadia Code"; size = 11 }
        hidden = $false
    }
)

# Ensure profiles.list exists
if (-not $settings.profiles) {
    $settings | Add-Member -NotePropertyName "profiles" -NotePropertyValue @{ list = @() }
}
if (-not $settings.profiles.list) {
    $settings.profiles | Add-Member -NotePropertyName "list" -NotePropertyValue @()
}

foreach ($profile in $profiles) {
    # Remove existing profile with same GUID
    $settings.profiles.list = @($settings.profiles.list | Where-Object { $_.guid -ne $profile.guid })
    # Add new profile
    $profileObj = [PSCustomObject]$profile
    $settings.profiles.list += $profileObj
    Write-Host "Profil hinzugefuegt: $($profile.name)"
}

# --- SAVE ---

$json = $settings | ConvertTo-Json -Depth 10
# Ensure UTF-8 without BOM
[System.IO.File]::WriteAllText($settingsPath, $json, [System.Text.UTF8Encoding]::new($false))

Write-Host ""
Write-Host "Setup abgeschlossen. Windows Terminal neu starten um die Aenderungen zu sehen."
Write-Host ""
Write-Host "Hinweise:"
Write-Host "  - Hintergrundbilder nutzen BACKGROUND_URL_PLACEHOLDER -- ersetze mit echten URLs"
Write-Host "  - Sage-Profil startet direkt 'claude' im Vault $vaultPath"
Write-Host "  - Fork/Subagent/Dispatcher nutzen Git Bash"
Write-Host "  - Backup liegt unter: $backupPath"
