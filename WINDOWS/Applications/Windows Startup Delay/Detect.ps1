## Reviewed 19/05/2025
## Version 1.0
## Template Revision 1.1
# Dectection Script for: Windows 10/11 Startup Delay Removal

$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize"
$startupDelay = Get-ItemProperty -Path $registryPath -Name "Startupdelayinmsec" -ErrorAction SilentlyContinue
$waitForIdle = Get-ItemProperty -Path $registryPath -Name "WaitForIdleState" -ErrorAction SilentlyContinue

if ($startupDelay.Startupdelayinmsec -eq 0 -and $waitForIdle.WaitForIdleState -eq 0) {
    Write-Output "OK! - Found install"
    exit 0
} else {
    Write-Output "ERROR! - Install not found"
    exit 1
}

#------- Detection Script -------#