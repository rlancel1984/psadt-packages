╔════════════════════════════════════════════════════════════════════════╗
║                                                                        ║
║   PSADT INTUNE WIN32 APP - WINGET DEPLOYMENT                           ║
║   Zoom 5.13.11835                                             
║                                                                        ║
╚════════════════════════════════════════════════════════════════════════╝

⚠️  BELANGRIJK: Dit is een Winget-based deployment
    Deze package gebruikt Winget om de applicatie te installeren.
    Er is GEEN installer bestand nodig (Winget download het).

═══════════════════════════════════════════════════════════════════════════
  BESTANDEN IN DEZE FOLDER
═══════════════════════════════════════════════════════════════════════════

📦 Zoom/5.13.11835/
├── Invoke-AppDeployToolkit.ps1  ← PSADT deployment script
├── metadata.json                ← Package metadata
├── README.txt                   ← Dit bestand
└── Create-IntuneWin.cmd         ← Script om .intunewin te maken

⚠️  Let op: Geen installer bestand! Winget download de applicatie tijdens deployment.

═══════════════════════════════════════════════════════════════════════════
  GEBRUIK INSTRUCTIES
═══════════════════════════════════════════════════════════════════════════

STAP 1: DOWNLOAD BESTANDEN
──────────────────────────────────

1. Clone de repository of download deze folder
2. Zorg dat alle bestanden in één folder staan

STAP 2: MAAK DE .INTUNEWIN FILE
──────────────────────────────────

OPTIE A: AUTOMATISCH (Aanbevolen)
1. Dubbelklik op: Create-IntuneWin.cmd
2. Het script download automatisch IntuneWinAppUtil.exe (indien nodig)
3. De .intunewin file wordt gemaakt in de Output/ folder

OPTIE B: HANDMATIG
1. Download IntuneWinAppUtil.exe van:
   https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool
2. Open PowerShell en run:
   .\IntuneWinAppUtil.exe -c . -s Invoke-AppDeployToolkit.ps1 -o .\Output

STAP 3: UPLOAD NAAR INTUNE
──────────────────────────────────

1. Microsoft Endpoint Manager Admin Center
2. Apps > All apps > Add
3. App type: Windows app (Win32)
4. Select app package file: Upload de .intunewin file

═══════════════════════════════════════════════════════════════════════════
  INTUNE WIN32 APP CONFIGURATIE
═══════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────────┐
│ PROGRAM SETTINGS                                                        │
└─────────────────────────────────────────────────────────────────────────┘

Install command:
powershell.exe -ExecutionPolicy Bypass -File Invoke-AppDeployToolkit.ps1 -DeploymentType Install

Uninstall command:
powershell.exe -ExecutionPolicy Bypass -File Invoke-AppDeployToolkit.ps1 -DeploymentType Uninstall

Install behavior:         System
Device restart behavior:  Determine behavior based on return codes

┌─────────────────────────────────────────────────────────────────────────┐
│ REQUIREMENTS                                                            │
└─────────────────────────────────────────────────────────────────────────┘

Operating system architecture:  64-bit
Minimum operating system:       Windows 10 1809

┌─────────────────────────────────────────────────────────────────────────┐
│ DETECTION RULES (VERPLICHT!)                                            │
└─────────────────────────────────────────────────────────────────────────┘

⚠️  Voor Winget apps is een handmatige detection rule nodig.
    Kies één van de volgende opties:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPTIE 1: REGISTRY DETECTION (AANBEVOLEN)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Rule type:         Registry
Key path:          HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Zoom.Zoom
Value name:        DisplayName
Detection method:  String comparison
Operator:          Equals
Value:             Zoom

Alternative registry path (probeer beide):
HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Zoom.Zoom

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPTIE 2: FILE/FOLDER DETECTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Rule type:         File or folder
Path:              C:\Program Files\Zoom\Zoom
File or folder:    Zoom.exe
Detection method:  File or folder exists
Associated with:   64-bit app

⚠️  Pas het pad aan naar de werkelijke installatie locatie!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPTIE 3: POWERSHELL DETECTION SCRIPT (MEEST FLEXIBEL)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Rule type:              Use a custom detection script
Script file:            Detection.ps1
Run script as 32-bit:   No

Voorbeeld Detection.ps1 inhoud:
────────────────────────────────────────────────────────────────────────
# Detection script voor Zoom
$minVersion = [version]"5.13.11835"

# Check via Registry
$regPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Zoom.Zoom",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Zoom.Zoom"
)

foreach ($path in $regPaths) {
    $app = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | 
           Where-Object { $_.DisplayName -like "*Zoom*" }
    
    if ($app) {
        try {
            $installedVersion = [version]$app.DisplayVersion
            if ($installedVersion -ge $minVersion) {
                Write-Output "Detected: Zoom $installedVersion"
                exit 0
            }
        } catch {
            Write-Output "Detected: Zoom (version check failed)"
            exit 0
        }
    }
}

