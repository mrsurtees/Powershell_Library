$test_boot = if (Test-Path $env:windir\Panther\setupact.log)
{(Select-String "Detected boot environment" -Path "$env:windir\Panther\setupact.log"  -AllMatches).line -replace '.*:\s+'} else {if (Test-Path HKLM:\System\CurrentControlSet\control\SecureBoot\State) {"UEFI"} else {"BIOS"}}  
$test_boot   | out-file "C:\rmm-mgmt\boot_method.txt"

