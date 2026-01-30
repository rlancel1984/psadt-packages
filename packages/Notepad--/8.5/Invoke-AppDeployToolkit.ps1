<#

.SYNOPSIS
PSAppDeployToolkit - This script performs the installation or uninstallation of an application(s).

.DESCRIPTION
- The script is provided as a template to perform an install, uninstall, or repair of an application(s).
- The script either performs an "Install", "Uninstall", or "Repair" deployment type.
- The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.

The script imports the PSAppDeployToolkit module which contains the logic and functions required to install or uninstall an application.

.PARAMETER DeploymentType
The type of deployment to perform.

.PARAMETER DeployMode
Specifies whether the installation should be run in Interactive (shows dialogs), Silent (no dialogs), NonInteractive (dialogs without prompts) mode, or Auto (shows dialogs if a user is logged on, device is not in the OOBE, and there's no running apps to close).

Silent mode is automatically set if it is detected that the process is not user interactive, no users are logged on, the device is in Autopilot mode, or there's specified processes to close that are currently running.

.PARAMETER SuppressRebootPassThru
Suppresses the 3010 return code (requires restart) from being passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.

.PARAMETER TerminalServerMode
Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Desktop Session Hosts/Citrix servers.

.PARAMETER DisableLogging
Disables logging to file for the script.

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -DeployMode Silent

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -DeploymentType Uninstall

.EXAMPLE
Invoke-AppDeployToolkit.exe -DeploymentType Install -DeployMode Silent

.INPUTS
None. You cannot pipe objects to this script.

.OUTPUTS
None. This script does not generate any output.

.NOTES
Toolkit Exit Code Ranges:
- 60000 - 68999: Reserved for built-in exit codes in Invoke-AppDeployToolkit.ps1, and Invoke-AppDeployToolkit.exe
- 69000 - 69999: Recommended for user customized exit codes in Invoke-AppDeployToolkit.ps1
- 70000 - 79999: Recommended for user customized exit codes in PSAppDeployToolkit.Extensions module.

.LINK
https://psappdeploytoolkit.com

#>

[CmdletBinding()]
param
(
    # Default is 'Install'.
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall', 'Repair')]
    [System.String]$DeploymentType,

    # Default is 'Auto'. Don't hard-code this unless required.
    [Parameter(Mandatory = $false)]
    [ValidateSet('Auto', 'Interactive', 'NonInteractive', 'Silent')]
    [System.String]$DeployMode,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$SuppressRebootPassThru,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$TerminalServerMode,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$DisableLogging
)


##================================================
## MARK: Variables
##================================================

# Zero-Config MSI support is provided when "AppName" is null or empty.
# By setting the "AppName" property, Zero-Config MSI will be disabled.
$adtSession = @{
    # App variables.
    AppVendor = 'Notepad++ Team'
    AppName = 'Notepad++'
    AppVersion = '8.5'
    AppArch = ''
    AppLang = 'EN'
    AppRevision = '01'
    AppSuccessExitCodes = @(0)
    AppRebootExitCodes = @(1641, 3010)
    AppProcessesToClose = @()  # Example: @('excel', @{ Name = 'winword'; Description = 'Microsoft Word' })
    AppScriptVersion = '1.0.0'
    AppScriptDate = '2026-01-30'
    AppScriptAuthor = 'R.Lancel'
    RequireAdmin = $true

    # Install Titles (Only set here to override defaults set by the toolkit).
    InstallName = ''
    InstallTitle = ''

    # Script variables.
    DeployAppScriptFriendlyName = $MyInvocation.MyCommand.Name
    DeployAppScriptParameters = $PSBoundParameters
    DeployAppScriptVersion = '4.1.8'
}

function Install-ADTDeployment
{
    [CmdletBinding()]
    param
    (
    )

    ##================================================
    ## MARK: Pre-Install
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

    ## Show Welcome Message, close processes if specified, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt.
    $saiwParams = @{
        AllowDefer = $true
        DeferTimes = 3
        CheckDiskSpace = $true
        PersistPrompt = $true
    }
    if ($adtSession.AppProcessesToClose.Count -gt 0)
    {
        $saiwParams.Add('CloseProcesses', $adtSession.AppProcessesToClose)
    }
    Show-ADTInstallationWelcome @saiwParams

    ## Show Progress Message (with the default message).
    Show-ADTInstallationProgress

    ## <Perform Pre-Installation tasks here>


    ##================================================
    ## MARK: Install
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    ## Handle Zero-Config MSI installations.
    if ($adtSession.UseDefaultMsi)
    {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile)
        {
            $ExecuteDefaultMSISplat.Add('Transforms', $adtSession.DefaultMstFile)
        }
        Start-ADTMsiProcess @ExecuteDefaultMSISplat
        if ($adtSession.DefaultMspFiles)
        {
            $adtSession.DefaultMspFiles | Start-ADTMsiProcess -Action Patch
        }
    }

    ## <Perform Installation tasks here>
    # Install via Winget
    # Resolve winget.exe full path (required by Start-ADTProcess)
    $wingetPath = (Get-Command winget.exe -ErrorAction SilentlyContinue).Source
    if (-not $wingetPath) {
        Write-ADTLogEntry -Message "Winget is not installed or not found in PATH" -Severity 3
        Exit-ADTScript -ExitCode 60008
    }
    
    Write-ADTLogEntry -Message "Installing Notepad++.Notepad++ via Winget..." -Severity 1
    
    # Check if package is already installed using exit code (0 = found, non-zero = not found)
    & $wingetPath list --id Notepad++.Notepad++ --exact --accept-source-agreements 2>&1 | Out-Null
    $isInstalled = ($LASTEXITCODE -eq 0)
    
    if ($isInstalled) {
        Write-ADTLogEntry -Message "Package already installed, attempting upgrade..." -Severity 2
        $wingetResult = Start-ADTProcess -FilePath $wingetPath -ArgumentList 'upgrade --id Notepad++.Notepad++ --silent --accept-source-agreements --accept-package-agreements' -PassThru -IgnoreExitCodes @(0,-1978335212)
        
        # -1978335212 = No applicable update found (already up to date)
        if ($wingetResult.ExitCode -eq -1978335212) {
            Write-ADTLogEntry -Message "Package is already up to date" -Severity 1
            $wingetResult = [PSCustomObject]@{ ExitCode = 0 }
        }
    } else {
        # Fresh install
        Write-ADTLogEntry -Message "Attempting fresh installation..." -Severity 1
        $wingetResult = Start-ADTProcess -FilePath $wingetPath -ArgumentList 'install --id Notepad++.Notepad++ --silent --accept-source-agreements --accept-package-agreements' -PassThru
    }
    
    if ($wingetResult.ExitCode -ne 0) {
        Write-ADTLogEntry -Message "Winget installation failed with exit code $($wingetResult.ExitCode)" -Severity 3
        Exit-ADTScript -ExitCode $wingetResult.ExitCode
    } else {
        Write-ADTLogEntry -Message "Winget installation completed successfully" -Severity 1
    }


    ##================================================
    ## MARK: Post-Install
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    ## <Perform Post-Installation tasks here>
    # ============================================
    # Plugin Installation
    # ============================================
    Write-ADTLogEntry -Message "Installing plugins..." -Severity 1
    
    # Plugin: XMLTools-3.1.1.13-x64.zip
    $pluginSource = "$($adtSession.DirFiles)\XMLTools-3.1.1.13-x64.zip"
    $pluginTarget = "C:\Program Files\Notepad++\plugins"
    
    # Extract ZIP plugin (handles Notepad++ style plugins)
    try {
        $tempExtractPath = Join-Path -Path $env:TEMP -ChildPath ("PluginExtract_" + [System.IO.Path]::GetRandomFileName())
        New-Item -Path $tempExtractPath -ItemType Directory -Force | Out-Null
        
        Write-ADTLogEntry -Message "Extracting plugin: $pluginSource to temp folder" -Severity 1
        Expand-Archive -Path $pluginSource -DestinationPath $tempExtractPath -Force
        
        # Find all DLL files in extracted content (including subfolders)
        $dllFiles = Get-ChildItem -Path $tempExtractPath -Filter "*.dll" -Recurse
        
        if ($dllFiles.Count -gt 0) {
            foreach ($dll in $dllFiles) {
                # Create folder named after DLL (without extension) INSIDE the plugins folder
                # $pluginTarget = C:\Program Files\Notepad++\plugins
                # Result: C:\Program Files\Notepad++\plugins\XMLTools\XMLTools.dll
                $pluginName = [System.IO.Path]::GetFileNameWithoutExtension($dll.Name)
                $pluginFolder = Join-Path -Path $pluginTarget -ChildPath $pluginName
                
                Write-ADTLogEntry -Message "Creating plugin folder: $pluginFolder" -Severity 1
                if (-not (Test-Path -Path $pluginFolder)) {
                    New-Item -Path $pluginFolder -ItemType Directory -Force | Out-Null
                }
                
                # Copy DLL to correct folder
                $finalDest = Join-Path -Path $pluginFolder -ChildPath $dll.Name
                Copy-Item -Path $dll.FullName -Destination $finalDest -Force
                Write-ADTLogEntry -Message "Plugin DLL installed: $finalDest" -Severity 1
                
                # Also copy any additional files from same folder (dependencies)
                $dllParent = $dll.Directory.FullName
                Get-ChildItem -Path $dllParent -File | Where-Object { $_.Name -ne $dll.Name } | ForEach-Object {
                    Copy-Item -Path $_.FullName -Destination $pluginFolder -Force
                    Write-ADTLogEntry -Message "Plugin dependency installed: $($_.Name)" -Severity 1
                }
            }
        } else {
            # No DLLs found, just extract to target as-is
            Write-ADTLogEntry -Message "No DLLs found in ZIP, extracting to target folder" -Severity 2
            if (-not (Test-Path -Path $pluginTarget)) {
                New-Item -Path $pluginTarget -ItemType Directory -Force | Out-Null
            }
            Copy-Item -Path "$tempExtractPath\*" -Destination $pluginTarget -Recurse -Force
        }
        
        # Cleanup temp folder
        Remove-Item -Path $tempExtractPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-ADTLogEntry -Message "Plugin extracted successfully" -Severity 1
    } catch {
        Write-ADTLogEntry -Message "Failed to extract plugin: $_" -Severity 3
    }
    
    Write-ADTLogEntry -Message "Plugin installation completed" -Severity 1
    
    ## Auto-update enabled
    # Winget packages ondersteunen automatische updates via "winget upgrade"
    
    # Create Scheduled Task for Automatic Winget Updates
    Write-ADTLogEntry -Message "Creating scheduled task for automatic updates: WingetAutoUpdate_Notepad" -Severity 1
    
    try {
        # Task Action: Run winget upgrade
        $action = New-ScheduledTaskAction `
            -Execute "powershell.exe" `
            -Argument "-NoProfile -WindowStyle Hidden -Command `"`& { winget upgrade --id Notepad++.Notepad++ --silent --accept-package-agreements --accept-source-agreements | Out-File -FilePath `$env:TEMP\winget_update_Notepad.log -Append }`"`""
        
        # Task Trigger: Daily at 3:00 AM
        $trigger = New-ScheduledTaskTrigger -Daily -At "03:00"
        
        # Task Principal: Run as SYSTEM with highest privileges
        $principal = New-ScheduledTaskPrincipal `
            -UserId "SYSTEM" `
            -LogonType ServiceAccount `
            -RunLevel Highest
        
        # Task Settings: Optimized for enterprise deployment
        $settings = New-ScheduledTaskSettingsSet `
            -AllowStartIfOnBatteries `
            -DontStopIfGoingOnBatteries `
            -StartWhenAvailable `
            -RunOnlyIfNetworkAvailable `
            -ExecutionTimeLimit (New-TimeSpan -Hours 1) `
            -RestartCount 3 `
            -RestartInterval (New-TimeSpan -Minutes 1)
        
        # Register the scheduled task
        Register-ScheduledTask `
            -TaskName "WingetAutoUpdate_Notepad" `
            -Action $action `
            -Trigger $trigger `
            -Principal $principal `
            -Settings $settings `
            -Description "Automatic update for Notepad++ via Winget. Runs daily at 3:00 AM or at next device startup if missed." `
            -Force | Out-Null
        
        Write-ADTLogEntry -Message "Scheduled task 'WingetAutoUpdate_Notepad' created successfully" -Severity 1
    }
    catch {
        Write-ADTLogEntry -Message "Failed to create scheduled task: $($_.Exception.Message)" -Severity 2
        # Non-critical error: Continue with deployment
    }


    ## Display a message at the end of the install.
    if (!$adtSession.UseDefaultMsi)
    {
        Show-ADTInstallationPrompt -Message 'You can customize text to appear at the end of an install or remove it completely for unattended installations.' -ButtonRightText 'OK' -NoWait
    }
}

function Uninstall-ADTDeployment
{
    [CmdletBinding()]
    param
    (
    )

    ##================================================
    ## MARK: Pre-Uninstall
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

    ## If there are processes to close, show Welcome Message with a 60 second countdown before automatically closing.
    if ($adtSession.AppProcessesToClose.Count -gt 0)
    {
        Show-ADTInstallationWelcome -CloseProcesses $adtSession.AppProcessesToClose -CloseProcessesCountdown 60
    }

    ## Show Progress Message (with the default message).
    Show-ADTInstallationProgress

    ## <Perform Pre-Uninstallation tasks here>


    ##================================================
    ## MARK: Uninstall
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    ## Handle Zero-Config MSI uninstallations.
    if ($adtSession.UseDefaultMsi)
    {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile)
        {
            $ExecuteDefaultMSISplat.Add('Transforms', $adtSession.DefaultMstFile)
        }
        Start-ADTMsiProcess @ExecuteDefaultMSISplat
    }

    ## <Perform Uninstallation tasks here>
    # Uninstall via Winget (with scope fallback)
    # Resolve winget.exe full path (required by Start-ADTProcess)
    $wingetPath = (Get-Command winget.exe -ErrorAction SilentlyContinue).Source
    if (-not $wingetPath) {
        Write-ADTLogEntry -Message "Winget is not installed or not found in PATH" -Severity 3
        Exit-ADTScript -ExitCode 60008
    }
    
    Write-ADTLogEntry -Message "Uninstalling Notepad++.Notepad++ via Winget..." -Severity 1
    
    # Try machine scope first
    $wingetResult = Start-ADTProcess -FilePath $wingetPath -ArgumentList 'uninstall --id Notepad++.Notepad++ --silent --scope machine' -PassThru -IgnoreExitCodes @(0,-1978335189)
    
    # If machine scope fails, try without scope (user scope)
    if ($wingetResult.ExitCode -eq -1978335189) {
        Write-ADTLogEntry -Message "Machine scope uninstall not supported, trying without scope..." -Severity 2
        $wingetResult = Start-ADTProcess -FilePath $wingetPath -ArgumentList 'uninstall --id Notepad++.Notepad++ --silent' -PassThru
    }
    
    if ($wingetResult.ExitCode -ne 0) {
        Write-ADTLogEntry -Message "Winget uninstallation failed with exit code $($wingetResult.ExitCode)" -Severity 2
        # Note: Some apps may not support Winget uninstall. Check app-specific uninstall methods.
    } else {
        Write-ADTLogEntry -Message "Winget uninstallation completed successfully" -Severity 1
    }


    ##================================================
    ## MARK: Post-Uninstallation
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    ## <Perform Post-Uninstallation tasks here>
    # Remove Scheduled Task for Automatic Updates
    Write-ADTLogEntry -Message "Removing scheduled task: WingetAutoUpdate_Notepad" -Severity 1
    
    try {
        $task = Get-ScheduledTask -TaskName "WingetAutoUpdate_Notepad" -ErrorAction SilentlyContinue
        if ($task) {
            Unregister-ScheduledTask -TaskName "WingetAutoUpdate_Notepad" -Confirm:$false
            Write-ADTLogEntry -Message "Scheduled task 'WingetAutoUpdate_Notepad' removed successfully" -Severity 1
        } else {
            Write-ADTLogEntry -Message "Scheduled task 'WingetAutoUpdate_Notepad' not found (already removed or never created)" -Severity 2
        }
    }
    catch {
        Write-ADTLogEntry -Message "Failed to remove scheduled task: $($_.Exception.Message)" -Severity 2
        # Non-critical error: Continue with uninstallation
    }
    
    # ============================================
    # Application Folder Cleanup
    # ============================================
    Write-ADTLogEntry -Message "Cleaning up application folder(s)..." -Severity 1
    
    # Remove application folder: C:\Program Files\Notepad++
    $appFolder = "C:\Program Files\Notepad++"
    if (Test-Path -Path $appFolder) {
        try {
            # Wait a moment for the uninstaller to fully complete
            Start-Sleep -Seconds 2
            
            # Remove the folder and all contents
            Remove-Item -Path $appFolder -Recurse -Force -ErrorAction Stop
            Write-ADTLogEntry -Message "Successfully removed folder: $appFolder" -Severity 1
        }
        catch {
            Write-ADTLogEntry -Message "Failed to remove folder $appFolder : $($_.Exception.Message)" -Severity 2
            # Try removing remaining files individually
            Get-ChildItem -Path $appFolder -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
            Remove-Item -Path $appFolder -Force -ErrorAction SilentlyContinue
        }
    } else {
        Write-ADTLogEntry -Message "Folder not found (already removed): $appFolder" -Severity 1
    }
    
}

function Repair-ADTDeployment
{
    [CmdletBinding()]
    param
    (
    )

    ##================================================
    ## MARK: Pre-Repair
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

    ## If there are processes to close, show Welcome Message with a 60 second countdown before automatically closing.
    if ($adtSession.AppProcessesToClose.Count -gt 0)
    {
        Show-ADTInstallationWelcome -CloseProcesses $adtSession.AppProcessesToClose -CloseProcessesCountdown 60
    }

    ## Show Progress Message (with the default message).
    Show-ADTInstallationProgress

    ## <Perform Pre-Repair tasks here>


    ##================================================
    ## MARK: Repair
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    ## Handle Zero-Config MSI repairs.
    if ($adtSession.UseDefaultMsi)
    {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile)
        {
            $ExecuteDefaultMSISplat.Add('Transforms', $adtSession.DefaultMstFile)
        }
        Start-ADTMsiProcess @ExecuteDefaultMSISplat
    }

    ## <Perform Repair tasks here>


    ##================================================
    ## MARK: Post-Repair
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    ## <Perform Post-Repair tasks here>
}


##================================================
## MARK: Initialization
##================================================

# Set strict error handling across entire operation.
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
Set-StrictMode -Version 1

# Import the module and instantiate a new session.
try
{
    # Import the module locally if available, otherwise try to find it from PSModulePath.
    if (Test-Path -LiteralPath "$PSScriptRoot\AppDeployToolkit\PSAppDeployToolkit.psd1" -PathType Leaf)
    {
        Get-ChildItem -LiteralPath "$PSScriptRoot\AppDeployToolkit" -Recurse -File | Unblock-File -ErrorAction Ignore
        Import-Module -FullyQualifiedName @{ ModuleName = "$PSScriptRoot\AppDeployToolkit\PSAppDeployToolkit.psd1"; Guid = '8c3c366b-8606-4576-9f2d-4051144f7ca2'; ModuleVersion = '4.1.8' } -Force
    }
    else
    {
        Import-Module -FullyQualifiedName @{ ModuleName = 'PSAppDeployToolkit'; Guid = '8c3c366b-8606-4576-9f2d-4051144f7ca2'; ModuleVersion = '4.1.8' } -Force
    }

    # Open a new deployment session, replacing $adtSession with a DeploymentSession.
    $iadtParams = Get-ADTBoundParametersAndDefaultValues -Invocation $MyInvocation
    $adtSession = Remove-ADTHashtableNullOrEmptyValues -Hashtable $adtSession
    $adtSession = Open-ADTSession @adtSession @iadtParams -PassThru
}
catch
{
    $Host.UI.WriteErrorLine((Out-String -InputObject $_ -Width ([System.Int32]::MaxValue)))
    exit 60008
}


##================================================
## MARK: Invocation
##================================================

# Commence the actual deployment operation.
try
{
    # Import any found extensions before proceeding with the deployment.
    Get-ChildItem -LiteralPath $PSScriptRoot -Directory | & {
        process
        {
            if ($_.Name -match 'PSAppDeployToolkit\..+$')
            {
                Get-ChildItem -LiteralPath $_.FullName -Recurse -File | Unblock-File -ErrorAction Ignore
                Import-Module -Name $_.FullName -Force
            }
        }
    }

    # Invoke the deployment and close out the session.
    & "$($adtSession.DeploymentType)-ADTDeployment"
    Close-ADTSession
}
catch
{
    # An unhandled error has been caught.
    $mainErrorMessage = "An unhandled error within [$($MyInvocation.MyCommand.Name)] has occurred.`n$(Resolve-ADTErrorRecord -ErrorRecord $_)"
    Write-ADTLogEntry -Message $mainErrorMessage -Severity 3

    ## Error details hidden from the user by default. Show a simple dialog with full stack trace:
    # Show-ADTDialogBox -Text $mainErrorMessage -Icon Stop -NoWait

    ## Or, a themed dialog with basic error message:
    # Show-ADTInstallationPrompt -Message "$($adtSession.DeploymentType) failed at line $($_.InvocationInfo.ScriptLineNumber), char $($_.InvocationInfo.OffsetInLine):`n$($_.InvocationInfo.Line.Trim())`n`nMessage:`n$($_.Exception.Message)" -ButtonRightText OK -Icon Error -NoWait

    Close-ADTSession -ExitCode 60001
}

