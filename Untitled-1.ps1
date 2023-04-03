Get-ChildItem -Path "C:\Users\msurtees\Desktop\2022 Tableau\" -File | ForEach-Object { Rename-Item $_.FullName -NewName ($_.name).Replace(".ps1", ".txt") }
Copy-Item -Path "C:\Users\msurtees\Desktop\2022 Tableau\*.txt" -Recurse '\\Mac\Home\Library\Application Support\DEVONthink 3\Inbox'
Get-ChildItem -Path "C:\Users\msurtees\Desktop\2022 Tableau\" -File | ForEach-Object { Rename-Item $_.FullName -NewName ($_.name).Replace(".txt", ".ps1") }

Copy-Item 'C:\Users\msurtees\Desktop\Copy PS! Files as text.ps1' '\\Mac\Home\Library\Application Support\DEVONthink 3\Inbox'
$
 = @{
    Name = Value
}



gg