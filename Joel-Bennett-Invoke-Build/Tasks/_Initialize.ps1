[CmdletBinding()]
param(
    [switch]$DotNetTasks,
    [switch]$NoTasks
)
Write-Information "Initializing build variables"
# BuildRoot is provided by Invoke-Build
Write-Information "  BuildRoot: $BuildRoot"

# NOTE: this variable is currently also used for Pester formatting ...
# So we must use either "AzureDevOps", "GithubActions", or "None"
$script:BuildSystem = if (Test-Path ENV:GITHUB_ACTIONS) {
    "GithubActions"
} elseif (Test-Path Env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI) {
    "AzureDevops"
} else {
    "None"
}

# A little extra BuildEnvironment magic
if ($script:BuildSystem -eq "AzureDevops") {
    Set-BuildHeader { Write-Build 11 "##[group]Begin $($args[0])" }
    Set-BuildFooter { Write-Build 11 "##[endgroup]Finish $($args[0]) $($Task.Elapsed)" }
}
Write-Information "  BuildSystem: $script:BuildSystem"

# Cross-platform separator character
${script:\} = ${script:/} = [IO.Path]::DirectorySeparatorChar

<#  A note about paths noted by Azure Pipeline environment variables:
    $Env:PIPELINE_WORKSPACE         - Defaults to /work/job_id and holds all the others:

    These other three are defined relative to $Env:PIPELINE_WORKSPACE
    $Env:BUILD_SOURCESDIRECTORY     - Cleaned BEFORE checkout IF: Workspace.Clean = All or Resources, or if Checkout.Clean = $True
                                        For single source, defaults to work/job_id/s
                                        For multiple, defaults to work/job_id/s/sourcename
    $Env:BUILD_BINARIESDIRECTORY    - Cleaned BEFORE build IF: Workspace.Clean = Outputs
    $Env:BUILD_STAGINGDIRECTORY     - Cleaned AFTER each Build
    $Env:AGENT_TEMPDIRECTORY        - Cleaned AFTER each Job
#>

# There are a few different environment/variables it could be, and then our fallback
$Script:OutputDirectory = $script:OutputDirectory ??
                          $Env:BUILD_BINARIESDIRECTORY ?? # Azure
                          (Join-Path -Path $BuildRoot -ChildPath 'output')
New-Item -Type Directory -Path $OutputDirectory -Force | Out-Null
Write-Information "  OutputDirectory: $OutputDirectory"

$Script:TestResultsDirectory = $script:TestResultsDirectory ??
                               $Env:COMMON_TESTRESULTSDIRECTORY ?? # Azure
                               $Env:TEST_RESULTS_DIRECTORY ??
                               (Join-Path -Path $OutputDirectory -ChildPath 'tests')
New-Item -Type Directory -Path $TestResultsDirectory -Force | Out-Null
Write-Information "  TestResultsDirectory: $TestResultsDirectory"

### IMPORTANT: Our local TempDirectory does not cleaned the way the Azure one does
$Script:TempDirectory = $script:TempDirectory ??
                        $Env:RUNNER_TEMP ?? # Github
                        $Env:AGENT_TEMPDIRECTORY ?? # Azure
                        (Join-Path ($Env:TEMP ?? $Env:TMP ?? "$BuildRoot/Tmp_$(Get-Date -f yyyyMMddThhmmss)") -ChildPath 'InvokeBuild')
New-Item -Type Directory -Path $TempDirectory -Force | Out-Null
Write-Information "  TempDirectory: $TempDirectory"

# Git variables that we could probably use:
$Script:GitSha = $script:GitSha ?? $ENV:GITHUB_SHA ?? $ENV:BUILD_SOURCEVERSION
if (!$Script:GitSha) {
    $Script:GitSha = git rev-parse HEAD
}
Write-Information "  GitSha: $Script:GitSha"

$script:BranchName = $script:BranchName ?? $Env:BUILD_SOURCEBRANCHNAME
if (!$script:BranchName -and (Get-Command git -CommandType Application -ErrorAction Ignore)) {
    $script:BranchName = (git branch --show-current) -replace ".*/"
}
Write-Information "  BranchName: $script:BranchName"

if ($DotNetTasks) {
    Write-Information "Initializing DotNet build variables"
    # The PublishDirectory is the pub folder within the OutputDirectory (used for dotnet publish output)
    $script:PublishDirectory = New-Item (Join-Path $script:OutputDirectory publish) -ItemType Directory -Force -ErrorAction SilentlyContinue | Convert-Path

    # Default values for build variables:
    # Dotnet build configuration
    $script:Configuration ??= "Release"
    Write-Information "  Configuration: $script:Configuration"

    # The projects are expected to each be in their own folder
    # Dotnet allows us to pass it the _folder_ that we want to build/test
    # So our $buildProjects are the names of the folders that contain the projects
    $script:dotnetProjects = @(
        if (!$dotnetProjects) {
            Get-ChildItem -Path $BuildRoot -Include *.*proj -Recurse | Split-Path
        } elseif (![IO.Path]::IsPathRooted(@($dotnetProjects)[0])) {
            Get-ChildItem -Path $BuildRoot -Include *.*proj -Recurse |
                Where-Object { $dotnetProjects -contains $_.BaseName } | Split-Path
        } else {
            $dotnetProjects
        }
    ) | Convert-Path
    Write-Information "  DotNetProjects: $($script:dotnetProjects -join ", ")"

    $script:dotnetTestProjects = @(
        if (!$dotnetTestProjects) {
            Get-ChildItem -Path $BuildRoot -Include *Test.*proj -Recurse | Split-Path
        } elseif (![IO.Path]::IsPathRooted(@($dotnetTestProjects)[0])) {
            Get-ChildItem -Path $BuildRoot -Include *Test.*proj -Recurse |
                Where-Object { $dotnetTestProjects -contains $_.BaseName } | Split-Path
        } else {
            $dotnetTestProjects
        }
    )  | Convert-Path
    Write-Information "  DotNetTestProjects: $($script:dotnetTestProjects -join ", ")"

    $script:dotnetOptions ??= @{}
}

# Finally, import all the Task.ps1 files in this folder
if (!$NoTasks) {
    Write-Information "Import Shared Tasks"
    foreach ($taskfile in Get-ChildItem -Path $PSScriptRoot -Filter *.Task.ps1) {
        if (!$DotNetTasks -and $taskfile.Name -match "^DotNet") { continue }
        Write-Information "    $($taskfile.FullName)"
        . $taskfile.FullName
    }
}