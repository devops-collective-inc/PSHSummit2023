class ModuleInfoAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData) {
        $ModuleInfo = $null
        if ($inputData -is [string] -and -not [string]::IsNullOrWhiteSpace($inputData)) {
            $ModuleInfo = Get-Module $inputData -ErrorAction SilentlyContinue
            if (-not $ModuleInfo) {
                $ModuleInfo = @(Get-Module $inputData -ErrorAction SilentlyContinue -ListAvailable)[0]
            }
        }
        if (-not $ModuleInfo) {
            throw ([System.ArgumentException]"$inputData module could not be found, please try passing the output of 'Get-Module $InputData' instead")
        }
        return $ModuleInfo
    }
}