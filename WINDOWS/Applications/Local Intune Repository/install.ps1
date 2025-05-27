## Reviewed 12/02/2025
## Version 2.0
## Template Revision 1.0


#---------- Common Script Variables ----------#
$ScriptName = "intuneRepositorySetup"
$GHSKey = "HKLM:\SOFTWARE\GHS"
$GHSDir = "$($ENV:ALLUSERSPROFILE)\GHS"
$LogsDir = "$($GHSDir)\Logs"
$LogFile = "$($LogsDir)\$($scriptName).log"
$RoboCopyLogFile = "$($LogsDir)\$($scriptName)_Robocopy.log"
$ShowConsoleOutput = $true #log to console & log file
$repositoryVersion = "1" #keep to whole numbers
$repositoryDir = "$($GHSDir)\IntuneRepository"

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

# Function to Mark Script as Ran
function Set-ScriptStatus {
    param (
        [Parameter(Mandatory=$true)][string]$ScriptName
    )
    New-ItemProperty -Path $GHSKey -Name $ScriptName -Value "1" -PropertyType "String" | Out-Null
}

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
if (-not (Test-Path $repositoryDir)) { New-Item -Path $repositoryDir -ItemType Directory -Force | Out-Null }

# Check Log File Size
if (Test-Path $LogFile) {
    if ((Get-Item $LogFile).Length -gt 2MB) {
        Rename-Item $LogFile "$LogFile.bak" -Force
    }
}

# Logging start of script
Add-LogMessage -Message "----------------------------------------------------------"
Add-LogMessage -Message "Starting script: $($ScriptName)"
Add-LogMessage -Message "Script Repository Version: $($repositoryVersion)"

#---------- Script Content Here! ----------#

if (Get-ScriptStatus $ScriptName) {
    $currentVersion = (Get-ItemProperty $GHSKey -Name $ScriptName).$ScriptName
    Add-LogMessage -Message "Found installed Version: $($currentVersion)"
	if ($currentVersion -lt $repositoryVersion) {
		Add-LogMessage -Message "Installed but outdated, updating now..."
		robocopy "$($PSScriptRoot)\IntuneRepository" "$($repositoryDir)" /E /COPY:DAT /DCOPY:T /R:3 /W:1 /MIR /LOG:"$($RoboCopyLogFile)" /TEE /TIMFIX /MT
		Set-ItemProperty $GHSKey -Name $ScriptName -Value $repositoryVersion
	} else {
		Add-LogMessage -Message "Up to date, no action to take!"
	}
} else {
    Add-LogMessage -Message "Fresh install"
    robocopy "$($PSScriptRoot)\IntuneRepository" "$($repositoryDir)" /E /COPY:DAT /DCOPY:T /R:3 /W:1 /MIR /LOG:"$($RoboCopyLogFile)" /TEE /TIMFIX /MT
    New-ItemProperty $GHSKey -Name $ScriptName -Value $repositoryVersion -PropertyType DWORD
}

#---------- Script End ----------#

# Logging completion of script
Add-LogMessage -message "Ending script"