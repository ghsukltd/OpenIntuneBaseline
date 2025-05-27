## Reviewed 12/03/2025
## Template Revision 1.1
# Dell Command Update Settings Apply

# ---------- Script Variables ---------- #
$ScriptName = "DellCommandUpdateSettings"
$ScriptVersion = "v1.0"

# Variables
$DCUCMD = "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
$biosPassword = ""

# Common Variables
$GHSKey = "HKLM:\SOFTWARE\GHS"
$GHSDir = "$($ENV:ALLUSERSPROFILE)\GHS"
$LogsDir = "$GHSDir\Logs"
$LogFile = "$LogsDir\$ScriptName.log"
$ShowConsoleOutput = $true # Log to both console & log file

# ---------- Functions ---------- #
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

function Get-DellUpdateRegistry {
    $regPath = "HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule"
    
    # Check if the registry path exists
    if (Test-Path $regPath) {
        # Retrieve the values from the registry
        $regValues = Get-ItemProperty -Path $regPath

        # Check if all the required values match
        if ($regValues.AutomationMode -eq "ScanDownloadApplyNotify" -and
            $regValues.SystemRestartDeferral -eq 1 -and
            $regValues.DeferRestartInterval -eq "8" -and
            $regValues.DeferRestartCount -eq "4") {
            
            # Return success if all values match
            return $true
        }
        else {
            # Return failure if any value does not match
            return $false
        }
    }
    else {
        # Return failure if the registry path does not exist
        return $false
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

# ---------- Script Content ---------- #
# Check if required executables exist
if (-not (Test-Path $DCUCMD)) {
    Add-LogMessage -Message "Required file not found: $DCUCMD" -fout
    Exit 1
}

# Verify settings
if (Get-DellUpdateRegistry) {
    Add-LogMessage -Message "OK: Settings are as expected."
    Exit 0
}

# If settings are not in place, apply...
Add-LogMessage -Message "Attempting to set Dell Command Update settings..."
& $DCUCMD /configure -importSettings="$PSScriptRoot\DCU-Settings.xml"
& $DCUCMD /configure -biosPassword="$biosPassword"

# Wait a few seconds to ensure settings complete
Start-Sleep -Seconds 5

# Verify settings again
if (Get-DellUpdateRegistry) {
    Add-LogMessage -Message "OK: Settings are as expected."
    Exit 0
} else {
    Add-LogMessage -Message "Registry values are incorrect or missing." -fout
    Exit 1
}

# ---------- Script End ---------- #
Add-LogMessage -Message "Ending script"