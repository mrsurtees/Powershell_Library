#%%%%%%%%%%%%%%%%%%
#      Start       #
       Clear-Host
#      PURPOSE:  reads in a csv with headings of "path, hash, name, url".  With these 
#      populated the script will install the requested software...in this case it's
#      for Chartis Tableau
# 
#      Checks if latest Tableau versions are installed and, if not, installs.  Old versions removed.
#%%%%%%%%%%%%%%%%%%

###Get username #####
$liu = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
$userID = $liu.split("\")[1]
$user = New-Object System.Security.Principal.NTAccount($liu) 
$userSID = $user.Translate([System.Security.Principal.SecurityIdentifier]) 

#Poplate for UDF Function
#Ensure there is a user logged in; abort execution if not
#Used a multitude of times...just needs passing of the necessary parameters
$var1 = $userID
$userLog = ""| out-file "c:\temp\errorlog.txt"
$errorMessage = "Tableau: No user logged in"
$goodResult = "Running for user: $var1"

#Ensure there is a user logged in; abort execution if not
#Used a multitude of times...just needs passing of the necessary parameters
function UDF{
    Param
    (
         [Parameter(Mandatory = $false)]  [string]$var1,
         [Parameter(Mandatory = $false)]  [string]$errorMessage, 
         [Parameter(Mandatory = $false)]  [string]$goodResult
    )
        if ($var1 -like "") {
        $verified = "Custom15"
        New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $verified -PropertyType String -Value $errorMessage
        Write-Host $errorMessage
        $errorlog = $errorMessage
        $errorLog | Out-File "c:\temp\errorlog.txt" -Append
        exit
} 
    else {
      $verified = "Custom15"
        New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $verified -PropertyType String -Value $goodResult
        Write-Host $goodResult
        "Detected logged-in user $userID," | Out-File "c:\temp\errorlog.txt" -Append
}}
UDF $var1 $errorMessage $goodResult


#$errorMessage = ""
#$goodResult = ""
#$var1 = "Checking hash"
#%%%%%%%%%%%%%%%%%% DOWNLOAD Tableau INSTALLERS PREP AND DESKTOP %%%%%%%%%%%%%%%%%% 

    Import-Csv C:\temp\installersArray.csv | ForEach-Object {
    "$($_.path)
     $($_.hash)
     $($_.name)
     $($_.url)"
        Write-Host "Downloading $($_.url)"
        Invoke-WebRequest -Uri $($_.url) -OutFile $($_.path)
        $Hashesverify = get-FileHash $($_.path)
        write-host "GETTING HASH" -ForegroundColor Cyan
        Write-Host $Hashesverify.hash -ForegroundColor Cyan
        if ($Hashesverify.hash -eq $($_.hash))
            {Write-Host "EQUAL" -ForegroundColor Cyan
            $goodresult = "Hashes equal..continuing,"| out-file "c:\temp\errorlog.txt" -Append
            }
        else{
            $errorMessage = "Hash checking failed...STOP" | out-file "c:\temp\errorlog.txt" -Append
            $errormessage  | out-file "c:\temp\errorlog.txt" -Append
            exit
            }
   }
    
#%%%%%%%%%%%%%%%%%% CHECK IF LATEST DESKTOP INSTALLED -  INSTALL IF NOT %%%%%%%%%%%%%%%%%% 
$currentDesktopInstalled =  Test-Path 'C:\Program Files\Tableau\Tableau 2022.4\bin\tableau.exe'
if ($currentDesktopInstalled -eq $false) {
        #Install Current Version
        Write-Host "Desktop NOT Installed....installing,"   | Out-File "c:\temp\errorLog.txt" -Append
        start-process  "c:\temp\TableauDesktop-64bit-2022-4-1.exe" -ArgumentList "ACCEPTEULA=1 DESKTOPSHORTCUT=1 REMOVEINSTALLEDAPP=1 /quiet"
}
 else
    {
     "Desktop already installed,"| Out-File "c:\temp\errorLog.txt" -Append
    }

#%%%%%%%%%%%%%%%%%% CHECK IF LATEST PREP INSTALLED -  INSTALL IF NOT %%%%%%%%%%%%%%%%%%
#check for existence...if not there we install 
$currentDesktopInstalled =  Test-Path "C:\Program Files\Tableau\Tableau Prep Builder 2022.4\Tableau Prep Builder.exe"
if ($currentDesktopInstalled -eq $false) 
{
        #Install Current Version
        write-host "Prep NOT Installed....installing," | Out-File "c:\temp\errorLog.txt" -Append
        start-process  "C:\temp\TableauPrep-2022-4-2.exe" -ArgumentList "ACCEPTEULA=1 DESKTOPSHORTCUT=1 REMOVEINSTALLEDAPP=1 /quiet"
}
 else
    {
         "Prep already installed," | Out-File "c:\temp\errorLog.txt" -Append
    }

#%%%%%%%%%%%%%%%%%% LOG AND DELETE OLD Tableau SHORTCUTS %%%%%%%%%%%%%%%%%% 
if (Test-Path "C:\temp\foundShortcuts.csv") {Remove-Item "c:\temp\foundShortcuts.csv"}
write-host "Removing old Tableau Shortcuts" #Removing all but creating new version ones at end.
New-Item -Path "c:\temp\foundShortcuts.csv"
ForEach($file in (Get-ChildItem "C:\users\$userID\appdata\" -Include "*tableau*.lnk" -Recurse) )
    {
    $file.FullName | out-file "c:\temp\foundShortcuts.csv" -Append
    Remove-Item $file.FullName
    }
ForEach($file in (Get-ChildItem "C:\users\Public\Desktop\" -Include "*tableau*.lnk" -Recurse) )
    {
    $file.FullName | out-file "c:\temp\foundShortcuts.csv" -Append
    Remove-Item $file.FullName
}

#Uninstall Old 2021 Preps
$oldPrepRemovals = Get-ChildItem -Recurse -Path "C:\programdata\Package Cache" -Include "Tableau-setup-p*2021*.exe"
$oldPrepRemovals.FullName 
if (Test-Path "C:\temp\foundOldPreps.csv") {Remove-Item "c:\temp\foundOldPreps.csv"}
$oldPrepRemovals.FullName | out-file "c:\temp\foundOldPreps.csv" -Append
start-process  $oldPrepRemovals.FullName -ArgumentList "/uninstall /quiet" -ErrorAction Continue

#Uninstall Old 2020 Preps
$oldPrepRemovals = Get-ChildItem -Recurse -Path "C:\programdata\Package Cache" -Include "Tableau-setup-p*2020*.exe"
$oldPrepRemovals.FullName 
$oldPrepRemovals.FullName | out-file "c:\temp\foundOldPreps.csv" -Append
start-process  $oldPrepRemovals.FullName -ArgumentList "/uninstall /quiet" -ErrorAction Continue

#Uninstall Old 2019 Preps
$oldPrepRemovals = Get-ChildItem -Recurse -Path "C:\programdata\Package Cache" -Include "Tableau-setup-p*2019*.exe"
$oldPrepRemovals.FullName 
$oldPrepRemovals.FullName | out-file "c:\temp\foundOldPreps.csv" -Append
start-process  $oldPrepRemovals.FullName -ArgumentList "/uninstall /quiet" -ErrorAction Continue

#Clean up downloaded files....keep logs
if (Test-Path "C:\temp\TableauPrep-2022-4-2.exe") {Remove-Item "C:\temp\TableauPrep-2022-4-2.exe"}
if (Test-Path "C:\temp\TableauDesktop-64bit-2022-4-1.exe") {Remove-Item "C:\temp\TableauDesktop-64bit-2022-4-1.exe"}

#Populate UDF with install log
$message = Get-Content -Path "C:\temp\errorlog.txt"
$verified = "Custom15"
New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $verified -PropertyType String -Value $Message


#Create Tableau Desktop Shortcuts
#Desktop
$SourceFilePath = "C:\Program Files\Tableau\Tableau 2022.4\bin\Tableau.exe"
$SourceFileLocation = "C:\Program Files\Tableau\Tableau 2022.4\bin\Tableau.exe"
$ShortcutLocation = “C:\Users\Public\Desktop\Tableau 2022.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutLocation)
    $Shortcut.TargetPath = $SourceFileLocation
    $Shortcut.Save()

#Create Tableau Desktop Shortcuts
#Prep
$SourceFilePath = "C:\Program Files\Tableau\Tableau Prep Builder 2022.4\Tableau Prep Builder.exe"
$SourceFileLocation = "C:\Program Files\Tableau\Tableau Prep Builder 2022.4\Tableau Prep Builder.exe"
$ShortcutLocation = “C:\Users\Public\Desktop\Tableau Prep 2022.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutLocation)
    $Shortcut.TargetPath = $SourceFileLocation
    $Shortcut.Save()

