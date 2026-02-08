╔════════════════════════════════════════════════════════════════════════╗
║                                                                        ║
║   PSADT INTUNE WIN32 APP - EXE DEPLOYMENT                              ║
║   count 7.7.0                                             
║                                                                        ║
╚════════════════════════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════════════════════════
  BESTANDEN IN DEZE FOLDER
═══════════════════════════════════════════════════════════════════════════

📦 count/7.7.0/
├── Invoke-AppDeployToolkit.ps1  ← PSADT deployment script
├── metadata.json                ← Package metadata
├── README.txt                   ← Dit bestand
├── Create-IntuneWin.cmd         ← Script om .intunewin te maken
└── Toolkit/Files/EasyLogUSB+Installer.exe   ← EXE installer (INCLUDED)

═══════════════════════════════════════════════════════════════════════════
  GEBRUIK INSTRUCTIES
═══════════════════════════════════════════════════════════════════════════

STAP 1: DOWNLOAD BESTANDEN
──────────────────────────────────────────────────

✅ De EXE installer (EasyLogUSB+Installer.exe) is AL INCLUDED in deze package!

1. Clone de repository of download deze folder
2. Alle bestanden zijn aanwezig - geen extra downloads nodig

   MyPackage/
   ├── Toolkit/
   │   ├── Invoke-AppDeployToolkit.ps1  (van GitHub)
   │   └── Files/
   │       └── EasyLogUSB+Installer.exe      ✅ INCLUDED
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
Value:             count

Alternative registry paths:
• HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{GUID}
• HKEY_LOCAL_MACHINE\SOFTWARE\CompanyURL\count

⚠️  Test de registry locatie na handmatige installatie!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPTIE 2: FILE/FOLDER DETECTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Rule type:         File or folder
Path:              C:\Program Files\CompanyURL\count
File or folder:    count.exe
Detection method:  File or folder exists
Associated with:   32-bit app

⚠️  Pas het pad aan naar de werkelijke installatie locatie!
    Gebruik optioneel versie check:
    
    Detection method:  Version comparison
    Operator:          Greater than or equal to
    Version:           7.7.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPTIE 3: POWERSHELL DETECTION SCRIPT (MEEST FLEXIBEL)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Rule type:              Use a custom detection script
Script file:            Detection.ps1
Run script as 32-bit:   Yes

Voorbeeld Detection.ps1 inhoud:
────────────────────────────────────────────────────────────────────────
# Detection script voor count
$minVersion = [version]"7.7.0"

# Method 1: Check via Registry
$regPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

foreach ($path in $regPaths) {
    $app = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | 
           Where-Object { $_.DisplayName -like "*count*" }
    
    if ($app) {
        try {
            $installedVersion = [version]$app.DisplayVersion
            if ($installedVersion -ge $minVersion) {
                Write-Output "Detected: count $installedVersion"
                exit 0
            }
        } catch {
            Write-Output "Detected: count"
            exit 0
        }
    }
}

# Method 2: Check via File System
$filePaths = @(
    "C:\Program Files\CompanyURL\count\count.exe",
    "C:\Program Files (x86)\CompanyURL\count\count.exe"
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
       Where-Object {$_.DisplayName -like "*count*"}
   
   # File check
   Test-Path "C:\Program Files\CompanyURL\count\count.exe"

3. Test uninstall:
   
   .\Invoke-AppDeployToolkit.ps1 -DeploymentType Uninstall

═══════════════════════════════════════════════════════════════════════════

Generated by PSADT Script Generator
8-2-2026
Committed to GitHub for version control
