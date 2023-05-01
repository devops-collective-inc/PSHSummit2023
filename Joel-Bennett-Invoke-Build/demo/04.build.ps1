<#
.SYNOPSIS
    ./project.build.ps1
.EXAMPLE
    Invoke-Build
.NOTES
    0.4.0 - Shared Tasks
    A full example with a shared tasks folder
    Add versioning and tests
#>
[CmdletBinding()]
param(
    # dotnet build configuration parameter (Debug or Release)
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',

    # Add the clean task before the default build
    [switch]$Clean,

    # Collect code coverage when tests are run
    [switch]$CollectCoverage
)
$InformationPreference = "Continue"

$Tasks = "Tasks","../Tasks","../../Tasks" | Convert-Path -ErrorAction Ignore | Select-Object -First 1

## Self-contained build script - can be invoked directly or via Invoke-Build
if ($MyInvocation.ScriptName -notlike '*Invoke-Build.ps1') {
    & "$Tasks/_Bootstrap.ps1"

    Invoke-Build -File $MyInvocation.MyCommand.Path @PSBoundParameters -Result Result

    if ($Result.Error) {
        $Error[-1].ScriptStackTrace | Out-String
        exit 1
    }
    exit 0
}

## The first task defined is the default task
if ($Clean) {
    Add-BuildTask . Clean, DotNetRestore, DotNetBuild, DotNetTest, DotNetPublish
} else {
    Add-BuildTask . DotNetRestore, DotNetBuild, DotNetTest, DotNetPublish
}

## Initialize the build variables, and import shared tasks, including DotNet tasks
. "$Tasks/_Initialize.ps1" -DotNet