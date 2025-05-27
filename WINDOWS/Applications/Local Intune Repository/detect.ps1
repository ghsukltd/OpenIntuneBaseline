## Reviewed 12/02/2025
## Version 2.0
## Template Revision 1.0


#---------- Common Script Variables ----------#
$ScriptName = "intuneRepositorySetup"
$GHSKey = "HKLM:\SOFTWARE\GHS"
$repositoryVersion = "1" #keep to whole numbers

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
    $currentVersion = (Get-ItemProperty $GHSKey -Name $ScriptName).$ScriptName
    if ($currentVersion -ge $repositoryVersion) {
        Write-Output "OK! - Current Version: $($currentVersion) - Script Version: $($repositoryVersion)"
        Exit 0
    }
}

Write-Output "ERROR! - Current Version: $($currentVersion) - Script Version: $($repositoryVersion)"
Exit 1