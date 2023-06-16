# Let's build a custom object from our tasks

# $taskInfoAll = Get-ScheduledTask
# $taskInfoAll
$taskInfo = Get-ScheduledTask | Where-Object {
  $_.TaskPath -eq '\' -and
  $_.TaskName -NotMatch 'MicrosoftEdgeUpdate'
}
# $taskInfo

$taskInfoFlat = foreach ($item in $taskInfo){
  [PSCustomObject]@{
  State                                   = $item.State
  # Actions                               = $item.Actions
  ActionsId                               = $item.Actions.Id
  ActionsArguments                        = $item.Actions.Arguments
  ActionsExecute                          = $item.Actions.Execute
  ActionsWorkingDirectory                 = $item.Actions.WorkingDirectory
  ActionsPSComputerName                   = $item.Actions.PSComputerName
  Author                                  = $item.Author
  Date                                    = $item.Date
  Description                             = $item.Description
  Documentation                           = $item.Documentation
  # Principal                             = $item.Principal
  PrincipalDisplayName                    = $item.Principal.DisplayName
  PrincipalGroupId                        = $item.Principal.GroupId
  PrincipalId                             = $item.Principal.Id
  PrincipalLogonType                      = $item.Principal.LogonType
  PrincipalRunLevel                       = $item.Principal.RunLevel
  PrincipalUserId                         = $item.Principal.UserId
  PrincipalProcessTokenSidType            = $item.Principal.ProcessTokenSidType
  PrincipalRequiredPrivilege              = $item.Principal.RequiredPrivilege
  PrincipalPSComputerName                 = $item.Principal.PSComputerName
  SecurityDescriptor                      = $item.SecurityDescriptor
  # Settings                              = $item.Settings
  SettingsAllowDemandStart                = $item.Settings.AllowDemandStart
  SettingsAllowHardTerminate              = $item.Settings.AllowHardTerminate
  SettingsCompatibility                   = $item.Settings.Compatibility
  SettingsDeleteExpiredTaskAfter          = $item.Settings.DeleteExpiredTaskAfter
  SettingsDisallowStartIfOnBatteries      = $item.Settings.DisallowStartIfOnBatteries
  SettingsEnabled                         = $item.Settings.Enabled
  SettingsExecutionTimeLimit              = $item.Settings.ExecutionTimeLimit
  SettingsHidden                          = $item.Settings.Hidden
  # SettingsIdleSettings                  = $item.Settings.IdleSettings
  SettingsIdleSettingsIdleDuration        = $item.Settings.IdleSettings.IdleDuration
  SettingsIdleSettingsRestartOnIdle       = $item.Settings.IdleSettings.RestartOnIdle
  SettingsIdleSettingsStopOnIdleEnd       = $item.Settings.IdleSettings.StopOnIdleEnd
  SettingsIdleSettingsWaitTimeout         = $item.Settings.IdleSettings.WaitTimeout
  SettingsIdleSettingsPSComputerName      = $item.Settings.IdleSettings.PSComputerName
  SettingsMultipleInstances               = $item.Settings.MultipleInstances
  # SettingsNetworkSettings               = $item.Settings.NetworkSettings
  SettingsNetworkSettingsId               = $item.Settings.NetworkSettings.Id
  SettingsNetworkSettingsName             = $item.Settings.NetworkSettings.Name
  SettingsNetworkSettingsPSComputerName   = $item.Settings.NetworkSettings.PSComputerName
  SettingsPriority                        = $item.Settings.Priority
  SettingsRestartCount                    = $item.Settings.RestartCount
  SettingsRestartInterval                 = $item.Settings.RestartInterval
  SettingsRunOnlyIfIdle                   = $item.Settings.RunOnlyIfIdle
  SettingsRunOnlyIfNetworkAvailable       = $item.Settings.RunOnlyIfNetworkAvailable
  SettingsStartWhenAvailable              = $item.Settings.StartWhenAvailable
  SettingsStopIfGoingOnBatteries          = $item.Settings.StopIfGoingOnBatteries
  SettingsWakeToRun                       = $item.Settings.WakeToRun
  SettingsDisallowStartOnRemoteAppSession = $item.Settings.DisallowStartOnRemoteAppSession
  SettingsUseUnifiedSchedulingEngine      = $item.Settings.UseUnifiedSchedulingEngine
  SettingsMaintenanceSettings             = $item.Settings.MaintenanceSettings
  SettingsVolatile                        = $item.Settings.volatile
  SettingsPSComputerName                  = $item.Settings.PSComputerName
  Source                                  = $item.Source
  TaskName                                = $item.TaskName
  TaskPath                                = $item.TaskPath
  # Triggers                              = $item.Triggers
  TriggersEnabled                         = $item.Triggers.Enabled
  TriggersEndBoundary                     = $item.Triggers.EndBoundary
  TriggersExecutionTimeLimit              = $item.Triggers.ExecutionTimeLimit
  TriggersId                              = $item.Triggers.Id
  TriggersStartBoundary                   = $item.Triggers.StartBoundary
  TriggersRandomDelay                     = $item.Triggers.RandomDelay
  TriggersPSComputerName                  = $item.Triggers.PSComputerName
  # TriggersRepetition                    = $item.Triggers.Repetition
  TriggersRepetitionDuration              = $item.Triggers.Repetition.Duration
  TriggersRepetitionInterval              = $item.Triggers.Repetition.Interval
  TriggersRepetitionStopAtDurationEnd     = $item.Triggers.Repetition.StopAtDurationEnd
  URI                                     = $item.URI
  Version                                 = $item.Version
  PSComputerName                          = $item.PSComputerName
  }
}

