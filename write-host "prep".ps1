write-host "prep"

Write-Host "2"

Write-Host "3"

$VerbosePreference = Continue 
$Installers = Import-Csv C:\temp\testArray.csv 
foreach ($Installer in $Installers) {}

