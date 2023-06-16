# Let's do this!

# Since we can't get what we need from Get-ScheduledTask, we have to become mutants and be Xml-Men
# It's like X-Men but with more letters (ML). 
if($audienceReaction -notmatch '😂|😒'){Write-Host "Continue demo" -ForegroundColor Green}

Wait-Debugger # show some stuff then F5
# Create the XML files from the tasks
$taskInfo = Get-ScheduledTask | Where-Object TaskPath -EQ '\'
foreach ($task in $taskInfo) {
  Write-Host "Processing task: $($task.TaskName)"
  [string]$xml = $task | Export-ScheduledTask
  $xmlFilePath = "xml\$($task.TaskName).xml"
  if(Test-Path -Path $xmlFilePath){
    Set-Content -Value $xml -Path $xmlFilePath -Force
  } else {
    New-Item -Path $xmlFilePath -ItemType File -Value $xml -Force
  }
}

# Wait-Debugger
# $timeToOutput = New-TimeSpan -Days 1
# $dateToOutput = Get-Date -Date (Read-Host -Prompt 'Enter date')
$dateToOutput = Get-Date -Date '4/14/23'
function OutTaskObject {
  param(
    [xml]$XmlContent,
    [datetime]$StartTime,
    [datetime]$DateToOutput
  )
  if ($XmlContent.Task.Triggers.TimeTrigger.ExecutionTimeLimit) {
    # check if there is a task ExecutionTimeLimit
    if ($XmlContent.Task.Settings.ExecutionTimeLimit) {
      # which one has precedence?
      # Trigger has precedence if it is set and Settings is also set
    }
    if ($XmlContent.Task.Triggers.TimeTrigger.ExecutionTimeLimit -eq 'PT0S') {
      $endTime = $DateToOutput.AddMonths(1)
    } else {
      $limit = [System.Xml.XmlConvert]::ToTimeSpan(
        $XmlContent.Task.Triggers.TimeTrigger.ExecutionTimeLimit
      )
      $endTime = $StartTime.Add($limit)
    }
  } elseif ($XmlContent.Task.Triggers.CalendarTrigger.ExecutionTimeLimit) {
    # check if there is a task ExecutionTimeLimit
    if ($XmlContent.Task.Settings.ExecutionTimeLimit) {
      # which one has precedence?
      # Trigger has precedence if it is set and Settings is also set
    }
    if ($XmlContent.Task.Triggers.CalendarTrigger.ExecutionTimeLimit -eq 'PT0S') {
      $endTime = $DateToOutput.AddMonths(1)
    } else {
      $limit = [System.Xml.XmlConvert]::ToTimeSpan(
        $XmlContent.Task.Triggers.CalendarTrigger.ExecutionTimeLimit
      )
      $endTime = $StartTime.Add($Limit)
    }
  } elseif ($XmlContent.Task.Settings.ExecutionTimeLimit) {
    # no Trigger ExecutionTimeLimit but Task ExecutionTimeLimit
    if ($XmlContent.Task.Settings.ExecutionTimeLimit -eq 'PT0S') {
      $endTime = $DateToOutput.AddMonths(1)
    } else {
      $limit = [System.Xml.XmlConvert]::ToTimeSpan(
        $XmlContent.Task.Settings.ExecutionTimeLimit
      )
      $endTime = $StartTime.Add($limit)
    }
  } else {
    # Need an end date of some kind
    $endTime = $DateToOutput.AddMonths(1)
  }
  [PSCustomObject]@{
    URI       = $XmlContent.Task.RegistrationInfo.URI
    StartTime = $StartTime
    EndTime   = $endTime
  }
}
$results = foreach ($xmlItem in (Get-ChildItem -Path 'xml')){
  Write-Host "Proccessing $($xmlItem.Name)" -ForegroundColor Green
  [xml]$xmlContent = Get-Content $xmlItem
  if($xmlContent.Task.Settings.Enabled){
    switch ($xmlContent) {
      {$_.Task.Triggers.TimeTrigger} {
        # One time trigger type
        Write-Host "The file $($xmlItem.Name) has the TimeTrigger" -ForegroundColor Cyan
        if($xmlContent.Task.Triggers.TimeTrigger.Enabled){
          # TimeTrigger is enabled
          $startTime = Get-Date -Date $xmlContent.Task.Triggers.TimeTrigger.StartBoundary
          if ($startTime -lt $dateToOutput.AddDays(1)){
            # The startTime must be before the end of the dateToOutput
            if (-not ($xmlContent.Task.Triggers.TimeTrigger.Duration)){
              # One time with indefinite duration
              if ($xmlContent.Task.Triggers.TimeTrigger.Repetition.Interval){
                # One time with indefinite duration and Repetition Interval
                $RepetitionInterval = [System.Xml.XmlConvert]::ToTimeSpan(
                  $xmlContent.Task.Triggers.TimeTrigger.Repetition.Interval
                )
                # generate all the entries for $dateToOutput via loop
                # Find first instance on $dateToOutput
                $startTimeHMS = Get-Date $startTime -Format HH:mm
                $nextStartTimeOnDate = (Get-Date (
                    Get-Date $dateToOutput -Format 'yyyy-MM-dd'
                  )).Add((Get-Date $startTimeHMS -Format HH:mm))
                # Loop until StartTime is at next day
                if ($xmlItem.Name -match 'test2') {
                  Write-host "pause"
                }
                while ($nextStartTimeOnDate -lt $dateToOutput.AddDays(1)) {
                  OutTaskObject -XmlContent $xmlContent -StartTime $nextStartTimeOnDate -DateToOutput $dateToOutput
                  # move to the next startTime
                  $nextStartTimeOnDate = $nextStartTimeOnDate.Add($RepetitionInterval)
                } # end while loop
              } else {
                # One time with indefinite duration and _NO_ Repetition Interval
                if($startTime -lt $dateToOutput){
                  # StartTime happens before date to output
                  OutTaskObject -XmlContent $xmlContent -StartTime $dateToOutput -DateToOutput $dateToOutput
                } elseif ($startTime -ge $dateToOutput -and $startTime -lt $dateToOutput.AddDays(1)) {
                  # StartTime after dateToOutput and within day
                  OutTaskObject -XmlContent $xmlContent -StartTime $startTime -DateToOutput $dateToOutput
                } else {
                  #nothing to output if the StartTime is after the dateToOutput
                }
              } #end of infinite duration and _NO_ Repetition Interval
            } else { 
              # TimeTrigger with a Duration
              $DurationInterval = [System.Xml.XmlConvert]::ToTimeSpan(
                $xmlContent.Task.Triggers.TimeTrigger.Duration
              )
              $endDateForTrigger = $startTime.Add($DurationInterval)
              if ((New-TimeSpan -Start $dateToOutput -End $endDateForTrigger).TotalDays -gt 0) {
                # the date of the Trigger Duraton has not been reached yet
                if ($xmlContent.Task.Triggers.TimeTrigger.Repetition.Interval) {
                  # TimeTrigger with a Duraton, duration not reached, WITH Repetition Interval
                  $RepetitionInterval = [System.Xml.XmlConvert]::ToTimeSpan(
                    $xmlContent.Task.Triggers.TimeTrigger.Repetition.Interval
                  )
                  # generate all the entries for $dateToOutput via loop
                  # Find first instance on $dateToOutput
                  if ($startTime -gt $dateToOutput -and $startTime -lt $dateToOutput.AddDays(1)) {
                    OutTaskObject -XmlContent $xmlContent -StartTime $startTime -DateToOutput $dateToOutput
                    # Loop until StartTime is at next day
                    $nextStartTime = $startTime.Add($RepetitionInterval)
                    while (
                      $nextStartTime -lt $dateToOutput.AddDays(1) -and
                      $nextStartTime -lt $endDateForTrigger
                    ) {
                      OutTaskObject -XmlContent $xmlContent -StartTime $startTime -DateToOutput $dateToOutput
                      # move to the next startTime
                      $nextStartTime = $startTime.Add($RepetitionInterval)
                    } # end while loop
                  } # end
                } else {
                  # TimeTrigger with a Duraton, duration not reached, _NO_ Repetition Interval
                  if ($startTime -lt $dateToOutput) {
                    # StartTime happens before date to output
                    OutTaskObject -XmlContent $xmlContent -StartTime $dateToOutput -DateToOutput $dateToOutput
                  } elseif ($startTime -ge $dateToOutput -and $startTime -lt $dateToOutput.AddDays(1)) {
                    # StartTime after dateToOutput and within day
                    OutTaskObject -XmlContent $xmlContent -StartTime $startTime -DateToOutput $dateToOutput
                  } else {
                    #nothing to output if the StartTime is after the dateToOutput
                  }

                }
              } # end
            } # end TimeTrigger with a Duration
          } # end if startTime is less than end of dateToOutput
        } # end TimeTrigger is enabled
      } # end switch check for TimeTrigger

      { $_.Task.Triggers.CalendarTrigger } {
        # Daily, Weekly, Monthly, DayOfMonth trigger
        Write-Host "The file $($xmlItem.Name) has the CalendarTrigger" -ForegroundColor Cyan
        if($xmlContent.Task.Triggers.CalendarTrigger.Enabled){
          # CalendarTrigger is enabled
          switch($xmlContent){
            { $_.Task.Triggers.CalendarTrigger.ScheduleByDay } {
              Write-Host "Trigger type is Daily"
              $startTime = Get-Date -Date $xmlContent.Task.Triggers.CalendarTrigger.StartBoundary
              # Determine if $dateToOutput is on a day task will run
              $daysInterval = $xmlContent.Task.Triggers.CalendarTrigger.ScheduleByDay.DaysInterval
              if (
                (
                  New-TimeSpan -Start $startTime -End $dateToOutput
                ).Days % $daysInterval -eq 0
              ){
                # $dateToOutput is a day this should run
                $startTimeHMS = Get-Date $startTime -Format HH:mm
                $startTimeOnDate = (Get-Date (
                  Get-Date $dateToOutput -Format 'yyyy-MM-dd'
                  )).Add((Get-Date $startTimeHMS -Format HH:mm))
                if ($xmlContent.Task.Triggers.CalendarTrigger.Repetition){
                  # Task is to repeat
                  # Get first instance
                  OutTaskObject -XmlContent $xmlContent -StartTime $startTimeOnDate -DateToOutput $dateToOutput
                  # Loop until outside dateToOutput
                  $RepetitionInterval = [System.Xml.XmlConvert]::ToTimeSpan(
                    $xmlContent.Task.Triggers.CalendarTrigger.Repetition.Interval
                  )
                  $nextStartTime = $startTimeOnDate.Add($RepetitionInterval)
                  while ($nextStartTime -lt $dateToOutput.AddDays(1)){
                    OutTaskObject -XmlContent $xmlContent -StartTime $nextStartTime -DateToOutput $dateToOutput
                    # move to the next startTime
                    $nextStartTime = $nextstartTime.Add($RepetitionInterval)
                  } # end while loop
                } else {
                  # Task does not repeat
                  # Get only instance for the day
                  OutTaskObject -XmlContent $xmlContent -StartTime $startTimeOnDate -DateToOutput $dateToOutput
                }
              }
            } # end switch condition on ScheduleByDay

            { $_.Task.Triggers.CalendarTrigger.ScheduleByWeek } {
              Write-Host "Trigger type is Weekly"
              $startTime = Get-Date -Date $xmlContent.Task.Triggers.CalendarTrigger.StartBoundary
              $startTimeHMS = Get-Date $startTime -Format HH:mm
              # Determine if $dateToOutput is on a day task will run
              $dayOfWeek = $dateToOutput.DayOfWeek
              if ($dayOfWeek -in (
                  $xmlContent.Task.Triggers.CalendarTrigger.ScheduleByWeek.DaysOfWeek.ChildNodes.Name
                )) {
                # Task day of week matches day of dateToOutput
                # Determine if $dateToOutput is on a week task will run:
                # Get the number of weeks from the $startTime to the $dayToOutput,
                # divide by 7 to convert to weeks, cast as integer to get whole number,
                # subtract by 1 because the first week is the start week,
                # modulus on the WeeksInterval and run if zero
                $weeksInterval = $xmlContent.Task.Triggers.CalendarTrigger.ScheduleByWeek.WeeksInterval
                if (
                  [int][math]::Floor(
                    (New-TimeSpan -Start $startTime -End $dateToOutput).Days / 7
                    ) -1 % $weeksInterval -eq 0)
                {
                  # Task matches the WeeksInterval and the DaysOfWeek
                  $startTimeOnDate = (
                    Get-Date (Get-Date $dateToOutput -Format 'yyyy-MM-dd')
                  ).Add(
                      (Get-Date $startTimeHMS -Format HH:mm)
                  )
                  if ($xmlContent.Task.Triggers.CalendarTrigger.Repetition) {
                    # Task is to repeat
                    # Get first instance
                    OutTaskObject -XmlContent $xmlContent -StartTime $startTimeOnDate -DateToOutput $dateToOutput
                    # Loop until outside dateToOutput
                    $RepetitionInterval = [System.Xml.XmlConvert]::ToTimeSpan(
                      $xmlContent.Task.Triggers.CalendarTrigger.Repetition.Interval
                    )
                    $nextStartTime = $startTimeOnDate.Add($RepetitionInterval)
                    while ($nextStartTime -lt $dateToOutput.AddDays(1)) {
                      OutTaskObject -XmlContent $xmlContent -StartTime $nextStartTime -DateToOutput $dateToOutput
                      # move to the next startTime
                      $nextStartTime = $nextstartTime.Add($RepetitionInterval)
                    } # end while loop
                  } else {
                    # Task does not repeat
                    # Get only instance for the day
                    OutTaskObject -XmlContent $xmlContent -StartTime $startTimeOnDate -DateToOutput $dateToOutput
                  }
                } # end if matches week interval
              } # end $dayOfWeek in ScheduleByWeek.DaysOfWeek
            } # end switch condition on ScheduleByWeek

            { $_.Task.Triggers.CalendarTrigger.ScheduleByMonth } {
              Write-Host "Trigger type is Monthly"
            } # end switch condition on ScheduleByMonth

            { $_.Task.Triggers.CalendarTrigger.ScheduleByMonthDayOfWeek } {
              Write-Host "Trigger type is MonthDayOfWeek"
            } # end switch condition on ScheduleByMonthDayOfWeek
          } # end switch on $xmlContent
        } # end CalendarTrigger is enabled
      } # end switch check for CalendarTrigger
      # =================================================================
      # Below are the rest of the triggers for reference
      # They are not used since their execution time cannot be determined
      # =================================================================
      <#
      { $_.Task.Triggers.BootTrigger } {
        Write-Host "The file $($xmlItem.Name) has the BootTrigger" -ForegroundColor Cyan
      }
      { $_.Task.Triggers.EventTrigger } {
        Write-Host "The file $($xmlItem.Name) has the EventTrigger" -ForegroundColor Cyan
      }
      { $_.Task.Triggers.IdleTrigger } {
        Write-Host "The file $($xmlItem.Name) has the IdleTrigger" -ForegroundColor Cyan
      }
      { $_.Task.Triggers.LogonTrigger } {
        Write-Host "The file $($xmlItem.Name) has the LogonTrigger" -ForegroundColor Cyan
      }
      { $_.Task.Triggers.RegistrationTrigger } {
        Write-Host "The file $($xmlItem.Name) has the RegistrationTrigger" -ForegroundColor Cyan
      }
      { $_.Task.Triggers.SessionStateChangeTrigger } {
        Write-Host "The file $($xmlItem.Name) has the SessionStateChangeTrigger" -ForegroundColor Cyan
      }
      { $_.Task.Triggers.BootTrigger } {
        Write-Host "The file $($xmlItem.Name) has the BootTrigger" -ForegroundColor Cyan
      }
      #>
    }
  }
}

$results | Out-GridView

# Output the results to Excel or some charting tool
# $results
Write-Host 'Show Out-GridView content' -ForegroundColor Magenta
Wait-Debugger
Invoke-Item -Path "~\Onedrive\Documents\Summit2023\TaskScheduler\TaskSchedulerCharts.xlsx"

Write-Host "Return to the slides" -ForegroundColor Magenta
