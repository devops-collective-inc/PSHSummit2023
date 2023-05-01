# A basic prompt
function prompt {
"`e[36m$($MyInvocation.HistoryId)`e[37m $pwd`e[0m`n$([char]0x276f)"
}

# When there are errors in your prompt
function prompt {
    Write-Error "Typo";
    "`e[36m$($MyInvocation.HistoryId)`e[37m $pwd`e[0m`n$([char]0x276f)"
}

# When there's an exception in your prompt
function prompt {
    Write-Error "Typo"
    "`e[36m$($MyInvocation.HistoryId)`e[37m $pwd`e[0m`n$([char]0x276f)"
    throw "grenade"
}

# You should know to check ...
$Error[0..2]

# Let's look at how PowerLine handles it:
Set-PowerLinePrompt

# Your prompt is an array of scriptblocks
$prompt

# We can add an error to it
Add-PowerLineBlock { Write-Error "Typo"}

# We can hide that warning output:
Set-PowerLinePrompt -HideErrors

# Even if it's an exception!
Add-PowerLineBlock { throw "grenades" }

# Hiding it is probably a bad idea
Set-PowerLinePrompt -HideErrors:$False

# So let's look at the errors
# We can see which block caused them
$PromptErrors

# And look more closely at the exception
$PromptErrors[1] | fl * -fo

# Then we can put our prompt back
Remove-PowerLineBlock { Write-Error "Typo" }
Remove-PowerLineBlock { throw "grenades" }