╔════════════════════════════════════════════════════════════════════════╗
║                                                                        ║
║   PSADT INTUNE WIN32 APP - EXE DEPLOYMENT                              ║
║   CIS CAT Assessor Windows GUI Jre V 4.65.0                                             
║                                                                        ║
╚════════════════════════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════════════════════════
  BESTANDEN IN DEZE FOLDER
═══════════════════════════════════════════════════════════════════════════

📦 CIS CAT Assessor Windows GUI Jre V/4.65.0/
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
2. Download de EXE installer: CIS-CAT-Assessor-Windows-GUI-jre-v4.65.0.zip
   
   📥 Download locaties (kies één):
      • Vendor website: Zoek "CIS CIS CAT Assessor Windows GUI Jre V 4.65.0"
   • Eigen bron (indien beschikbaar)

3. Maak een folder structuur:
   
   MyPackage/
   ├── Toolkit/
   │   ├── Invoke-AppDeployToolkit.ps1  (van GitHub)
   │   └── Files/
   │       └── CIS-CAT-Assessor-Windows-GUI-jre-v4.65.0.zip      ⚠️ HANDMATIG TOEVOEGEN
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

Operating system architecture:  64-bit
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
Value:             CIS CAT Assessor Windows GUI Jre V

Alternative registry paths:
• HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{GUID}
• HKEY_LOCAL_MACHINE\SOFTWARE\CIS\CIS CAT Assessor Windows GUI Jre V

⚠️  Test de registry locatie na handmatige installatie!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPTIE 2: FILE/FOLDER DETECTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Rule type:         File or folder
Path:              C:\Program Files\CIS\CIS CAT Assessor Windows GUI Jre V
File or folder:    CIS CAT Assessor Windows GUI Jre V.exe
Detection method:  File or folder exists
Associated with:   64-bit app

⚠️  Pas het pad aan naar de werkelijke installatie locatie!
    Gebruik optioneel versie check:
    
    Detection method:  Version comparison
    Operator:          Greater than or equal to
    Version:           4.65.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPTIE 3: POWERSHELL DETECTION SCRIPT (MEEST FLEXIBEL)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Rule type:              Use a custom detection script
Script file:            Detection.ps1
Run script as 32-bit:   No

Voorbeeld Detection.ps1 inhoud:
────────────────────────────────────────────────────────────────────────
# Detection script voor CIS CAT Assessor Windows GUI Jre V
$minVersion = [version]"4.65.0"

# Method 1: Check via Registry
$regPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

foreach ($path in $regPaths) {
    $app = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | 
           Where-Object { $_.DisplayName -like "*CIS CAT Assessor Windows GUI Jre V*" }
    
    if ($app) {
        try {
            $installedVersion = [version]$app.DisplayVersion
            if ($installedVersion -ge $minVersion) {
                Write-Output "Detected: CIS CAT Assessor Windows GUI Jre V $installedVersion"
                exit 0
            }
        } catch {
            Write-Output "Detected: CIS CAT Assessor Windows GUI Jre V"
            exit 0
        }
    }
}

# Method 2: Check via File System
$filePaths = @(
    "C:\Program Files\CIS\CIS CAT Assessor Windows GUI Jre V\CIS CAT Assessor Windows GUI Jre V.exe",
    "C:\Program Files (x86)\CIS\CIS CAT Assessor Windows GUI Jre V\CIS CAT Assessor Windows GUI Jre V.exe"
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
  INSTALLER TYPE: UNKNOWN
═══════════════════════════════════════════════════════════════════════════


Installer type: unknown

Controleer de silent parameters in het PSADT script.
Test de installatie handmatig voor deployment.


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
       Where-Object {$_.DisplayName -like "*CIS CAT Assessor Windows GUI Jre V*"}
   
   # File check
   Test-Path "C:\Program Files\CIS\CIS CAT Assessor Windows GUI Jre V\CIS CAT Assessor Windows GUI Jre V.exe"

3. Test uninstall:
   
   .\Invoke-AppDeployToolkit.ps1 -DeploymentType Uninstall

═══════════════════════════════════════════════════════════════════════════

Generated by PSADT Script Generator
2-9-2026
Committed to GitHub for version control
