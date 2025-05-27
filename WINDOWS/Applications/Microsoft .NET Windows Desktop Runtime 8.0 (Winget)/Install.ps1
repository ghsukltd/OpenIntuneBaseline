## Reviewed 20/02/2025
## Template Revision 1.1

#---------- Script Variables ----------#
$PackageName = "Microsoft.DotNet.DesktopRuntime.8"
$ScriptVersion = "v1.1"

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
Add-LogMessage -message "Starting script: Winget Install for $($PackageName) - $($ScriptVersion)"

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

#Trying to install Package with Winget
if ($PackageName) {
    try {
        Add-LogMessage -Message "Installing $($PackageName) via Winget"
        Start-Transcript -Path $LogFile -Append
        .\winget.exe install --id $PackageName -e -h --accept-package-agreements --accept-source-agreements --disable-interactivity
        Stop-Transcript
    } Catch {
        Add-LogMessage -Message "Failed to install package $($_)" -fout
    }
} else {
    Add-LogMessage -Message "Package $($PackageName) not available" -fout
}

#---------- Script End ----------#

# Logging completion of script
Add-LogMessage -message "Ending script"