Write-Output "Not detected"
exit 1
────────────────────────────────────────────────────────────────────────

═══════════════════════════════════════════════════════════════════════════
  WINGET VEREISTEN
═══════════════════════════════════════════════════════════════════════════

✅  Winget moet geïnstalleerd zijn op doelcomputers:
    • Windows 11: Standaard aanwezig
    • Windows 10: Installeer "App Installer" via Microsoft Store
    • Intune: Deploy via Microsoft Store app of PowerShell script

✅  Internet verbinding vereist tijdens installatie

✅  SYSTEM context: Winget werkt in SYSTEM context (LocalSystem account)

═══════════════════════════════════════════════════════════════════════════
  WINGET PACKAGE INFO
═══════════════════════════════════════════════════════════════════════════

Package ID:  Zoom.Zoom
Source:      winget (Microsoft repository)

Test handmatig met:
winget search Zoom.Zoom
winget show Zoom.Zoom

═══════════════════════════════════════════════════════════════════════════
  AUTO-UPDATE FUNCTIONALITEIT (OPTIONEEL)
═══════════════════════════════════════════════════════════════════════════

⚠️  Als auto-update is ingeschakeld tijdens script generatie, wordt automatisch
    een Windows Scheduled Task aangemaakt voor automatische updates.

┌─────────────────────────────────────────────────────────────────────────┐
│ SCHEDULED TASK DETAILS                                                  │
└─────────────────────────────────────────────────────────────────────────┘

Task Name:       WingetAutoUpdate_Zoom
Trigger:         Dagelijks om 03:00 uur
Account:         SYSTEM (LocalSystem)
Privileges:      Hoogste niveau (Administrator)

Command:         winget upgrade --id Zoom.Zoom --silent --scope machine

Settings:
  ✅  StartWhenAvailable           → Task draait bij eerstvolgende gelegenheid
                                    als device uit stond om 3:00
  ✅  AllowStartIfOnBatteries      → Mag op batterij draaien (laptops)
  ✅  DontStopIfGoingOnBatteries   → Stopt niet als device op batterij gaat
  ✅  RunOnlyIfNetworkAvailable    → Vereist actieve netwerkverbinding
  ✅  ExecutionTimeLimit: 1 uur    → Max. uitvoertijd per update poging
  ✅  RestartCount: 3               → Tot 3x retry bij falen
  ✅  RestartInterval: 1 minuut    → 1 minuut wachten tussen retries

┌─────────────────────────────────────────────────────────────────────────┐
│ HERSCHEDULING GEDRAG                                                    │
└─────────────────────────────────────────────────────────────────────────┘

📋  Desktop computers (24/7 aan):
    → Update draait precies om 03:00 elke dag
    → Geen gebruiker impact (buiten werktijd)

💻  Laptop computers (vaak uit):
    → Device uit om 03:00? Task wordt gemist
    → Device aan om 08:30? Task draait automatisch zodra device beschikbaar is
    → Update gebeurt voordat gebruiker begint te werken

📊  Enterprise Voordelen:
    → Gecontroleerde update window (3:00 of bij opstarten)
    → Geen netwerk overbelasting (updates gespreid over de dag)
    → Minimale impact op productiviteit
    → Predictable voor IT beheer

┌─────────────────────────────────────────────────────────────────────────┐
│ LOG LOCATIE & TROUBLESHOOTING                                          │
└─────────────────────────────────────────────────────────────────────────┘

Update logs:     %TEMP%\winget_update_Zoom.log
PSADT logs:      C:\Windows\Logs\Software\Zoom\*.log

View scheduled task:
  • Open: Task Scheduler (taskschd.msc)
  • Navigeer: Task Scheduler Library
  • Zoek: WingetAutoUpdate_Zoom
  • Rechtermuisknop: Run (om handmatig te testen)

View last run result:
  Get-ScheduledTask -TaskName "WingetAutoUpdate_Zoom" | 
    Get-ScheduledTaskInfo | 
    Select LastRunTime, LastTaskResult

Manual update test:
  winget upgrade --id Zoom.Zoom --silent --scope machine

┌─────────────────────────────────────────────────────────────────────────┐
│ UNINSTALL CLEANUP                                                      │
└─────────────────────────────────────────────────────────────────────────┘

✅  De scheduled task wordt AUTOMATISCH verwijderd tijdens uninstallation.
    Geen handmatige cleanup nodig!

Manual task removal (indien nodig):
  Unregister-ScheduledTask -TaskName "WingetAutoUpdate_Zoom" -Confirm:$false

═══════════════════════════════════════════════════════════════════════════

Generated by PSADT Script Generator
1-2-2026
Committed to GitHub for version control
