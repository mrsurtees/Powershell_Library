Clear-Host
#%%%%%%%%%%%%%%%%%%start
#Change Error Action to Stop by default
#$ErrorActionPreference = "Continue"
Clear-Host
###Get username #####
$liu = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
$userID = $liu.split("\")[1]
$user = New-Object System.Security.Principal.NTAccount($liu) 
$userSID = $user.Translate([System.Security.Principal.SecurityIdentifier]) 

#Ensure there is a user logged in; abort execution if not
$errorLog | out-file "c:\temp\errorlog.txt"
    if ($userID -like "") {
        $verified = "Custom15"
        New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $verified -PropertyType String -Value "Tableau: No user logged in"
        $errorlog = "STOP - Tableau: No user logged in"
        $errorLog | Out-File "c:\temp\errorlog.txt" -Append
        #exit
} 
    else {
      $verified = "Custom15"
        New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $verified -PropertyType String -Value "Running for user: $userID"
        Write-Host "Detected logged-in user: $userID"
        "Detected logged-in user: $userID" | Out-File "c:\temp\errorlog.txt" -Append
}



#new-item -Path "c:\temp\foundShortcuts.csv" -ErrorAction Ignore
#new-item -path "c:\temp\installersarray.csv" -ErrorAction ignore

#%%%%%%%%%%%%%%%%%% FUNCTION DOWNLOAD Tableau INSTALLERS PREP AND DESKTOP %%%%%%%%%%%%%%%%%% 
function downloadFilesHashes {
    Import-Csv C:\temp\installersArray.csv | ForEach-Object {
    "$($_.path)
     $($_.hash)
     $($_.name)
     $($_.url)"
        #Write-Host "Downloading $($_.url)"
        Invoke-WebRequest -Uri $($_.url) -OutFile $($_.path)
        $Hashesverify = get-FileHash $($_.path)
        write-host "GETTING HASH" -ForegroundColor Cyan
        Write-Host $Hashesverify.hash -ForegroundColor Cyan
        if ($Hashesverify.hash -eq $($_.hash))
            {Write-Host "EQUAL" -ForegroundColor Cyan
            #udf
            }
        else
            {Write-error "The HASHES don't Match."  -ForegroundColor red
             #udf
            }
    } 
}

#%%%%%%%%%%%%%%%%%% CHECK IF LATEST DESKTOP INSTALLED -  INSTALL IF NOT %%%%%%%%%%%%%%%%%% 
FUNCTION DesktopInstall{
$currentDesktopInstalled =  Test-Path 'C:\Program Files\Tableau\Tableau 2022.4\bin\tableau.exe'
if ($currentDesktopInstalled -eq $false) {
        #Install Current Version
        Write-Host "NOT Installed....installing"  -ForegroundColor red
        start-process  "c:\temp\TableauDesktop-64bit-2022-4-1.exe" -ArgumentList "ACCEPTEULA=1 DESKTOPSHORTCUT=1 REMOVEINSTALLEDAPP=1 /quiet"
        #/log c:\users\msurtees\desktop\LOGS\log.txt"
}
    else
    {#STOP HERE  UDF UPDATE GOES HERE
     write-host "Current Desktop version already installed" -ForegroundColor Cyan}
} 


#%%%%%%%%%%%%%%%%%% CHECK IF LATEST PREP INSTALLED -  INSTALL IF NOT %%%%%%%%%%%%%%%%%%
FUNCTION PrepInstall{
#check for existence...not there we install
$currentPrepInstalled =  Test-Path 'C:\Program Files\Tableau\Tableau Prep Builder 2022.4\Tableau Prep Builder.exe'
if ($currentPrepInstalled -eq $false) {
        #Install Current Version
        Write-Host "NOT Installed....installing Prep"  -ForegroundColor red
        start-process  "c:\temp\TableauPrep-2022-4-2.exe" -ArgumentList "ACCEPTEULA=1 DESKTOPSHORTCUT=1 /quiet"
        #/log c:\users\msurtees\desktop\LOGS\log.txt"
}
    else
    {
     write-host "Current Prep version already installed" -ForegroundColor Cyan
     }
} 

#%%%%%%%%%%%%%%%%%% LOG AND DELETE OLD Tableau SHORTCUTS %%%%%%%%%%%%%%%%%% 
function findShortcuts{
    #$oldPreps = (Get-ChildItem "C:\users\$userID\appdata\" -Include "tableau*.lnk" -Recurse)
    remove-item -path "c:\temp\foundShortcuts.csv"
    New-Item -Path "c:\temp\foundShortcuts.csv"
    ForEach($file in (Get-ChildItem "C:\users\$userID\appdata\" -Include "*tableau*.lnk" -Recurse) )
    {
    $file.FullName | out-file "c:\temp\foundShortcuts.csv" -Append
    Remove-Item $file.FullName
    #write-Host "$file.name"
    }
    ForEach($file in (Get-ChildItem "C:\users\Public\Desktop\" -Include "*tableau*.lnk" -Recurse) )
    {
    $file.FullName | out-file "c:\temp\foundShortcuts.csv" -Append
    Remove-Item $file.FullName
}}


function uninstallOldPreps{
    #remove-item "C:\temp\foundOldPreps.csv"
    #$file = "d" #$oldPreps = (Get-ChildItem "C:\users\$userID\appdata\" -Include "tableau*.lnk" -Recurse)
    ForEach($filePrep in (Get-ChildItem "c:\program files\Tableau\" -Include "Tableau*2021*Prep*.exe"   -Recurse) )
        {
            $filePrep.fullName | out-file "c:\temp\foundOldPreps.csv" -Append
            #start-process $filePrep.fullname -ArgumentList "/uninstall /quiet"
            #Start-Process -FilePath "C:\temp\TableauPrep-2022-4-2.exe" -ArgumentList -ArgumentList "/uninstall /quiet"
            #write-host "$filePrep /uninstall /quiet"
            start-process  "c:\temp\TableauPrep-2021-4-4.exe" -ArgumentList "/quiet /uninstall"
        }

}

#Download files and verify them. 
    downloadFilesHashes
    DesktopInstall
#If not installed, start the install.
    PrepInstall
#find old Tableau Shortcuts
    findShortcuts
#find and uninstall old Prep versionss
uninstallOldPreps
