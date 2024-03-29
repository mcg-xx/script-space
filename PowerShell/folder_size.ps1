$sizeInBytes = (Get-ChildItem -Path '.' -Recurse -Force | Measure-Object -Property Length -Sum).Sum

$sizeInGB = $sizeInBytes / 1GB
$sizeInMB = $sizeInBytes / 1MB

$sizeInGBFormatted = "{0:N3}" -f $sizeInGB
$sizeInMBFormatted = "{0:N0}" -f $sizeInMB

Write-Output "Result: ${sizeInGBFormatted} GB (${sizeInMBFormatted} MB)"