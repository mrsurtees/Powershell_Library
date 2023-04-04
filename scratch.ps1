Remove-Item "c:\temp\err*.txt"
$hashImport=@()
$hashArray=@(Import-Csv -path  "C:\temp\installersArray.csv")
$hashArray
#$hasharray  | ForEach{$hashArray}


$temp=gc "C:\temp\installersArray.csv"
$hasharray=@()

$temp | Foreach{
    $elements=$_.split(",")
    $hashArray += ,@($elements[0],$elements[1],$elements[2])
}


$path = $_.'path'
$header2 = $_.'hash'
$header3 = $_.'name'
$header4 = $_.'url'
}
Write-Host $header1.url 
Write-Host $hashArray.name 
Write-Host $hashArray.hash 


{
    Write-Host $hashArray.url 
    Invoke-WebRequest -Method get -Uri $($hashArray.url) -OutFile "$hashArray.path" 
 }

 #       {
 #           $Hashesverify.hash = Get-FileHash $hashArray.hash
 #       }
 #       #Write-Host "GETTING HASH" -ForegroundColor Cyan
 #       Write-Host $Hashesverify.hash -ForegroundColor Cyan
 #       if ($Hashesverify.hash -eq $hasharray.hash) {
 #           Write-Host "EQUAL" -ForegroundColor Cyan
 #           $goodresult = "Hashes equal..continuing," | Out-File "c:\temp\errorlog.txt" -Append
 #       } else {
 #           $errorMessage = "Hash checking failed...STOP" | Out-File "c:\temp\errorlog.txt" -Append
 #           $errormessage | Out-File "c:\temp\errorlog.txt" -Append
 #           #exit
 #       }
    #}
 #
 #
 #