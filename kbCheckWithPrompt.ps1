
$content_string = Get-Content "C:\temp\userResponse.txt"
$kb = gc "C:\temp\kb.txt"

((get-hotfix -id "$content_string").hotfixid )  | Add-Content C:\temp\kb.txt 
 
$content_string; $kb

If ($content_string -notlike $kb) {Write-Host "POOP"}
else {
Add-Content C:\temp\kb.txt $content_string 
}

