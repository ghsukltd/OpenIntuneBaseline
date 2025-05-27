## Reviewed 14/02/2025 - Windows 11 24H2
## Version 2.7
## Template Revision 1.0

#---------- Script Variables ----------#
$ScriptName = "RemoveAppxPackages"
$allowedApps = @(
	'1527c705-839a-4832-9118-54d4Bd6a0c89',
	'AD2F1837.HPSystemInformation',
	'AdobeAcrobatReaderCoreApp',
	'AdobeNotificationClient',
	'AdvancedMicroDevicesInc*',
	'AppUp.IntelGraphicsExperience',
	'AppUp.IntelOptaneMemoryandStorageManagement',
	'c5e2524a-ea46-4f67-841f-6a9465d9d515',
	'DellInc.DellCommandUpdate',
	'E2A4F912-2574-4A75-9BB0-0D023378592B',
	'F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE',
	'Microsoft.549981C3F5F10',
	'Microsoft.AAD.BrokerPlugin',
	'Microsoft.AccountsControl',
	'Microsoft.Advertising.Xaml',
	'Microsoft.ApplicationCompatibilityEnhancements',
	'Microsoft.AsyncTextService',
	'Microsoft.AV1VideoExtension',
	'Microsoft.AVCEncoderVideoExtension',
	'Microsoft.BingNews',
	'Microsoft.BingSearch',
	'Microsoft.BingWeather',
	'Microsoft.BioEnrollment',
	'Microsoft.CompanyPortal',
	'Microsoft.Copilot',
	'Microsoft.CredDialogHost',
	'Microsoft.DesktopAppInstaller',
	'Microsoft.ECApp',
	'Microsoft.GamingApp',
	'Microsoft.GetHelp',
	'Microsoft.Getstarted',
	'Microsoft.HEIFImageExtension',
	'Microsoft.HEVCVideoExtension',
	'Microsoft.LanguageExperiencePacken-GB',
	'Microsoft.LockApp',
	'Microsoft.Microsoft3DViewer',
	'Microsoft.MicrosoftEdge',
	'Microsoft.MicrosoftEdge.Stable',
	'Microsoft.MicrosoftEdgeDevToolsClient',
	'Microsoft.MicrosoftStickyNotes',
	'Microsoft.MixedReality.Portal',
	'Microsoft.MPEG2VideoExtension',
	'Microsoft.MSPaint',
	'Microsoft.NET.Native*',
	'Microsoft.OneDriveSync',
	'Microsoft.OutlookForWindows',
	'Microsoft.Paint',
	'Microsoft.People',
	'Microsoft.PowerToys*',
	'Microsoft.RawImageExtension',
	'Microsoft.RemoteDesktop',
	'Microsoft.ScreenSketch',
	'Microsoft.SecHealthUI',
	'Microsoft.Services.Store.Engagement',
	'Microsoft.StorePurchaseApp',
	'Microsoft.Todos',
	'Microsoft.UI.Xaml.*',
	'Microsoft.VCLibs.*',
	'Microsoft.VP9VideoExtensions',
	'Microsoft.Wallet',
	'Microsoft.WebMediaExtensions',
	'Microsoft.WebpImageExtension',
	'Microsoft.WidgetsPlatformRuntime',
	'Microsoft.Win32WebViewHost',
	'Microsoft.WinAppRuntime*',
	'Microsoft.Windows.Apprep.ChxApp',
	'Microsoft.Windows.AssignedAccessLockApp',
	'Microsoft.Windows.AugLoop.CBS',
	'Microsoft.Windows.CallingShellApp',
	'Microsoft.Windows.CapturePicker',
	'Microsoft.Windows.CloudExperienceHost',
	'Microsoft.Windows.ContentDeliveryManager',
	'Microsoft.Windows.DevHome',
	'Microsoft.Windows.NarratorQuickStart',
	'Microsoft.Windows.OOBENetworkCaptivePortal',
	'Microsoft.Windows.OOBENetworkConnectionFlow',
	'Microsoft.Windows.ParentalControls',
	'Microsoft.Windows.PeopleExperienceHost',
	'Microsoft.Windows.Photos',
	'Microsoft.Windows.PinningConfirmationDialog',
	'Microsoft.Windows.PrintQueueActionCenter',
	'Microsoft.Windows.Search',
	'Microsoft.Windows.SecHealthUI',
	'Microsoft.Windows.SecureAssessmentBrowser',
	'Microsoft.Windows.ShellExperienceHost',
	'Microsoft.Windows.StartMenuExperienceHost',
	'Microsoft.Windows.XGpuEjectDialog',
	'Microsoft.WindowsAlarms',
	'Microsoft.WindowsAppRuntime*',
	'Microsoft.WindowsCalculator',
	'Microsoft.WindowsCamera',
	'Microsoft.WindowsFeedbackHub',
	'Microsoft.WindowsMaps',
	'Microsoft.WindowsNotepad',
	'Microsoft.WindowsSoundRecorder',
	'Microsoft.WindowsStore',
	'Microsoft.WindowsTerminal',
	'Microsoft.Winget.Source',
	'Microsoft.Xbox.TCUI',
	'Microsoft.XboxGameCallableUI',
	'Microsoft.XboxGameOverlay',
	'Microsoft.XboxGamingOverlay',
	'Microsoft.XboxIdentityProvider',
	'Microsoft.XboxSpeechToTextOverlay',
	'Microsoft.YourPhone',
	'Microsoft.ZuneMusic',
	'Microsoft.ZuneVideo',
	'MicrosoftCorporationII.QuickAssist',
	'MicrosoftCorporationII.WinAppRuntime*',
	'MicrosoftCorporationII.Windows365',
	'MicrosoftCorporationII.WindowsAppRuntime*',
	'MicrosoftTeams',
	'MicrosoftWindows.Client.*',
	'MicrosoftWindows.CrossDevice',
	'MicrosoftWindows.LKG.*',
	'MicrosoftWindows.UndockedDevKit',
	'MSTeams',
	'NcsiUwpApp',
	'NotepadPlusPlus',
	'RealtekSemiconductorCorp.*',
	'Windows.CBSPreview',
	'windows.immersivecontrolpanel',
	'Windows.PrintDialog',
	'AppUp.ThunderboltControlCenter*',
	'MicrosoftWindows.Speech*',
	'AD2F1837.HPProgrammableKey',
	'AD2F1837.myHP'
	)

