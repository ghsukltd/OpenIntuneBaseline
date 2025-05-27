## Reviewed 12/02/2025
## Version 1.2
## Template Revision 1.0
# Dell Command Update Settings Detection

# ---------- Common Script Variables ---------- #
$DCUCMD = "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"

# ---------- Functions ---------- #
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

# ---------- Script Body ---------- #

# Check if SPUCmdLine.exe exists
if (-not (Test-Path $DCUCMD)) {
    Add-LogMessage -Message "Required file not found: $DCUCMD" -fout
    Exit 1
}

# Verify settings
if (Get-DellUpdateRegistry) {
    Write-Output "OK - Values are as expected."
    Exit 0
}

Write-Output "ERROR - Registry values are incorrect or missing."
Exit 1