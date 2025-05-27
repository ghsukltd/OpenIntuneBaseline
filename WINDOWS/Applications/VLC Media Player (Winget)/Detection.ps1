## Reviewed 20/02/2025
## Version 1.0
## Template Revision 1.0


#---------- Common Script Variables ----------#
$PackageName = "VideoLAN.VLC"
$Scope = "machine"
#$Scope = "user"

#---------- Code ----------#
$ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"
    if ($ResolveWingetPath){
           $WingetPath = $ResolveWingetPath[-1].Path
    } else {
        Write-Host "Failed to find Winget"
        exit 1
}
Set-Location $wingetpath
$InstalledApps = .\winget.exe list --id $PackageName -e --scope $Scope --accept-source-agreements --disable-interactivity 

if (!($InstalledApps[$InstalledApps.count-1] -eq "No installed package found matching input criteria.")) {
    Write-Output "OK! - Found install"
    Exit 0
}

Write-Output "ERROR! - Install not found"
Exit 1