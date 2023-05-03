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

# put your code here
# put your code here



[Application]::Top.Add($Window)
[Application]::Run()

# This makes it so it actually closes
[Application]::Shutdown()