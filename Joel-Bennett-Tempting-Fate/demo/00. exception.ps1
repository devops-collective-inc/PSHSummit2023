# These three functions show how sometimes an -ErrorAction Ignore can surpress an exception ...
# But have it bubble up again later when someone tries a trap or try/catch
function divide {
    [CmdletBinding()]
    param($numerator = 1, $denominator = 0)
    $numerator / $denominator
}

function nevercrash {
    [CmdletBinding()]
    param($numerator = 1, $denominator = 0)
    divide @PSBoundParameters -ErrorAction Ignore
}

function surprise {
    [CmdletBinding()]
    param($ammount = 1)
    try {
        nevercrash $ammount
    } catch {
        throw $_
    }
}