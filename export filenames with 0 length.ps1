<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2019 v5.6.167
	 Created on:   	11/15/2019 10:50 AM
	 Created by:   	msurtees
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


#get-childitem c:\temp -rec | where { !$_.PSIsContainer } |
#select-object FullName, Length | export-csv -notypeinformation -delimiter ',' -path c:\users\msurtees\desktop\file.csv
#
$path = "c:\zeros"
foreach ($file in $path)
{
#
#$a = Get-ChildItem  | Where-Object {$_.length/1KB -eq 0} | select -ExpandProperty fullname | #,@{n=”Size MB”;e={$_.length/1MB}} 
#Write-Host $a
#copy $a "c:\non-zeros"
#$a = $null
#$a
#}
Get-ChildItem -Path C:\zeros | Where-Object {$_.length/1KB -eq 0} | select fullname,@{n=”Size MB”;e={$_.length/1MB}} |
convertTo-csv -notype | Select-Object -Skip 1 | set-content "c:\rmm-mgmt\log\file.csv"
}