#---------- Common Script Variables ----------#
$GHSKey = "HKCU:\SOFTWARE\GHS"
$GHSDir = "$($ENV:LOCALAPPDATA)\GHS"
$LogsDir = "$($GHSDir)\Logs"
$LogFile = "$($LogsDir)\$($scriptName).log"
$ShowConsoleOutput = $true #log to console & log file

#---------- Functions ----------#
# Function to Check Script Status
function Get-ScriptStatus {
    param ($ScriptName)
    try {
        return $null -ne (Get-ItemProperty -Path $GHSKey -Name $scriptName -ErrorAction Stop).$scriptName
    } catch {
        return $false
    }
}

# Function to Mark Script as Ran
function Set-ScriptStatus {
    param (
        [Parameter(Mandatory=$true)][string]$ScriptName
    )
    New-ItemProperty -Path $GHSKey -Name $ScriptName -Value "1" -PropertyType "String" | Out-Null
}

# Function to Log Messages
function Add-LogMessage {
    param (
        [Parameter(Mandatory=$true)][string]$Message,
        [Switch]$fout,
        [Switch]$warning
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    if($fout){
        $Message = "$($timestamp) | ERROR | $($Message)"
    }
    elseif($warning){
        $Message = "$($timestamp) | WARNING | $($Message)"
    }
    else{
        $Message = "$($timestamp) | INFO | $($Message)"
    }
    try{
        Add-Content $LogFile $Message
    }catch{$Null}
    if ($ShowConsoleOutput) {
        if ($fout) {
            Write-Host $Message -ForegroundColor Red
        } elseif ($warning) {
            Write-Host $Message -ForegroundColor Yellow
        } else {
            Write-Host $Message -ForegroundColor Green
        }
    }
}

#---------- Script Start / Initialisation ----------#
# Check if common areas exist, if not create
if (-not (Test-Path $GHSKey)) { New-Item -Path $GHSKey | Out-Null }
if (-not (Test-Path $GHSDir)) { New-Item -Path $GHSDir -ItemType Directory -Force | Out-Null }
if (-not (Test-Path $LogsDir)) { New-Item -Path $LogsDir -ItemType Directory -Force | Out-Null }

# Check Log File Size
if (Test-Path $LogFile) {
    if ((Get-Item $LogFile).Length -gt 2MB) {
        Rename-Item $LogFile "$LogFile.bak" -Force
    }
}

# Exit if Script Already Ran
if (Get-ScriptStatus $ScriptName) { exit }

# Logging start of script
Add-LogMessage -message "----------------------------------------------------------"
Add-LogMessage -message "Starting script: $($ScriptName)"

# Remove Majority of Default Windows Apps
$ErrorActionPreference= 'silentlycontinue'
Add-LogMessage -message "Removing User App Packages"
$allInstalledApps = Get-AppxPackage
foreach ($app in $allInstalledApps) {
	if (-not ($allowedApps | Where-Object { $app.Name -match $_ })) {
		Add-LogMessage -message "Removing app: $($app.Name) aka $($app)"
		Remove-AppxPackage $app
	}
}

#---------- Script End ----------#

Set-ScriptStatus $ScriptName

# Logging completion of script
Add-LogMessage -message "Ending script"