Add-BuildTask DotNetRestore @{
    # This task should be skipped if there are no C# projects to build
    If      = $dotnetProjects
    Inputs  = {
        Get-ChildItem $dotnetProjects -Recurse -File -Filter *.*proj
    }
    Outputs = {
        Join-Path $dotnetProjects obj project.assets.json
    }
    Jobs    = {
        $local:options = @{} + $script:dotnetOptions

        if (Test-Path "$BuildRoot/NuGet.config") {
            $options["-configfile"] = "$BuildRoot/NuGet.config"
        }
        foreach ($project in $dotnetProjects) {
            Write-Build Gray "dotnet restore $project" @options
            dotnet restore $project @options
        }
    }
}
