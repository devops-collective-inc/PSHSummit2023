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

$Label = [Terminal.Gui.Label]::new()
$Label.Text = "0"
$Label.Height = 1
$Label.Width = 20
$Window.Add($Label) 

$Button = [Button]::new()
$Button.X = [Pos]::Right($Label)
$Button.Text = "Start Job"
$Button.add_Clicked({ 
        Start-ThreadJob { 
            $bgLabel = $args[0]
            write-host $bgLabel
            1..100 | ForEach-Object {
                $Item = $_
                [Application]::MainLoop.Invoke({ $bgLabel.Text = $Item.ToString() }) 
                Start-Sleep -Milliseconds 1000
            }
        
        } -ArgumentList $Label
    })

$Window.Add($Button)

$Button2 = [Button]::new()
$Button2.X = [Pos]::Right($Button)
$Button2.Text = "Do I work?"
$Button2.add_Clicked({ 
        [MessageBox]::Query("Still workin'", "")
    })

$Window.Add($Button2)

[Application]::Top.Add($Window)
[Application]::Run()

# This makes it so it actually closes
[Application]::Shutdown()