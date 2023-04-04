New-Item -Path "c:\temp"

$customfield = "Custom"+$ENV:UDF_6
$delFile = "C:\temp\export.csv" 
del $delFile
wmic qfe list /format:csv >  C:\temp\export.csv
$myVar = Get-Content $delFile
$myVar[4..($myVar.length-4)] | % {$_.trimstart()} | out-file C:\temp\export.csv
New-ItemProperty "HKLM:\software\centrastage" -Name Custom6 -PropertyType string -Value $myVar
