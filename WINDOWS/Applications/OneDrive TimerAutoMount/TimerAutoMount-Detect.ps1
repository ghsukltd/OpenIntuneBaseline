# Detection script for Intune Win32 app

$TaskName = "OneDrive TimerAutoMount"

# Check if the scheduled task exists
$scheduledTask = Get-ScheduledTask | Where-Object {$_.TaskName -eq $TaskName}

if ($null -ne $scheduledTask) {
    # Verify the action, trigger, and principal settings
    $action = $scheduledTask.Actions | Where-Object { $_.Execute -eq "reg.exe" -and $_.Arguments -eq 'add "HKCU\Software\Microsoft\OneDrive\Accounts\Business1" /v Timerautomount /t REG_QWORD /d 1 /f' }
    $principal = $scheduledTask.Principal.GroupId -eq "Users"
    
    if ($null -ne $action -and $principal) {
        # Task exists and has the correct settings
        Write-Output "Task Exists and is correct"
        Exit 0
    }
}

# If the task does not exist or is misconfigured, the app is not installed correctly
Write-Output "Detection failed"
Exit 1
