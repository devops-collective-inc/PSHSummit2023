Add-BuildTask GitVersion @{
    # This task should be skipped if there are no C# projects to build
    If      = $dotnetProjects
    Inputs  = {
        # Exclude generated source files in /obj/ folders
        Get-ChildItem $dotnetProjects -Recurse -File -Filter *.cs |
            Where-Object FullName -NotMatch "[\\/]obj[\\/]"
    }
    Outputs = {
        if ($script:BuildSystem -eq "None") {
            # Locally, we can never skip versioning, because someone could have tagged git
            $BuildRoot
        } else {
            # In the build system, run it ONCE PER BUILD (use a $TempDirectory the build cleans)
            if ($dotnetProjects.Count -gt 1) {
                (Split-Path $dotnetProjects -Leaf).ToLower() |
                    Join-Path -Path $TempDirectory -ChildPath { "${_}-v$GitSha.json" }
            } else {
                Join-Path -Path $TempDirectory -ChildPath "v$GitSha.json"
            }
        }
    }
    Jobs    = {
        $PackageNames = (Split-Path $dotnetProjects -Leaf).ToLower()

        <# MonoRepo Madness
        # If this is a PR build, fetch the "description" which will go into the commit later
        # GET https://dev.azure.com/{organization}/{project}/_apis/sourceProviders/{providerName}/pullrequests/{pullRequestId}?repositoryId={repositoryId}&serviceEndpointId={serviceEndpointId}&api-version=7.0

        $commitMessage = if ($Env:SYSTEM_PULLREQUEST_PULLREQUESTID -and $Env:SYSTEM_ACCESSTOKEN -and $Env:SYSTEM_COLLECTIONURI) {
            $BaseUri = "$($Env:SYSTEM_COLLECTIONURI)$($Env:SYSTEM_TEAMPROJECTID)/_apis/"
            $ApiVersion = "api-version=7.0"
            $PullRequest = Invoke-RestMethod "$($BaseUri)sourceProviders/git/pullrequests/${Env:SYSTEM_PULLREQUEST_PULLREQUESTID}?$($ApiVersion)" -Headers @{
                Authorization = "Bearer $Env:SYSTEM_ACCESSTOKEN"
            }
            $PullRequest.title + "`n`n" + $PullRequest.description
        } else {
            # %B is for the raw "Body" of the commit message. See https://git-scm.com/docs/git-show#_pretty_formats
            git log -1 --format="%B"
        }

        # In a monorepo, we need to ignore commits that don't mention a specific package
        if ($PackageNames) {
            Write-Host "GitVersion calculating for monorepo."
            $SkipMessage = ".*"
        } else {
            Write-Host "GitVersion calculating for single project repo."
            $SkipMessage = "\s*(skip|none)"
        }
        #>
        $script:GitVersionTags = foreach ($Name in $PackageNames) {
            $MessagePrefix = "semver"
            $TagPrefix = "v"

            if ($dotnetProjects.Count -gt 1) {
                $MessagePrefix = ($MessagePrefix, $Name) -join "-"
                $TagPrefix = ($Name, $TagPrefix) -join "-"
            }

            # Since we know the things we need to version, let's make *sure* that we version it:
            # Write-Host git commit "--ammend" "-m" "$commitMessage`n$messagePrefix:patch"
            # git commit --ammend -m "$commitMessage`n$messagePrefix:patch"

            $GitVersionYaml = if (Test-Path "$BuildRoot/GitVersion.yml") {
                "$BuildRoot/GitVersion.yml"
            } else {
                Convert-Path "$PSScriptRoot/Version.yml"
            }

            $VersionFile = Join-Path $TempDirectory -ChildPath "$TagPrefix$GitSha.json"

            if (Test-Path $VersionFile) {
                Remove-Item $VersionFile
            }

            Write-Host dotnet gitversion -config $GitVersionYaml -output file -outputfile $VersionFile
            # We can't splat because it's 5 copies of the same parameter, so, use line-wrapping escapes:
            # Also, the no-bump-message has to stay at .* or else every commit to master will increment all components
            dotnet gitversion -config $GitVersionYaml -output file -outputfile $VersionFile `
                -overrideconfig tag-prefix="$($TagPrefix)" `
                -overrideconfig major-version-bump-message="$($MessagePrefix):\s*(breaking|major)" `
                -overrideconfig minor-version-bump-message="$($MessagePrefix):\s*(feature|minor)" `
                -overrideconfig patch-version-bump-message="$($MessagePrefix):\s*(fix|patch)" `
                -overrideconfig no-bump-message="$($MessagePrefix):\s*(skip|none)"

            try {
                $GitVersion = Get-Content $VersionFile | ConvertFrom-Json -ErrorAction Stop
                Set-Variable "GitVersion.$Name" $GitVersion -Scope Script
            } catch {
                Write-Warning "dotnet gitversion -config $GitVersionYaml -outputfile $VersionFile"
                Write-Warning "TagPrefix: $($TagPrefix)"
                Write-Warning "MessagePrefix: $($MessagePrefix)"
                Write-Host $VersionFile
                throw $_
            }

            # Output for Azure DevOps
            if ($ENV:SYSTEM_COLLECTIONURI) {
                foreach ($envar in $GitVersion.PSObject.Properties) {
                    $EnvVarName = if ($Name) {
                        @($Name, $Envar.Name) -join "."
                    } else {
                        $Envar.Name
                    }
                    Write-Host "INFO [task.setvariable variable=$EnvVarName;isOutput=true]$($envar.Value)"
                    Write-Host "##vso[task.setvariable variable=$EnvVarName;isOutput=true]$($envar.Value)"
                }
            } else {
                Write-Host "GitVersion: $($GitVersion.InformationalVersion)"
            }
            # Output the expected tag
            $TagPrefix + $GitVersion.SemVer
        }

        # Output for Azure DevOps
        if ($ENV:SYSTEM_COLLECTIONURI) {
            $OFS = " "
            Write-Host "INFO [task.setvariable variable=Tag;isOutput=true]$GitVersionTags"
            Write-Host "##vso[task.setvariable variable=Tag;isOutput=true]$GitVersionTags"
        }
    }
}
