-- -
created: 2022-08-03T13:08:20Z
language: PowerShell
modified: 2022-08-03T13:08:58Z
title: untitled snippet
-- -

#edit 
$text = "cmd.exe /c" "cd C:\Program Files\Microsoft Office\Office16 & cscript ospp.vbs /dstatus"
foreach ($t in $text) {
    if ($t -like "Last 5 characters*") {
        $key = $t.Trim("Last 5 characters of installed product key: ")
        cmd.exe /c "cd C:\Program Files\Microsoft Office\Office16 & cscript ospp.vbs /unpkey:$key"            
    }
}
#

Restart-Computer


