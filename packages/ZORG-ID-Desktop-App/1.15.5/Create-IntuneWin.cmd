@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM  PSADT Intune Package Creator
REM  App: ZORG-ID Desktop App
REM  Installer: ZORG-ID Desktop App for Windows-1.15.5.msi
REM  
REM  BELANGRIJK: Plaats het installer bestand in Toolkit/Files/
REM  voordat je dit script uitvoert!
REM ============================================================

set "SCRIPT_DIR=%~dp0"
set "TOOLKIT_DIR=!SCRIPT_DIR!Toolkit"
set "OUTPUT_DIR=!SCRIPT_DIR!Output"
set "INTUNE_UTIL=!SCRIPT_DIR!IntuneWinAppUtil.exe"
set "PSADT_SCRIPT=!TOOLKIT_DIR!\Invoke-AppDeployToolkit.ps1"

echo.
echo ============================================================
echo   PSADT Intune Package Creator
echo   Type: MSI/EXE DEPLOYMENT
echo ============================================================
echo.

REM Check if IntuneWinAppUtil.exe exists
if not exist "!INTUNE_UTIL!" (
    echo [INFO] IntuneWinAppUtil.exe niet gevonden.
    echo [INFO] Downloading from Microsoft...
    echo.
    
    REM Download using PowerShell
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/raw/master/IntuneWinAppUtil.exe' -OutFile '!INTUNE_UTIL!' -UseBasicParsing"
    
    if exist "!INTUNE_UTIL!" (
        echo [OK] Download succesvol!
    ) else (
        echo.
        echo [ERROR] Download mislukt. Download handmatig van:
        echo         https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool
        echo.
        pause
        exit /b 1
    )
)

REM Check Toolkit folder
if not exist "!PSADT_SCRIPT!" (
    echo [ERROR] Toolkit folder niet gevonden of onvolledig.
    echo         Controleer of Invoke-AppDeployToolkit.ps1 aanwezig is.
    echo         Verwacht: !PSADT_SCRIPT!
    pause
    exit /b 1
)


REM Check installer file (skip for Winget)
if not exist "!TOOLKIT_DIR!\Files\ZORG-ID Desktop App for Windows-1.15.5.msi" (
    echo [ERROR] Installer bestand niet gevonden!
    echo         Verwacht: !TOOLKIT_DIR!\Files\ZORG-ID Desktop App for Windows-1.15.5.msi
    echo.
    echo         Plaats het installer bestand in de Toolkit/Files/ folder.
    pause
    exit /b 1
)


REM Create output folder
if not exist "!OUTPUT_DIR!" mkdir "!OUTPUT_DIR!"

echo [INFO] Toolkit folder: !TOOLKIT_DIR!
echo [INFO] Setup file:    Invoke-AppDeployToolkit.ps1
echo [INFO] Output folder: !OUTPUT_DIR!
echo.
echo [INFO] Creating .intunewin file...
echo.

REM Run IntuneWinAppUtil
"!INTUNE_UTIL!" -c "!TOOLKIT_DIR!" -s "Invoke-AppDeployToolkit.ps1" -o "!OUTPUT_DIR!" -q

if !ERRORLEVEL! EQU 0 (
    echo.
    echo ============================================================
    echo   [SUCCESS] Intune package succesvol aangemaakt!
    echo ============================================================
    echo.
    echo   Output: !OUTPUT_DIR!\Invoke-AppDeployToolkit.intunewin
    echo.    echo   Intune Install Command:
    echo   powershell.exe -ExecutionPolicy Bypass -File Invoke-AppDeployToolkit.ps1 -DeploymentType Install
    echo.
    echo   Intune Uninstall Command:
    echo   powershell.exe -ExecutionPolicy Bypass -File Invoke-AppDeployToolkit.ps1 -DeploymentType Uninstall
    echo.
) else (
    echo.
    echo [ERROR] Er is een fout opgetreden bij het maken van de .intunewin file.
    echo         Controleer de Toolkit folder en probeer opnieuw.
)

pause
