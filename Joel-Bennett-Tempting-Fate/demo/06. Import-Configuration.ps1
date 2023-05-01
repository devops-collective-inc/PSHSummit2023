using namespace System.Management.Automation

class ModuleInfoAttribute : ArgumentTransformationAttribute {
    [object] Transform([EngineIntrinsics]$engineIntrinsics, [object] $inputData) {
        $ModuleInfo = $null
        if ($inputData -is [string] -and -not [string]::IsNullOrWhiteSpace($inputData)) {
            $ModuleInfo = Get-Module $inputData -ErrorAction SilentlyContinue
            if (-not $ModuleInfo) {
                $ModuleInfo = @(Get-Module $inputData -ErrorAction SilentlyContinue -ListAvailable)[0]
            }
        }
        if (-not $ModuleInfo) {
            throw ([System.ArgumentException]"$inputData module could not be found, please try passing the output of 'Get-Module $InputData' instead")
        }
        return $ModuleInfo
    }
}

function Import-Configuration {
    <#
        .SYNOPSIS
            A command to load configuration for a module
        .EXAMPLE
            $Config = Import-Configuration

            Load THIS module's configuration from a command
        .EXAMPLE
            $Config = Import-Configuration
            $Config.AuthToken = $ShaToken
            $Config | Export-Configuration

            Update a single setting in the configuration
        .EXAMPLE
            $Config = Get-Module PowerLine | Import-Configuration
            $Config.PowerLineConfig.DefaultAddIndex = 2
            Get-Module PowerLine | Export-Configuration $Config

            Update a single setting in the configuration
        .EXAMPLE
            $Config = Import-Configuration -Name Powerline -CompanyName HuddledMasses.org

            Load the specififed module's configuration by hand
    #>
    [CmdletBinding()]
    param(
        # The module to import configuration from
        [Parameter(ValueFromPipelineByPropertyName, ValueFromPipeline, Mandatory)]
        [ModuleInfo()]
        [PSModuleInfo]$Module
    )
    process {
        try {

            $Path = Join-Path $Env:APPDATA (
                Join-Path $Module.CompanyName $Module.Name
            )

            Import-LocalizedData -BaseDirectory $Path -FileName Configuration.psd1

        } catch {
            throw $_
        }
    }
}