# Compare the tasks
$taskinfoflat | Select-Object TaskName, State, SettingsExecutionTimeLimit, SettingsIdleSettingsRestartOnIdle,
  SettingsAllowHardTerminate, SettingsMultipleInstances, SettingsRestartInterval, SettingsRestartCount,
  SettingsRunOnlyIfIdle, TriggersEnabled, TriggersExecutionTimeLimit, TriggersStartBoundary, TriggersRandomDelay,
  TriggersRepetitionInterval, TriggersRepetitionDuration, TriggersRepetitionStopAtDurationEnd | Out-GridView
Wait-Debugger # review Out-GridView then F10

# Only return tasks that use the default time limit
$taskInfoFlat |
  Where-Object SettingsExecutionTimeLimit -eq 'PT72H' |
  Select-Object TaskName, SettingsExecutionTimeLimit, Description |
  Format-Table -AutoSize


# There's more than one ExecutionTimeLimit
$taskInfoFlat |
  Where-Object SettingsExecutionTimeLimit -eq 'PT72H' |
  Select-Object TaskName, SettingsExecutionTimeLimit, TriggersExecutionTimeLimit, Description |
  Format-Table -AutoSize
# but you can only set the Settings.ExecutionTimeLimit using New-ScheduledTaskSettingsSet

# Find tasks with more than one trigger
# $taskInfoFlat |
#   Where-Object {
#     $_.SettingsExecutionTimeLimit -EQ 'PT72H' -and
#     $_.TriggersExecutionTimeLimit -is [Array]
#   } |
#   Select-Object TaskName, SettingsExecutionTimeLimit, TriggersExecutionTimeLimit, Description |
#   Format-Table -AutoSize

# List the task and each individual trigger
$multiTriggersTasks = $taskInfo |
  Where-Object {
    $_.Settings.ExecutionTimeLimit -EQ 'PT72H' -and
    $_.Triggers.count -gt 1
  }
$multiOutput = foreach ($trigger in $multiTriggersTasks.Triggers){ #F5
  [PSCustomObject]@{
    TaskName = $multiTriggersTasks.TaskName
    State = $multiTriggersTasks.State
    SettingsExecutionTimeLimit = $multiTriggersTasks.Settings.ExecutionTimeLimit
    SettingsIdleSettingsRestartOnIdle = $multiTriggersTasks.Settings.IdleSettings.RestartOnIdle
    SettingsAllowHardTerminate = $multiTriggersTasks.SettingsAllowHardTerminate
    SettingsMultipleInstances = $multiTriggersTasks.Settings.MultipleInstances
    SettingsRestartInterval = $multiTriggersTasks.Settings.RestartInterval
    SettingsRestartCount = $multiTriggersTasks.Settings.RestartCount
    SettingsRunOnlyIfIdle = $multiTriggersTasks.Settings.RunOnlyIfIdle
    TriggersEnabled = $trigger.Triggers
    TriggersExecutionTimeLimit = $trigger.ExecutionTimeLimit
    TriggersStartBoundary = $trigger.StartBoundary
    TriggersRandomDelay = $trigger.RandomDelay
    TriggersRepetitionInterval = $trigger.Repetition.Interval
    TriggersRepetitionDuration = $trigger.Repetition.Duration
    TriggersRepetitionStopAtDurationEnd = $trigger.Repetition.StopAtDurationEnd
  }
}
$multiOutput | Out-GridView
Wait-Debugger # review Out-GridView then F10

# yet another problem: What kind of trigger is it?
# Trigger from UI                   Trigger from PowerShell
# ---------------                   -----------------------
# One time                          One time
# Daily                             Daily
# Weekly                            Weekly
# Monthly
# At log on                         At log on
# At startup                        At startup
# On idle
# On an event                      
# At task creation/modification    
# On connection to user session    
# On disconnect from user session  
# On workstation lock
# On workstation unlock

Write-Host "Return to the slides" -ForegroundColor Magenta
