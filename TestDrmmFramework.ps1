<#
    Script: TestDrmmFramework.ps1

    Framework for testing Datto RMM behaviors. Establishes basic functions such as writing to a UDF and detecting the logged-in user.
#>

<#
    Function Declarations
#>

function WriteTo-UDF {
    Param
    (
        [Parameter(Mandatory = $true)]  [string]$UdfNumber,
        [Parameter(Mandatory = $true)]  [string]$UdfMessage
    )
 
    if ([int16] $udfNumber -lt 1 -or [int16] $UdfNumber -gt 30) {
        $msg = 'Fatal Error in Script Execution\Invalid UDF Number in WriteTo-UDF function call: $($UdfNumber.ToString())'
        Write-Error -Message $msg -Category InvalidArgument -ErrorAction Stop
 
    }

    $udfName = 'Custom' + $UdfNumber.ToString()
    $Result = New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $udfName -PropertyType 'String' -Value $UdfMessage

}

function Get-LoggedInUser {

    try {
        $AntecedentRegex = '.+Name = "(.+)".+Domain = "(.+)"'
        $DependentRegex = '.+LogonId = "(\d+)"'

        $LoggedOnUsers = [System.Collections.Generic.List[PsCustomObject]]::New()
        $SessionUser = @{}

        $LogonType = @{
            "0"="Local System"
            "2"="Interactive (Local logon)"
            "3"="Network (Remote logon)"
            "4"="Batch (Scheduled task)"
            "5"="Service (Service account logon)"
            "7"="Unlock (Screen saver)"
            "8"="NetworkCleartext (Cleartext network logon)"
            "9"="NewCredentials (RunAs using alternate credentials)"
            "10"="RemoteInteractive (RDP\TS\RemoteAssistance)"
            "11"="CachedInteractive (Local w\cached credentials)"
        }

        $LogonSessions = @(Get-CimInstance -Class Win32_LogonSession)
        $LogonUsers = @(Get-CimInstance -Class Win32_LoggedOnUser)

        foreach ($User in $LogonUsers) {
            $User.antecedent -match $AntecedentRegex > $nul
            $UserName = $matches[2] + "\" + $matches[1]
            $User.dependent -match $DependentRegex > $nul
            $session = $matches[1]
            $sessionUser[$session] += $UserName 
        }

        foreach ($Session in $LogonSessions) {
            if (($Session.logontype -eq 2) -and ($session.authenticationpackage -ne 'Negotiate')) {
                $lgu = [PsCustomObject] @{
                    Session = $Session.logonid
                    User = $SessionUser[$Session.logonid]
                    Type = $Session.logontype
                    LogonType = $LogonType[$Session.logontype.ToString()]
                    Auth = $Session.authenticationpackage
                    StartTime = $Session.starttime
                }
                $LoggedOnUsers.Add($lgu)
            }
        }
        $LoggedOnUsers = $LoggedOnUsers | Sort-Object -Property Session
        $Liu = $LoggedOnUsers[0]
    }
    catch {
        Write-Host "Error detecting LoggedInUser..."
        $Liu = "Get-LoggedInUser Error"
    }

    return $Liu

}

<#
    Step 1 - Declare Constants and Global Variables
#>

# Constant declarations
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$UDF = '15'
$RootFolder = 'c:\'
$TempFolder = '\temp'
$TestFolder = 'drmm-incident_4431020'
$TempPath = Join-Path -path $RootFolder -ChildPath $TempFolder
$TestPath = Join-Path -Path $TempPath -ChildPath $TestFolder


# List variable declarations
$DownloadTargets = [System.Collections.Generic.List[PsCustomObject]]::New()


# Job control variable declarations
$DeleteTestFolder = $true
$DeleteTempFolder = $false
$RunMode = 'Interactive'
$UdfResult = ""


# Prepare list with target download file information

$BlankTimeSpan = New-TimeSpan

