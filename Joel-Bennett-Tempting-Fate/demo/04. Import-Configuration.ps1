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
    #>
    [CmdletBinding()]
    param(
        # The module to import configuration from
        [Parameter(ValueFromPipelineByPropertyName, ValueFromPipeline, Mandatory)]
        [System.Management.Automation.PSModuleInfo]$Module
    )
    process {
        try {
            # TODO
        } catch {
            throw $_
        }
    }
}