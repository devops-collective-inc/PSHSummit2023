# Cleanup
Get-ScheduledTask -TaskPath '\Demo\' | Unregister-ScheduledTask -PassThru -Confirm:$false
Get-ScheduledTask -TaskPath '\Demo\'
# Disable Scripts
$tasksToDisable = @(
  'Chad-Reasonable'
  'Chad-Unreasonable'
  'DailyTaskAtMidnight'
  'Demo1'
  'EnableTaskHistory'
  'Test1'
  'Test2'
  'Test3'
  'Test4'
  'Test5'
  'Test6'
  'Test7'
)
foreach ($task in $tasksToDisable){
  Disable-ScheduledTask -TaskName $task -TaskPath '\'
}