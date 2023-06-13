# check for Admin rights
if ((New-Object Security.Principal.WindowsPrincipal (
    [Security.Principal.WindowsIdentity]::GetCurrent()
  )).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) -ne $true){
  Write-Error "Must be running as Admin"
}

Get-ScheduledTask | Where-Object TaskPath -NotMatch '\\Microsoft'

#region Examine the object
Wait-Debugger
(Get-ScheduledTask)[0].GetType().FullName
(Get-ScheduledTask)[0] | Get-Member -Name TaskName | Select-Object TypeName
# Not a standard .NET object type
# May act different than objects you are used to
#endregion Examine the object

Write-Host "Return to the slides" -ForegroundColor Magenta
