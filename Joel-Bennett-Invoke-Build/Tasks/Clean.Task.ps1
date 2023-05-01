Add-BuildTask Clean {
    # This will blow away everything that's .gitignored, and fast
    git clean -Xdf
    # Re "Initialize.ps1" to make sure the directories are there
    & "$PSScriptRoot/_Initialize.ps1" -NoTasks -InformationAction SilentlyContinue
}