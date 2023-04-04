Clear-Host
#%%%%%%%%%%%%%%%%%%
#      Start       #
#      PURPOSE:  reads in a csv with headings of "path, hash, name, url".  With these 
#      populated the script will install the requested software...in this case it's
#      for Chartis Tableau
# 
#      Checks if latest Tableau versions are installed and, if not, installs.  Old versions removed.
#%%%%%%%%%%%%%%%%%%

#remove and create log file
if (Test-Path "c:\temp\errorlog.txt") {
    Remove-Item -Path "c:\temp\errorlog.txt"
} else {
    New-Item -Path "c:\temp\errorlog.txt"
}
#remove and create log file
if (Test-Path "C:\temp\foundShortcuts.csv") {
    Remove-Item -Path "c:\temp\errorlog.txt"
} else {
    New-Item -Path "C:\temp\foundShortcuts.csv"
}



###Get username #####
$liu = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
###$userID needs to be error checked since issues are possible
$userID = $liu.split("\")[1]
$user = New-Object System.Security.Principal.NTAccount($liu) 
$userSID = $user.Translate([System.Security.Principal.SecurityIdentifier]) 
<#  FV - COMMENT 
    Now the Error check for username is here
#Ensure there is a user logged in; abort execution if not #>
if ($userid -like "") {
    $verified = "Custom15"
    New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $verified -PropertyType String -Value "No user logged in"
    Write-Error -Message "Error: No user logged into system. Script execution terminating." -Category ObjectNotFound -ErrorAction Stop
    EXIT
} else {
    $verified = "Custom15"
    New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $verified -PropertyType String -Value "Running for user: $userid"
    Write-Host "Detected logged-in user: $liu"
}

# For the necessary parameters received from other functions
function UDF {
    Param
    (
        [Parameter(Mandatory = $false)]  [string]$var1,
        [Parameter(Mandatory = $false)]  [string]$errorMessage, 
        [Parameter(Mandatory = $false)]  [string]$goodResult
    )
    <#  FV - COMMENT
            UDF Function now used throughout the script
            Still not portable enough
           #>
        
    if ($var1 -like "") {
        $verified = "Custom15"
        New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $verified -PropertyType String -Value $errorMessage
        $errorlog = $errorMessage
        $errorLog | Out-File "c:\temp\errorlog.txt" -Append
        exit
    } else {
        $verified = "Custom15"
        New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $verified -PropertyType String -Value $goodResult
        Write-Host $goodResult
        "Detected logged-in user: $userID" | Out-File "c:\temp\errorlog.txt" -Append
    }
}

#%%%%%%%%%%%%%%%%%% FUNCTION DOWNLOAD Tableau INSTALLERS PREP AND DESKTOP %%%%%%%%%%%%%%%%%% 
function downloadFilesHashes {
    <#  FV - COMMENT
        Added more comments for the steps
        Ran into issues/confusion when assigning to a var...moved on
        #>
    #populate possible messages for UDF Function
    $errorMessage = "Hashes don't match"
    $goodResult = "Hashes match....moving on"
    $goodResult | Out-File "c:\temp\errorlog.txt" -Append
    $var1 = "Checking hash"
    #import our csv containing data as outlined at top of scrtipt
    #NEEDS VAR ASSIGNMENT BUT RAN INTO ISSUES
    Import-Csv C:\temp\installersArray.csv | ForEach-Object {
        #each item from the csv populates these:
        "$($_.path)
     $($_.hash)
     $($_.name)
     $($_.url)"

        Invoke-WebRequest -Uri $($_.url) -OutFile $($_.path)
        
        
        #$testing = Test-Path "$($_.path)" 
        #if ($testing = $false) {Invoke-WebRequest -Uri $($_.url) -OutFile $($_.path)}
        #else 
        #{
        #write-host "We have an issue...stop"
        #UDF $var1 $errorMessage $goodResult
        #exit
        #}
        $Hashesverify = Get-FileHash $($_.path)
        #write-hosts for testing
        Write-Host "GETTING HASH" -ForegroundColor Cyan
        Write-Host $Hashesverify.hash -ForegroundColor Cyan
        if ($Hashesverify.hash -eq $($_.hash)) {
            Write-Host "EQUAL" -ForegroundColor Cyan
            #$errorMessage = "Hashes equal..continuing"| out-file "c:\temp\errorlog.txt" -Append
            UDF $var1 $goodResult

        } else {
            $errorMessage = "Hash checking failed" | Out-File "c:\temp\errorlog.txt" -Append
            UDF $var1 $errorMessage 
            exit
        }
    
    } 
}

#%%%%%%%%%%%%%%%%%% CHECK IF LATEST DESKTOP INSTALLED -  INSTALL IF NOT %%%%%%%%%%%%%%%%%% 
FUNCTION DesktopInstall {
    #populate messages for UDF 
    $errorMessage = "N"
    $goodResult = "Already installed"
    $goodResult | Out-File "c:\temp\errorlog.txt" -Append
    $var1 = "Checking hash"
    $currentDesktopInstalled = Test-Path 'C:\Program Files\Tableau\Tableau 2022.4\bin\tableau.exe'
    if ($currentDesktopInstalled -eq $True) {
            UDF $var1 $goodResult
        Write-Host "Current Desktop version already installed" -ForegroundColor Cyan
  } else {
       #Install Current Version
        Write-Host "NOT Installed....installing" -ForegroundColor red
        UDF $var1 $errorMessage 
        Start-Process "c:\temp\TableauDesktop-64bit-2022-4-1.exe" -ArgumentList "ACCEPTEULA=1 DESKTOPSHORTCUT=1 REMOVEINSTALLEDAPP=1 /quiet"
   
    }
} 


#%%%%%%%%%%%%%%%%%% CHECK IF LATEST PREP INSTALLED -  INSTALL IF NOT %%%%%%%%%%%%%%%%%%
FUNCTION PrepInstall {
    #check for existence...not there we install
    #populate messages for UDF 
    $errorMessage = "Prep Not installed...installing"
    $goodResult = "Prep Already installed"
    $goodResult | Out-File "c:\temp\errorlog.txt" -Append
    $var1 = "Checking hash"
    $currentPrepInstalled = Test-Path 'C:\Program Files\Tableau\Tableau Prep Builder 2022.4\Tableau Prep Builder.exe'
    if ($currentPrepInstalled -eq $false) {
        #Install Current Version
        Write-Host "NOT Installed....installing Prep" -ForegroundColor red
        UDF $var1 $errorMessage $goodResult
        Start-Process "c:\temp\TableauPrep-2022-4-2.exe" -ArgumentList "ACCEPTEULA=1 DESKTOPSHORTCUT=1 /quiet"
    } else {
        UDF $var1 $errorMessage 
        Write-Host "Current Prep version already installed" -ForegroundColor Cyan
    }
} 

#%%%%%%%%%%%%%%%%%% LOG AND DELETE OLD Tableau SHORTCUTS %%%%%%%%%%%%%%%%%% 
function findShortcuts {
    Remove-Item -Path "c:\temp\foundShortcuts.csv"
    New-Item -Path "c:\temp\foundShortcuts.csv"
    ForEach ($file in (Get-ChildItem "C:\users\$userID\appdata\" -Include "*tableau*.lnk" -Recurse) ) {
        $file.FullName | Out-File "c:\temp\foundShortcuts.csv" -Append
        Remove-Item $file.FullName
    }
    ForEach ($file in (Get-ChildItem "C:\users\Public\Desktop\" -Include "*tableau*.lnk" -Recurse) ) {
        $file.FullName | Out-File "c:\temp\foundShortcuts.csv" -Append
        Remove-Item $file.FullName
    }
}

####EXECUTE FUNCTIONS####
downloadFilesHashes
DesktopInstall
PrepInstall
findShortcuts

#Uninstall Old 2021 Preps

$oldPrepRemovals = Get-ChildItem -Recurse -Path "C:\programdata\Package Cache" -Include "Tableau-setup-p*2021*.exe"
if ($oldPrepRemovals -eq "") {
    Write-Host "No old 2021s so Move on..."
} else {

    $oldPrepRemovals.FullName 
    $oldPrepRemovals.FullName | Out-File "C:\temp\errorlog.txt" -Append
    try {
        Start-Process $oldPrepRemovals.FullName -ArgumentList "/uninstall /quiet"
    } catch {
        Write-Host "no download"
    }
}

#Uninstall Old 2020 Preps
$oldPrepRemovals = Get-ChildItem -Recurse -Path "C:\programdata\Package Cache" -Include "Tableau-setup-p*2020*.exe"
if ($oldPrepRemovals -eq "") {
    $oldPrepRemovals.FullName 
    $oldPrepRemovals.FullName | Out-File "c:\temp\foundOldPreps.csv" -Append
    try {
        Start-Process $oldPrepRemovals.FullName -ArgumentList "/uninstall /quiet"
    } catch {
        Write-Host "no download"
    }
} else {
    Write-Host "No old 2020s so Move on..."
}


#Uninstall Old 2019 Preps
$oldPrepRemovals = Get-ChildItem -Recurse -Path "C:\programdata\Package Cache" -Include "Tableau-setup-p*2019*.exe"
if ($oldPrepRemovals -eq "") {
    $oldPrepRemovals.FullName 
    $oldPrepRemovals.FullName | Out-File "c:\temp\foundOldPreps.csv" -Append
    try {
        Start-Process $oldPrepRemovals.FullName -ArgumentList "/uninstall /quiet"
    } catch {
        Write-Host "no download"
    }
} else {
    Write-Host "No old 2019s so Move on..."
}

#%%%%%%%%%%%%%%%%%% Create New Tableau Shortcuts %%%%%%%%%%%%%%%%%% 
#Create out shortcuts for the new apps
#Prep
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("c:\users\public\Desktop\Tableau Prep Builder 2022.4.lnk")
$Shortcut.TargetPath = "C:\Program Files\Tableau\Tableau Prep Builder 2022.4\Tableau Prep Builder.exe"
$Shortcut.Save()
#Desktop
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("c:\users\public\Desktop\Tableau 2022.4.lnk")
$Shortcut.TargetPath = "C:\Program Files\Tableau\Tableau 2022.4\bin\tableau.exe"
$Shortcut.Save()

#Clean up downloaded files....keep logs
#if (Test-Path "C:\temp\TableauPrep-2022-4-2.exe") {Remove-Item "C:\temp\TableauPrep-2022-4-2.exe"}
#if (Test-Path "C:\temp\TableauDesktop-64bit-2022-4-1.exe") {Remove-Item "C:\temp\TableauDesktop-64bit-2022-4-1.exe"}

#just while testing
Write-Host "Script complete"
