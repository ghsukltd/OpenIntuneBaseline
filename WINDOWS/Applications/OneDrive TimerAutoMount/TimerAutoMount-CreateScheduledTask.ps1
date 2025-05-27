#############################################################
#Set Values of Scheduled Task 
#############################################################

$TaskName = "OneDrive TimerAutoMount"
Get-ScheduledTask | Where-Object {$_.TaskName -eq "$TaskName"} | Unregister-ScheduledTask -confirm:$false
$action = New-ScheduledTaskAction -Execute 'reg.exe' -Argument 'add "HKCU\Software\Microsoft\OneDrive\Accounts\Business1" /v Timerautomount /t REG_QWORD /d 1 /f'
$trigger = New-ScheduledTaskTrigger -AtLogon
$principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users"
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
Register-ScheduledTask -TaskName $TaskName -Trigger $trigger -Principal $principal -Action $action -Settings $settings


#############################################################
# Run Scheduled Task
#############################################################
try {
    Start-ScheduledTask -TaskName $TaskName
}
catch {
    Write-Host $Error
    Exit 2000
}