# Large file
$file = [PsCustomObject] @{
    Name = "Large"
    FileName = "large_file.txt"
    Url = "https://www.dropbox.com/s/dh2w5qhs03ndhmr/1gig.txt?dl=1"
    Hash = "49BC20DF15E412A64472421E13FE86FF1C5165E18B2AFCCF160D4DC19FE68A14"
    HashMatch = $false
    Time = $BlankTimeSpan
}

$DownloadTargets.Add($file)


# Medium file
$file = [PsCustomObject] @{
    Name = "Medium"
    FileName = "medium_file.txt"
    Url = "https://www.dropbox.com/s/uu7bul7spzh6mhw/50mg.txt?dl=1"
    Hash = "8565A714DCA840F8652C5BAE9249AB05F5FB5A4F9F13FBE23304B10F68252DA2"
    HashMatch = $false
    Time = $BlankTimeSpan
}

$DownloadTargets.Add($file)


# Small file
$file = [PsCustomObject] @{
    Name = "Small"
    FileName = "small_file.txt"
    Url = "https://www.dropbox.com/s/1d03pqtsxleqpkz/1meg.txt?dl=1"
    Hash = "30E14955EBF1352266DC2FF8067E68104607E750ABB9D3B36582B8AF909FCB58"
    HashMatch = $false
    Time = $BlankTimeSpan
}

$DownloadTargets.Add($file)

Remove-Variable $file


<#
    Prepare and validate test environment
#>

Clear-Host

# Make sure c:\temp folder exists

if (-not (Test-Path -Path $TempFolder)) {
    Write-Verbose "C:\Temp folder did not exist. Creating now..."
    $z = New-Item -Path $RootFolder -Name $TempFolder -ItemType Directory
    $DeleteTempFolder = $true
}

Set-Location -Path $TempFolder


# Make sure test folder exists

if (-not (Test-Path -Path $TestFolder)) {
    Write-Verbose "Test folder did not exsist. Creating now..."
    $z = New-Item -Name $TestFolder -ItemType Directory
}


# Make sure test folder is empty

$FilesFound = Get-ChildItem -Path $TestPath

if ($FilesFound.Count -gt 0l) {
    Write-Verbose "Files found in test folder. Removing now..."
    Remove-Item -Path $TestPath\*.*
}

Set-Location $TestPath


# Determine run mode

if (Test-Path -Path 'env:RUNMODE') {
    $RunMode = $env:RUNMODE
    Write-Verbose "Running in component mode"
}
else {
    Write-Verbose "Running in interactive mode"
}


<#
    Run download test
#>

foreach ($file in $DownloadTargets) {
    Write-Verbose "Downloading file $($file.Name)"
    $t = Measure-Command {
        Invoke-WebRequest -Uri $file.Url -OutFile $file.FileName
    }
    $Hash = Get-FileHash -Path $file.FileName

    if ($Hash.hash -eq $file.Hash) {
        $File.HashMatch = $true
    }
    $file.Time = $t
    $UdfResult += "$($File.Name): $($File.Time) "
}


# Calculate total test duration

$TotalTime = $DownloadTargets.Time | Measure-Object -Property TotalSeconds -Sum


<#
    Output test results
#>

Write-Output "`nTotal time elapsed in seconds: $($TotalTime.Sum)"
Write-Output "Individual file results:"
Write-Output ($DownloadTargets | Select-Object -Property Name, Time, HashMatch | format-table) -NoEnumerate
Write-Output "UDF update string: $UdfResult"

if ($RunMode -eq "Component") {
    WriteTo-UDF -UdfNumber $UDF -UdfMessage $UdfResult
}


<#
    Clean up after ourselves
#>


# Empty Test folder

$FilesFound = Get-ChildItem -Path $TestPath

if ($FilesFound.Count -gt 0) {
    Remove-Item -Path $TestPath\*.*
}

Set-Location -Path $RootFolder

if (Test-Path -Path $TestPath) {
    Remove-Item -Path $TestPath
}

if ($DeleteTempFolder) {
    Remove-Item -Path $TempPath
}

Write-Verbose "Script run ended."