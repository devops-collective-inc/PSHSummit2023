# https://blog.ironmansoftware.com/daily-powershell/powershell-out-tree-view/
Import-Module Microsoft.PowerShell.ConsoleGuiTools 
$module = (Get-Module Microsoft.PowerShell.ConsoleGuiTools -List).ModuleBase
Add-Type -Path (Join-path $module Terminal.Gui.dll)
function Expand-Object {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    Process {
        if ($InputObject -eq $null) {
            return
        }
        $InputObject | Get-Member -MemberType Properties | ForEach-Object {
            try {
                $Value = $InputObject.($_.Name)
                $Node = [Terminal.Gui.Trees.TreeNode]::new("$($_.Name) = $Value")

                if ($Value -ne $null) {
                    $Children = Expand-Object -InputObject $Value
                    foreach ($child in $Children) {
                        $Node.Children.Add($child)
                    }
                }

                $Node
            }
            catch {
                Write-Host $_
            }
        }

    }
}

function Out-TreeView {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    Begin {
        $Objects = @() 
    }
    
    Process {
        $Objects += $InputObject
    }

    End {
        [Terminal.Gui.Application]::Init()
        $Top = [Terminal.Gui.Application]::Top

        $Win = [Terminal.Gui.Window]::new("Out-TreeView")
        $Win.Height = [Terminal.Gui.Dim]::Fill()
        $Win.Width = [Terminal.Gui.Dim]::Fill()

        $TreeView = [Terminal.Gui.TreeView]::new()
        $TreeView.Height = [Terminal.Gui.Dim]::Fill()
        $TreeView.Width = [Terminal.Gui.Dim]::Fill()

        foreach ($item in $Objects) {
            $root = [Terminal.Gui.Trees.TreeNode]::new($item.GetType().Name)
            $Children = Expand-Object $item
            $Children | ForEach-Object {
                $root.Children.Add($_)
            }
            $TreeView.AddObject($root)
        }

        $Win.Add($TreeView)

        $Top.Add($Win)
 
        [Terminal.Gui.Application]::Run()
        [Terminal.Gui.Application]::Shutdown()
    }
}
$Podcasts = Invoke-RestMethod 'https://feed.podbean.com/powershellpodcast/feed.xml'
$Podcasts | Out-TreeView
