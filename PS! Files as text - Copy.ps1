Get-ChildItem -Path "C:\Users\msurtees\Desktop\2022 Tableau\" -File | ForEach {Rename-Item $_.FullName -NewName ($_.name).Replace(".ps1",".txt")}
Copy-Item -Path "C:\Users\msurtees\Desktop\2022 Tableau\*.txt" -Recurse "\\Library\Application Support\DEVONthink 3\Inbox"
Get-ChildItem -Path "C:\Users\msurtees\Desktop\2022 Tableau\" -File | ForEach {Rename-Item $_.FullName -NewName ($_.name).Replace(".txt",".ps1")}




<#
.SYNOPSIS
	Writes a random Juck Norris joke to the console
.DESCRIPTION
	This PowerShell script writes a random Juck Norris joke to the console.
.EXAMPLE
	PS> ./write-joke
	When Chuck Norris does division, there are no remainders. 😂
.NOTES
	Author: Markus Fleschutz / License: CC0
.LINK
	https://github.com/fleschutz/PowerShell
#>

try {
	$Table = import-csv "$PSScriptRoot/../Data/jokes.csv"

	$Generator = New-Object System.Random
	$Index = [int]$Generator.next(0, $Table.Count - 1)
	$Joke = $Table[$Index].Joke

	"$Joke 😂"
	exit 0 # success
} catch {
	"⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	exit 1
}
