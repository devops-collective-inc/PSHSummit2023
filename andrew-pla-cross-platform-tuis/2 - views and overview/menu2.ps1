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

$MenuItem = [MenuItem]::new("_Close", "", { [Application]::RequestStop() })
$MenuBarItem = [MenuBarItem]::new("C_lose", @($MenuItem))

$MenuItem2 = [MenuItem]::New("_About", "", { [Terminal.Gui.MessageBox]::Query("About", "This is a super sweet demo, wowzerz!") })
$MenuBarItem2 = [MenuBarItem]::New("A_bout", @($MenuItem2))

$MenuBar = [MenuBar]::new(@($MenuBarItem, $MenuBarItem2))
$Window.Add($MenuBar)


[Application]::Top.Add($Window)
[Application]::Run()

# This makes it so it actually closes
[Application]::Shutdown()

