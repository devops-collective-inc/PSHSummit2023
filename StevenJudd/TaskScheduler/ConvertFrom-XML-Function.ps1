function ConvertFrom-Xml {
  <#
.SYNOPSIS
    Converts XML object to PSObject representation for further ConvertTo-Json transformation
.EXAMPLE
    # JSON->XML
    $xml = ConvertTo-Xml (get-content 1.json | ConvertFrom-Json) -Depth 4 -NoTypeInformation -as String
.EXAMPLE
    # XML->JSON
    ConvertFrom-Xml ([xml]($xml)).Objects.Object | ConvertTo-Json
  .NOTES
    copied from https://stackoverflow.com/questions/3242995/convert-xml-to-psobject
#>
  param([System.Xml.XmlElement]$Object)

  if (($Object -ne $null) -and ($Object.Property -ne $null)) {
    $PSObject = New-Object PSObject

    foreach ($Property in @($Object.Property)) {
      if ($Property.Property.Name -like 'Property') {
        $PSObject | Add-Member NoteProperty $Property.Name ($Property.Property | ForEach-Object { ConvertFrom-Xml $_ })
      } else {
        if ($Property.'#text' -ne $null) {
          $PSObject | Add-Member NoteProperty $Property.Name $Property.'#text'
        } else {
          if ($Property.Name -ne $null) {
            $PSObject | Add-Member NoteProperty $Property.Name (ConvertFrom-Xml $Property)
          }
        }
      } 
    }   
    $PSObject
  }
}