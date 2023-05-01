[CmdletBinding()]
param(
    # If set, bootstrap dotnet as well as Invoke-Build
    [semver]$Dotnet,

    [switch]$Force
)
$InformationPreference = "Continue"

Write-Information "Ensure Invoke-Build"
if (!(Get-Command Invoke-Build -ErrorAction SilentlyContinue)) {
    Install-Module InvokeBuild -Scope CurrentUser -Force
    Import-Module InvokeBuild
}

if ($Dotnet) {
    Write-Information "Ensure dotnet version"
    if (!((Get-Command dotnet -ErrorAction SilentlyContinue) -and ([semver](dotnet --version) -gt [semver]"7.0.200"))) {
        Write-Host "This script can call dotnet-install to install a local copy of dotnet 7.0 -- if you'd rather install it yourself, answer no:"
        if ($Force -or $PSCmdlet.ShouldContinue("Attempt to install dotnet 7.0?")) {
            if (!$IsLinux -and !$IsMacOS) {
                Invoke-WebRequest https://dot.net/v1/dotnet-install.ps1 -OutFile bootstrap-dotnet-install.ps1
                .\bootstrap-dotnet-install.ps1 -Channel 7.0 -InstallDir $HOME\.dotnet
            } else {
                Invoke-WebRequest https://dot.net/v1/dotnet-install.sh -OutFile bootstrap-dotnet-install.sh
                chmod +x bootstrap-dotnet-install.sh
                ./bootstrap-dotnet-install.sh --channel 7.0 --install-dir $HOME/.dotnet
            }
        }
        if (!((Get-Command dotnet -ErrorAction SilentlyContinue) -and ([semver](dotnet --version) -gt [semver]"7.0.200"))) {
            throw "Unable to find dotnet 7.0.200 or later"
        }
    }

    Write-Information "Ensure GitVersion"
    if (!(Get-Command dotnet-gitversion -ErrorAction SilentlyContinue)) {
        $ENV:PATH += ([IO.Path]::PathSeparator) + (Convert-Path ~/.dotnet/tools)
        dotnet tool update GitVersion.Tool --global # --verbosity normal
    }
}