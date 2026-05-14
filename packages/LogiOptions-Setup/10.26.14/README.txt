╔════════════════════════════════════════════════════════════════════════╗
║                                                                        ║
║   PSADT INTUNE WIN32 APP - EXE DEPLOYMENT                              ║
║   LogiOptions Setup 10.26.14                                             
║                                                                        ║
╚════════════════════════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════════════════════════
  BESTANDEN IN DEZE FOLDER
═══════════════════════════════════════════════════════════════════════════

📦 LogiOptions Setup/10.26.14/
├── Invoke-AppDeployToolkit.ps1  ← PSADT deployment script
├── metadata.json                ← Package metadata
├── README.txt                   ← Dit bestand
├── Create-IntuneWin.cmd         ← Script om .intunewin te maken

⚠️  Let op: EXE installer bestand is NIET meegeleverd (>100MB).
    Download de installer separaat en plaats deze in de Toolkit/Files/ folder.

═══════════════════════════════════════════════════════════════════════════
  GEBRUIK INSTRUCTIES
═══════════════════════════════════════════════════════════════════════════

STAP 1: DOWNLOAD BESTANDEN & VOEG INSTALLER TOE
──────────────────────────────────────────────────

⚠️  Installer bestand is NIET included (>100MB).

1. Clone de repository of download deze folder
2. Download de EXE installer: options_installer.exe
   
   📥 Download locaties (kies één):
      • Vendor website: Zoek "Logitech Inc. LogiOptions Setup 10.26.14"
   • Eigen bron (indien beschikbaar)

3. Maak een folder structuur:
   
   MyPackage/
   ├── Toolkit/
   │   ├── Invoke-AppDeployToolkit.ps1  (van GitHub)
   │   └── Files/
   │       └── options_installer.exe      ⚠️ HANDMATIG TOEVOEGEN
   ├── Create-IntuneWin.cmd              (van GitHub)
   └── README.txt                        (van GitHub)

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
   .\IntuneWinAppUtil.exe -c .\Toolkit -s Invoke-AppDeployToolkit.ps1 -o .\Output

STAP 3: UPLOAD NAAR INTUNE
──────────────────────────────────

1. Microsoft Endpoint Manager Admin Center
2. Apps > All apps > Add
3. App type: Windows app (Win32)
4. Select app package file: Upload de .intunewin file uit Output folder

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

Operating system architecture:  32-bit or 64-bit
Minimum operating system:       Windows 10 1809

┌─────────────────────────────────────────────────────────────────────────┐
│ DETECTION RULES (VERPLICHT!)                                            │
└─────────────────────────────────────────────────────────────────────────┘

⚠️  Voor EXE deployments moet je een detection rule configureren.
    Kies één van de volgende opties:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPTIE 1: REGISTRY DETECTION (MEEST BETROUWBAAR)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Rule type:         Registry
Key path:          HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{GUID-or-AppName}
Value name:        DisplayName
Detection method:  String comparison
Operator:          Equals
Value:             LogiOptions Setup

Alternative registry paths:
• HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{GUID}
• HKEY_LOCAL_MACHINE\SOFTWARE\Logitech Inc.\LogiOptions Setup

⚠️  Test de registry locatie na handmatige installatie!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPTIE 2: FILE/FOLDER DETECTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Rule type:         File or folder
Path:              C:\Program Files\Logitech Inc.\LogiOptions Setup
File or folder:    LogiOptions Setup.exe
Detection method:  File or folder exists
Associated with:   32-bit app

⚠️  Pas het pad aan naar de werkelijke installatie locatie!
    Gebruik optioneel versie check:
    
    Detection method:  Version comparison
    Operator:          Greater than or equal to
    Version:           10.26.14

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPTIE 3: POWERSHELL DETECTION SCRIPT (MEEST FLEXIBEL)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Rule type:              Use a custom detection script
Script file:            Detection.ps1
Run script as 32-bit:   Yes

Voorbeeld Detection.ps1 inhoud:
────────────────────────────────────────────────────────────────────────
# Detection script voor LogiOptions Setup
$minVersion = [version]"10.26.14"

# Method 1: Check via Registry
$regPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

foreach ($path in $regPaths) {
    $app = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | 
           Where-Object { $_.DisplayName -like "*LogiOptions Setup*" }
    
    if ($app) {
        try {
            $installedVersion = [version]$app.DisplayVersion
            if ($installedVersion -ge $minVersion) {
                Write-Output "Detected: LogiOptions Setup $installedVersion"
                exit 0
            }
        } catch {
            Write-Output "Detected: LogiOptions Setup"
            exit 0
        }
    }
}

# Method 2: Check via File System
$filePaths = @(
    "C:\Program Files\Logitech Inc.\LogiOptions Setup\LogiOptions Setup.exe",
    "C:\Program Files (x86)\Logitech Inc.\LogiOptions Setup\LogiOptions Setup.exe"
)

foreach ($filePath in $filePaths) {
    if (Test-Path $filePath) {
        $fileVersion = (Get-Item $filePath).VersionInfo.FileVersion
        if ($fileVersion) {
            try {
                $ver = [version]$fileVersion
                if ($ver -ge $minVersion) {
                    Write-Output "Detected: $appName $fileVersion at $filePath"
                    exit 0
                }
            } catch {
                Write-Output "Detected: $appName at $filePath"
                exit 0
            }
        }
    }
}

Write-Output "Not detected"
exit 1
────────────────────────────────────────────────────────────────────────

═══════════════════════════════════════════════════════════════════════════
  INSTALLER TYPE: NSIS
═══════════════════════════════════════════════════════════════════════════


NSIS installer gedetecteerd.
Silent parameters: /S

Uninstall locatie (meestal):
C:\Program Files\Logitech Inc.\LogiOptions Setup\Uninstall.exe


═══════════════════════════════════════════════════════════════════════════
  TESTEN VOOR DEPLOYMENT
═══════════════════════════════════════════════════════════════════════════

1. Test handmatig op een test machine (als SYSTEM):
   
   PsExec.exe -i -s powershell.exe
   cd "C:\Path\To\Toolkit"
   .\Invoke-AppDeployToolkit.ps1 -DeploymentType Install

2. Verify detection na installatie:
   
   # Registry check
   Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
       Where-Object {$_.DisplayName -like "*LogiOptions Setup*"}
   
   # File check
   Test-Path "C:\Program Files\Logitech Inc.\LogiOptions Setup\LogiOptions Setup.exe"

3. Test uninstall:
   
   .\Invoke-AppDeployToolkit.ps1 -DeploymentType Uninstall

═══════════════════════════════════════════════════════════════════════════

Generated by PSADT Script Generator
14-5-2026
Committed to GitHub for version control
