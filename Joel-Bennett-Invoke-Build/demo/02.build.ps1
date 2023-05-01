<#
.SYNOPSIS
    ./project.build.ps1
.EXAMPLE
    Invoke-Build -Task build
.NOTES
    0.2.0 - Clean up
    Allow directly invoking the build script
    Expand aliases for maintainability (PSScriptAnalyzer)
#>
param(
    # dotnet build configuration parameter (Debug or Release)
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release'
)

if ($MyInvocation.ScriptName -notlike '*Invoke-Build.ps1') {
    if (!(Get-Command Invoke-Build -ErrorAction SilentlyContinue)) {
        Install-Module InvokeBuild -Scope CurrentUser -Force
        Import-Module InvokeBuild
    }

    Invoke-Build @PSBoundParameters -File $MyInvocation.MyCommand.Path
    return
}

Add-BuildTask restore {
    Invoke-BuildExec { dotnet restore }
}

Add-BuildTask build restore, {
    Invoke-BuildExec { dotnet build -c $Configuration }
}

Add-BuildTask clean {
    Remove-BuildItem bin, obj
}

Add-BuildTask . restore, build
