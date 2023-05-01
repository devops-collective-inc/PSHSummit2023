[CmdletBinding()]
param(
    [switch]$PleaseDontThrow
)

try {
    Write-Information "Enter $($MyInvocation.MyCommand)" -Tag Trace
    if (!$PleaseDontThrow) {
        Write-Information "`$PleaseDontThrow was $PleaseDontThrow, so ..." -Tag Trace
        throw "horseshoes"
    }
} catch {
    Write-Information $_ -Tag Exception
    throw $_
}
Write-Information "Exit $($MyInvocation.Line)" -Tag Trace
