## Reviewed 20/02/2025
## Template Revision 1.1

#---------- Script Variables ----------#
$PackageName = "Google.Chrome"
$Scope = "machine"
#$Scope = "user"
$ScriptVersion = "v1.0"

#---------- Common Script Variables ----------#
$GHSKey = "HKLM:\SOFTWARE\GHS"
$GHSDir = "$($ENV:ALLUSERSPROFILE)\GHS"
$LogsDir = "$($GHSDir)\Logs"
$LogFile = "$($LogsDir)\App_Winget_$($PackageName).log"
$ShowConsoleOutput = $true #log to console & log file

#---------- Functions ----------#
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

# Logging start of script
Add-LogMessage -message "----------------------------------------------------------"
Add-LogMessage -message "Starting script: Winget Uninstall for $($PackageName) - $($ScriptVersion)"

#---------- Script Content Here! ----------#

$ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
    if ($ResolveWingetPath){
           $WingetPath = $ResolveWingetPath[-1].Path
    } else {
        Add-LogMessage -Message "Failed to find Winget" -fout
        exit 1
}
$Wingetpath = Split-Path -Path $WingetPath -Parent
Set-Location $wingetpath

#Detect Apps
$InstalledApps = .\winget.exe list --id $PackageName -e --scope $Scope --accept-source-agreements --disable-interactivity

if (!($InstalledApps[$InstalledApps.count-1] -eq "No installed package found matching input criteria.")) {
    Add-LogMessage -Message "Trying to uninstall $($PackageName)"
    try {
        Start-Transcript -Path $LogFile -Append
        .\winget.exe uninstall --id $PackageName -e --scope $Scope -h --accept-source-agreements --disable-interactivity
        Stop-Transcript
    }
    catch {
        Throw "Failed to uninstall $($PackageName)"
    }
} else {
    Add-LogMessage -Message "$($PackageName) is not installed or detected"
}

#---------- Script End ----------#

# Logging completion of script
Add-LogMessage -message "Ending script"