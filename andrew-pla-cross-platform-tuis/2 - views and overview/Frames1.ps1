using namespace Terminal.Gui
# This lets us reference types by their short name and makes things easier to read
  
# We can get the required DLLs from 
if (-not $(Get-Module Microsoft.PowerShell.ConsoleGuiTools -ListAvailable)) {
    Install-Module Microsoft.PowerShell.ConsoleGuiTools
}

Import-Module Microsoft.PowerShell.ConsoleGuiTools 
$module = (Get-Module Microsoft.PowerShell.ConsoleGuiTools -List).ModuleBase
Add-Type -Path (Join-path $module Terminal.Gui.dll)

# Initialize the application
[Application]::Init()

# Create a window to add frames to
$Window = [Window]::new()
$Window.Title = 'Window Title'

$Frame1 = [FrameView]::new()
$Frame1.Width = [Dim]::Percent(50)
$Frame1.Height = [Dim]::Fill()
$Frame1.Title = "Frame 1"
$Window.Add($Frame1)

$Frame2 = [FrameView]::new()
$Frame2.Width = [Dim]::Percent(50)
$Frame2.Height = [Dim]::Percent(50)

# Set position relative to frame1
$Frame2.X = [Pos]::Right($Frame1)
$Frame2.Title = "Frame 2"
$Window.Add($Frame2)

$Label1 = [Label]::new()
$Label1.Text = "Frame 1 Content"
$Label1.Height = 1
$Label1.Width = 20
$Frame1.Add($Label1)

$Label2 = [Label]::new()
$Label2.Text = "Frame 2 Content"
$Label2.Height = 1
$Label2.Width = 20
$Frame2.Add($Label2)

[Application]::Top.Add($Window)

[Application]::Run()

# This makes it so it actually closes
[Application]::Shutdown()