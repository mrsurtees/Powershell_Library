<#
.SYNOPSIS
	Writes text in lowercase letters
.DESCRIPTION
	This PowerShell script writes text in lowercase letters.
.PARAMETER text
	Specifies the text to write
.EXAMPLE
	PS> ./write-lowercase "Hello World"
.NOTES
	Author: Markus Fleschutz / License: CC0
.LINK
	https://github.com/fleschutz/PowerShell
#>

param([string]$text = "")

if ($text -eq "" ) { $text = Read-Host "Enter the text to write" }

Write-Output $text.ToLower()
#exit 0 # success
