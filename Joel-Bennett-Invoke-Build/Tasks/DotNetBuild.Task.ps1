Add-BuildTask DotNetBuild @{
    # This task should be skipped if there are no C# projects to build
    If      = $dotnetProjects
    Inputs  = {
        # Exclude generated source files in /obj/ folders
        Get-ChildItem $dotnetProjects -Recurse -File -Filter *.cs |
            Where-Object FullName -NotMatch "[\\/]obj[\\/]"
    }
    Outputs = {
        foreach ($project in $dotnetProjects) {
            $BaseName = (Get-Item $project -Filter *.csproj).BaseName
            (Get-ChildItem $project/bin -Filter "$BaseName.dll" -Recurse -ErrorAction Ignore) ?? $BuildRoot
        }
    }
    Jobs    = "DotNetRestore", "GitVersion", {
        $local:options = @{} + $script:dotnetOptions

        # We never do self-contained builds
        if ($options.ContainsKey("-runtime") -or $options.ContainsKey("-ucr")) {
            $options["-no-self-contained"] = $true
        }

        foreach ($project in $dotnetProjects) {
            if (Test-Path "Variable:GitVersion.$((Split-Path $project -Leaf).ToLower())") {
                $options["p"] = "Version=$((Get-Variable "GitVersion.$((Split-Path $project -Leaf).ToLower())" -ValueOnly).InformationalVersion)"
            }

            Write-Build Gray "dotnet build $project --configuration $configuration -p $($options["p"])"
            dotnet build $project --configuration $configuration @options
        }
    }
}
