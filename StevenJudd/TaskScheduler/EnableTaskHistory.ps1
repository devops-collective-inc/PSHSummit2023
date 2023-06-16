$logName = 'Microsoft-Windows-TaskScheduler/Operational'
$log = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $logName
if($log.IsEnabled -eq $false){
  $log.IsEnabled = $true
  $log.SaveChanges()
}
