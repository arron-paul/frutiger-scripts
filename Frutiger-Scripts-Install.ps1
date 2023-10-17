# Define the Scheduled Task
$TaskActionParams = @{
  Execute = 'PowerShell.exe'
  Argument = "-NoProfile -ExecutionPolicy Bypass -File ""$PSScriptRoot\Frutiger-Scripts.ps1"""
}
$TaskAction = New-ScheduledTaskAction @TaskActionParams

# Define Triggers
$TaskTrigger = New-ScheduledTaskTrigger -AtStartup

# Register the Scheduled Task
Register-ScheduledTask `
  -Action $TaskAction `
  -Trigger $TaskTrigger `
  -TaskName "Frutiger Scripts" `
  -User ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name) `
  -RunLevel "Highest" -Force
