# Talk through, don't run
Wait-Debugger

#region Enable the task history
wevtutil set-log Microsoft-Windows-TaskScheduler/Operational /enabled:true

# Um, we are PowerShell people (and this is PowerShell-ish)
$logName = 'Microsoft-Windows-TaskScheduler/Operational'
$log = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $logName
$log.IsEnabled = $true
$log.SaveChanges()

# Even better, encode the command to enable Task History and run every minute
# Wait-Debugger
$scriptPath = Join-Path -Path $PSScriptRoot -ChildPath 'EnableTaskHistory.ps1'
$encodedCommand = [Convert]::ToBase64String([IO.File]::ReadAllBytes($scriptPath))
$NewScheduledTaskActionParam = @{
  Execute = 'Powershell.exe'
  Argument = @(
    '-NoProfile'
    '-WindowStyle Hidden'
    "-encodedCommand $encodedCommand"
  ) -join ' '
}
$action = New-ScheduledTaskAction @NewScheduledTaskActionParam
$NewScheduledTaskTrigger = @{
  Once = $true
  At = '00:00'
  RepetitionInterval = (New-TimeSpan -Minutes 1)
  # RepetitionDuration = (New-TimeSpan -Days 1)
}
$trigger = New-ScheduledTaskTrigger @NewScheduledTaskTrigger
$NewScheduledTaskSettingsSetParam = @{
  ExecutionTimeLimit = (New-TimeSpan -Seconds 55)
}
$settings = New-ScheduledTaskSettingsSet @NewScheduledTaskSettingsSetParam
$principal = New-ScheduledTaskPrincipal -UserId 'NT AUTHORITY\SYSTEM' -LogonType ServiceAccount -RunLevel Highest
$NewScheduledTaskParam = @{
  Action      = $action
  Principal   = $principal
  Trigger     = $trigger
  Settings    = $settings
  Description = 'Enable Task History for Scheduled Tasks'
}
$task = New-ScheduledTask @NewScheduledTaskParam
$RegisterScheduledTaskParam = @{
  TaskName    = 'EnableTaskHistory'
  InputObject = $task
}
Register-ScheduledTask @RegisterScheduledTaskParam
#endregion
