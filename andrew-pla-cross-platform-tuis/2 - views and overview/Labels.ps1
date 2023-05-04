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
$Window.Title = "Label Window"

$Label = [Label]::New()
$Label.Text = "We have our first label. This label can have a lot of content,good times! `r`n you can use ``r``n to newline. You can also use enter.

see"


#$Label.TextDirection = 'BottomTop_RightLeft'

$Label.Width = [Dim]::Fill()
$Label.Height = [Dim]::Fill()

$Window.Add($Label)

[Application]::Top.Add($Window)
[Application]::Run()

# This makes it so it actually closes
[Application]::Shutdown()