## Reviewed 19/05/2025
## Template Revision 1.2

#---------- Script Variables ----------#
$ScriptName = "ResetWindows1011StartupDelay"
$ScriptVersion = "v1.0"

#---------- Common Script Variables ----------#
$GHSKey = "HKCU:\SOFTWARE\GHS"
$GHSDir = "$($ENV:LOCALAPPDATA)\GHS"
$LogsDir = "$($GHSDir)\Logs"
$LogFile = "$($LogsDir)\$($scriptName).log"
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
Add-LogMessage -message "Starting script: $($ScriptName) - $($ScriptVersion)"

#---------- Script Content Here! ----------#

$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize"

# Check and remove "Startupdelayinmsec"
try {
    $props = Get-ItemProperty -Path $registryPath -ErrorAction Stop
    if ($props.PSObject.Properties.Name -contains "Startupdelayinmsec") {
        Add-LogMessage -Message "Found Startupdelayinmsec, removing..."
        Remove-ItemProperty -Path $registryPath -Name "Startupdelayinmsec" -Force
    }
    if ($props.PSObject.Properties.Name -contains "WaitForIdleState") {
        Add-LogMessage -Message "Found WaitForIdleState, removing..."
        Remove-ItemProperty -Path $registryPath -Name "WaitForIdleState" -Force
    }
}
catch {
    # Key doesn't exist or other error, do nothing
}

#---------- Script End ----------#

# Logging completion of script
Add-LogMessage -message "Ending script"