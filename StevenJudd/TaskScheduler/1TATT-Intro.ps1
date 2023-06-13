# Run from ISE since VSCode is running as admin (or should be)
& $env:windir\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe .\1TATT-Intro.ps1

# List the tasks
Wait-Debugger
Get-ScheduledTask
Get-ScheduledTask | Where-Object TaskPath -NotMatch '\\Microsoft'

#region
# Welcome to the UAC, not nearly as cool as the EAC, right Crush?

# Of course, you could try to do something ugly:
# $schedule = New-Object -ComObject 'Schedule.Service'
# $schedule.connect() 
# $schedule.getfolder('\').gettasks(0)

# or

# schtasks
# But it won't work either
# Time to switch to Admin

Write-Host "Run as Admin"
#endregion