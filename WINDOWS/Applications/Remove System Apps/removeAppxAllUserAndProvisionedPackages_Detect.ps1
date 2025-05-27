## Reviewed 14/02/2025
## Version 1.0
## Template Revision 1.0


#---------- Common Script Variables ----------#
$ScriptName = "RemoveAppxAllUserProvisioned"
$GHSKey = "HKLM:\SOFTWARE\GHS"

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

if (Get-ScriptStatus $ScriptName) {
    Write-Output "OK! - Found run attempt"
    Exit 0
}

Write-Output "ERROR! - Run attempt not found"
Exit 1