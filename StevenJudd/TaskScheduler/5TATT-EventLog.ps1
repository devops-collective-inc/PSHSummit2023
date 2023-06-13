# Show the events in Event Log, then come back here
if (-not(Get-Process 'mmc' -ErrorAction SilentlyContinue | Where-Object MainWindowTitle -EQ 'Event Viewer')){
  eventvwr.msc
}
Wait-Debugger #F5

$logName = 'Microsoft-Windows-TaskScheduler/Operational'
$maxEvents = 100
# Getting the events from the EventLog
Get-WinEvent -LogName $logName -MaxEvents $maxEvents
Wait-Debugger #F10

# Get the "Task Triggered" events (ID107)
Get-WinEvent -MaxEvents $maxEvents -FilterHashtable @{
  LogName = $logName
  Id = 107
}

# Get the EnableTaskHistory Task Triggered events
Get-WinEvent -MaxEvents $maxEvents -FilterHashtable @{
  Logname = $logName
  Id = 107
  Message = "*EnableTaskHistory*"
}

# Turns out you can't filter on Message (even though ChatGPT says you can). BRILLIANT!
# What you can filter on using FilterHashtable:
# https://learn.microsoft.com/en-us/powershell/scripting/samples/creating-get-winevent-queries-with-filterhashtable?view=powershell-7.3#hash-table-key-value-pairs

# Correlate the most recent of the completed EnableTaskHistory events with their other events
$events = Get-WinEvent -LogName $logName -MaxEvents 1000
$taskName = 'EnableTaskHistory'
$firstEvent = $events | Where-Object {
  $_.Message -Match $taskName -and
  $_.Id -eq 107
} | Select-Object -First 1 -Skip 1 #added skip 1 to avoid issue with task not yet complete

# Get the Guid
$guid = $firstEvent.ActivityId.Guid

# Return the events
$events | Where-Object Message -Match $guid | Out-Host

# Return how long this job took
$startOfTask = $events | Where-Object {$_.Message -Match $guid -and $_.Id -eq 107}
$endOfTask = $events | Where-Object {$_.Message -Match $guid -and $_.ID -eq 102}
New-TimeSpan $startOfTask.TimeCreated $endOfTask.TimeCreated | Out-Host

#  Return average of how long all the EnableTaskHistory jobs took
# $events = Get-WinEvent -LogName $logName -MaxEvents 1000
# $taskName = 'EnableTaskHistory'
$startEvents = $events | & {
  process {
    if (
      $_.Message -Match $taskName -and
      $_.Id -eq 107
    ){ $_ }
  }
}
# Return the events
#F5
$results = foreach ($item in $startEvents.ActivityId.Guid) {
  $startOfTask = $events | Where-Object { $_.Message -Match $item -and $_.Id -eq 107 }
  $endOfTask = $events | Where-Object { $_.Message -Match $item -and $_.ID -eq 102 }
  $duration = (New-TimeSpan $startOfTask.TimeCreated $endOfTask.TimeCreated).TotalSeconds
  [PSCustomObject]@{
    TaskName = $taskName
    StartTime = $startOfTask.TimeCreated
    Duration = $duration
  }
}
$results | Format-Table

Write-Host "Average time to run $($taskName):" -ForegroundColor Green
($results | Measure-Object -Average Duration).Average

Write-Host "Return to the slides" -ForegroundColor Magenta
