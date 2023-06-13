$minutes = 30
for ($i = 0; $i -lt $minutes; $i++) {
  Write-Host '.' -NoNewline
  Start-Sleep -Seconds 60
}