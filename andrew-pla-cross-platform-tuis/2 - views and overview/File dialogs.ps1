using namespace Terminal.Gui
  
# We can get the required DLLs from 
if (-not $(Get-Module Microsoft.PowerShell.ConsoleGuiTools -ListAvailable)) {
    Install-Module Microsoft.PowerShell.ConsoleGuiTools
}

Import-Module Microsoft.PowerShell.ConsoleGuiTools 
$module = (Get-Module Microsoft.PowerShell.ConsoleGuiTools -List).ModuleBase
Add-Type -Path (Join-path $module Terminal.Gui.dll)

# Initialize the application
[Application]::Init()

# Create the window to use
$Window = [Window]::New()
$Window.Title = "Window Title"

$Dialog = [OpenDialog]::new("Open Powershell Script", "")
$Dialog.CanChooseDirectories = $false
$Dialog.CanChooseFiles = $true 
$Dialog.AllowsMultipleSelection = $false

$Dialog.DirectoryPath = "$Home\Documents\PowerShell\Scripts"
$Dialog.AllowedFileTypes = @(".ps1")
[Application]::Run($Dialog)

# This makes it so it actually closes
[Application]::Shutdown()

# We must call the .tostring() method to work with this type
Write-Host "you selected $($dialog.FilePath.ToString())"
#Code "$($dialog.FilePath.ToString())"