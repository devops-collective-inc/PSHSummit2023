#region Create a scheduled task to run at logon
# Taken from the New-ScheduledTask Help example 1
# Changed Principal from $principal = "Contoso\Administrator" because IT DOESN'T WORK!
# Also added a TaskPath for this Demo
# Wait-Debugger
$action = New-ScheduledTaskAction -Execute "Taskmgr.exe"
$trigger = New-ScheduledTaskTrigger -AtLogon
$principal = New-ScheduledTaskPrincipal -GroupId 'BUILTIN\Administrators' -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet
$task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
Register-ScheduledTask TaskMgrOnLogon -InputObject $task -TaskPath 'Demo'
Wait-Debugger
#endregion Create a scheduled task to run at logon

#region Create a scheduled task to run every day
# F5
$NewScheduledTaskActionParam = @{
  Execute  = 'Powershell.exe'
  Argument = @(
    '-NoProfile'
    '-File C:\Users\steve\OneDrive\Documents\Summit2023\TaskScheduler\TaskThatTakes30Minutes.ps1'
  ) -join ' '
}
$action = New-ScheduledTaskAction @NewScheduledTaskActionParam
$trigger = New-ScheduledTaskTrigger -Daily -At '00:00'
$settings = New-ScheduledTaskSettingsSet
$RegisterScheduledTaskParam = @{
  Action = $action
  Trigger = $trigger
  TaskName = 'DailyTaskAtMidnight'
  Description = 'Run TaskThatTakes30Minutes.ps1'
  Settings = $settings
  TaskPath = 'Demo'
}
Register-ScheduledTask @RegisterScheduledTaskParam
Wait-Debugger
#endregion

#region Create a scheduled task that fails
# F5
$NewScheduledTaskActionParam = @{
  Execute  = 'Powershell.exe'
  Argument = @(
    '-NoProfile'
    '-WindowStyle Hidden'
    '-File C:\Users\steve\OneDrive\Documents\Summit2023\TaskScheduler\Chad.ps1'
  ) -join ' '
}
$action = New-ScheduledTaskAction @NewScheduledTaskActionParam
$repIntvl = New-TimeSpan -Minutes 5
# $repDur = New-TimeSpan -Days 1
$trigger = New-ScheduledTaskTrigger -Once -At '00:00' -RepetitionInterval $repIntvl #-RepetitionDuration $repDur
# Do yourself a favor and start your repeating jobs at midnight not 9:38a
# Do yourself another favor and discourage the use of repetition duration
$settings = New-ScheduledTaskSettingsSet
$RegisterScheduledTaskParam = @{
  Action      = $action
  Trigger     = $trigger
  TaskName    = 'Chad-Unreasonable'
  Description = 'Run Chad.ps1 using defaults'
  Settings    = $settings
  TaskPath    = 'Demo'
}
Register-ScheduledTask @RegisterScheduledTaskParam
Wait-Debugger
#endregion

#region Create a scheduled task that fails in a reasonable time
# F5
$NewScheduledTaskActionParam = @{
  Execute  = 'Powershell.exe'
  Argument = @(
    '-NoProfile'
    '-WindowStyle Hidden'
    '-File C:\Users\steve\OneDrive\Documents\Summit2023\TaskScheduler\Chad.ps1'
  ) -join ' '
}
$action = New-ScheduledTaskAction @NewScheduledTaskActionParam
$repIntvl = New-TimeSpan -Minutes 5
$trigger = New-ScheduledTaskTrigger -Once -At '00:00' -RepetitionInterval $repIntvl
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit $repIntvl.Subtract($(New-TimeSpan -Minutes 1))
$RegisterScheduledTaskParam = @{
  Action      = $action
  Trigger     = $trigger
  TaskName    = 'Chad-Reasonable'
  Description = 'Run Chad.ps1 and stop before the next run'
  Settings    = $settings
  TaskPath    = 'Demo'
}
Register-ScheduledTask @RegisterScheduledTaskParam
Wait-Debugger

#endregion

Write-Host "Return to the slides" -ForegroundColor Magenta
