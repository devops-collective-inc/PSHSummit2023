# How to acquire? We need a couple .dlls to get started quick, install module
Install-Module Microsoft.PowerShell.ConsoleGuiTools
Install-Module TerminalGuiDesigner


# Load Assembly
Import-Module Microsoft.PowerShell.ConsoleGuiTools 
$module = (Get-Module Microsoft.PowerShell.ConsoleGuiTools -List).ModuleBase
Add-Type -Path (Join-path $module Terminal.Gui.dll)

# Must initialize the top level application
[Terminal.Gui.Application]::Init()


# Use this code in VS Code to allow Ctrl + Q to pass to the terminal from
# https://github.com/microsoft/vscode/issues/108130
"terminal.integrated.commandsToSkipShell": [
"-workbench.action.quickOpenView"
]