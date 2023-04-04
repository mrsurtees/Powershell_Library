
 cls
 $Result = @()
 Write-Host "Gathering Event Logs, this can take awhile..."
 $ELogs = Get-EventLog System -Source Microsoft-Windows-WinLogon -After (Get-Date).AddDays(-10) 
 If ($ELogs)
 { Write-Host "Processing..."
 ForEach ($Log in $ELogs)
 { If ($Log.InstanceId -eq 7001)
   { $ET = "Logon"
   }
   ElseIf ($Log.InstanceId -eq 7002)
   { $ET = "Logoff"
   }
   Else
   { Continue
   }
   $Result += New-Object PSObject -Property @{
    Time = $Log.TimeWritten
    'Event Type' = $ET
    User = (New-Object System.Security.Principal.SecurityIdentifier $Log.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount])
   }
 }
 }
 $Result | Select Time,"Event Type",User | Sort Time -Descending | out-file C:\rmm-mgmt\logins.txt
 Write-Host "Done."