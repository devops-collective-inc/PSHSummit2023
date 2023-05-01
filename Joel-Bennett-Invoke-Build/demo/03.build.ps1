<#
.SYNOPSIS
    ./project.build.ps1
.EXAMPLE
    Invoke-Build
.NOTES
    0.3.0 - Incremental
    Add incremental build support with inputs and outputs
    Add a clean switch
#>
param(
    # dotnet build configuration parameter (Debug or Release)
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',

    # Add the clean task before the default build
    [switch]$Clean
)

if ($MyInvocation.ScriptName -notlike '*Invoke-Build.ps1') {
    if (!(Get-Command Invoke-Build -ErrorAction SilentlyContinue)) {
        Install-Module InvokeBuild -Scope CurrentUser -Force
        Import-Module InvokeBuild
    }

    Invoke-Build @PSBoundParameters -File $MyInvocation.MyCommand.Path
    return
}

if ($Clean) {
    Add-BuildTask . clean, restore, build
} else {
    Add-BuildTask . restore, build
}

Add-BuildTask restore @{
    Inputs = {
        Get-ChildItem -Recurse -File -Filter *.csproj
    }
    Outputs = {
        Join-Path $pwd obj project.assets.json
    }
    Jobs = {
        Invoke-BuildExec {
            dotnet restore
        }
    }

}

Add-BuildTask build @{
    Inputs  = {
        Get-ChildItem -Recurse -File -Filter *.cs |
            # Exclude generated files in /obj/ folders
            Where-Object FullName -NotMatch "[\\/]obj[\\/]"
    }
    Outputs = {
        $BaseName = (Get-Item $BuildRoot -filter *.csproj).BaseName
        Join-Path $BuildRoot bin "$BaseName.dll"
    }
    Jobs    = {
        Invoke-BuildExec {
            dotnet build -c $configuration -o bin
        }
    }
}

Add-BuildTask clean {
    Remove-BuildItem bin, obj
}
