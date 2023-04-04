New-Item -Path "c:\temp" -ErrorAction Ignore
$customfield = "Custom"+$ENV:UDF_6
$delFile = "C:\temp\export.csv" 
del $delFile -ErrorAction Ignore
wmic qfe get caption,hotfixid,installedon  > C:\temp\export.csv
$myVar = Get-Content $delFile
#$myvar = $myVar[4..($myVar.length-4)] | % {$_.trimstart()} | out-file C:\temp\export.csv
del $delFile -ErrorAction Ignore

$result = $myVar[4..($myVar.length-4)] | % {$_.trimstart()}# | Out-File -Encoding ASCII C:\temp\export.csv
$myVar = Get-Content $delFile
New-ItemProperty "HKLM:\software\centrastage" -Name Custom6 -PropertyType string -Value $result -ErrorAction Ignore

