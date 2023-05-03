Install-Module Microsoft.PowerShell.ConsoleGuiTools

#region Quick tool to pick a new song to play
Get-ChildItem $Home\Music\ -Recurse -Filter *.mp3 |
Out-ConsoleGridView -OutputMode Single |
Invoke-Item
#endregion

#region Get some help, you probably need it
Get-Help about* | 
Select-Object Name |
Out-ConsoleGridView -Title 'Plz get help' -OutputMode Single |
Get-Help
#endregion

#region filter processes to stop
Get-Process | Out-ConsoleGridView -PassThru | Stop-process -WhatIf
#endregion

#region f7 view history - Shift+f7 psreadlinehistory
function ocgv_history {
    param(
        [parameter(Mandatory = $true)]
        [Boolean]
        $global
    )
  
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if ($global) {
        # Global history
        $history = [Microsoft.PowerShell.PSConsoleReadLine]::GetHistoryItems().CommandLine 
        # reverse the items so most recent is on top
        [array]::Reverse($history) 
        $selection = $history | Select-Object -Unique | Out-ConsoleGridView -OutputMode Single -Filter $line -Title "Global Command Line History"
  
    }
    else {
        # Local history
        $history = Get-History | Sort-Object -Descending -Property Id -Unique | Select-Object CommandLine -ExpandProperty CommandLine 
        $selection = $history | Out-ConsoleGridView -OutputMode Single -Filter $line -Title "Command Line History"
    }
  
    if ($selection) {
        [Microsoft.PowerShell.PSConsoleReadLine]::DeleteLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selection)
        if ($selection.StartsWith($line)) {
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor)
        }
        else {
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selection.Length)
        }    
    }      
}
  
# When F7 is pressed, show the local command line history in OCGV
$parameters = @{
    Key              = 'F7'
    BriefDescription = 'Show Matching History'
    LongDescription  = 'Show Matching History using Out-ConsoleGridView'
    ScriptBlock      = {
        ocgv_history -Global $false 
    }
}
Set-PSReadLineKeyHandler @parameters
  
# When Shift-F7 is pressed, show the local command line history in OCGV
$parameters = @{
    Key              = 'Shift-F7'
    BriefDescription = 'Show Matching Global History'
    LongDescription  = 'Show Matching History for all PowerShell instances using Out-ConsoleGridView'
    ScriptBlock      = {
        ocgv_history -Global $true
    }
}
Set-PSReadLineKeyHandler @parameters

#endregion