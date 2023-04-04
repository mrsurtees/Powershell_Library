Clear-Host
#%%%%%%%%%%%%%%%%%%
#      Start       #
#      PURPOSE:  reads in a csv with headings of "path, hash, name, url".  With these 
#      populated the script will install the requested software...in this case it's
#      for Chartis Tableau
# 
#      Checks if latest Tableau versions are installed and, if not, installs.  Old versions removed.
#%%%%%%%%%%%%%%%%%%
#all working....get error checking in place
function WriteTo-UDF {
    Param
    (
        [Parameter(Mandatory = $true)]  [int]$UdfNumber,
        [Parameter(Mandatory = $true)]  [string]$UdfMessage
    )
 
    if ($udfNumber -lt 1 -or $UdfNumber -gt 30) {
        $msg = 'Fatal Error in Script Execution\Invalid UDF Number in WriteTo-UDF function call: $($UdfNumber.ToString())'
        Write-Error -Message $msg -Category InvalidArgument -ErrorAction Stop
 
    }

    $udfName = 'Custom' + $UdfNumber.ToString()
    $Result = New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $udfName -PropertyType 'String' -Value $UdfMessage

}

function Delete-OldTableauPrep {
    Param (
        [Parameter(Mandatory = $true)] [String] $Year
    )

    $oldPrepRemovals = Get-ChildItem -Recurse -Path "C:\programdata\Package Cache" -Include "Tableau-setup-p*$Year*.ext"
    if ($oldPrepRemovals -eq "") {
        Write-Verbose "No preps found for year $Year... "
    } else {
        foreach ($opr in $oldPrepRemovals) {
            Write-Verbose "Removing file: $($opr.FullName)"
            $opr.FullName | Out-File "C:\temp\errorlog.txt" -Append
            try {
                Start-Process $opr.FullName -ArgumentList "/uninstall /quiet"
            } catch {
                Write-Verbose "The Old Prep removal for $($opr.FullName) failed."
                Write-Error -Message "Removal of $($opr.FullName) failed" -Category InvalidOperation -ErrorAction Continue
            }
        }
    }
}

#remove and create log file
if (-not (Test-Path "c:\temp")) {
    New-Item -Path "c:\temp"
}
if (Test-Path "c:\temp\errorlog.txt") {
    Remove-Item -Path "c:\temp\errorlog.txt"
} else {
    New-Item -Path "c:\temp\errorlog.txt"
}


###Get username #####
$liu = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName

###$userID needs to be error checked since issues are possible
$userID = $liu.split("\")[1]
$user = New-Object System.Security.Principal.NTAccount($liu) 
$userSID = $user.Translate([System.Security.Principal.SecurityIdentifier]) 
$UdfContent = ""

#Ensure there is a user logged in; abort execution if not
if ($userID -like "") {
    WriteTo-UDF -udfNumber 15 -UdfMessage "No User Logged In"
    $UdfContent += "_User:NO| "
    Write-Error -Message "Error: No user logged into system. Script execution terminating." -Category ObjectNotFound -ErrorAction Stop
}

# For the necessary parameters received from other functions
# downloadFilesHashes

#import our csv containing data as outlined at top of scrtipt
$Installers = Import-Csv C:\temp\installersArray.csv 
foreach ($Installer in $Installers) {

    try {
        #Invoke-WebRequest -Uri $Installer.url -OutFile $Installer.path
        $UdfContent += "_IVWR:Invoke OK| "
    } catch {
        WriteTo-UDF -UdfNumber 15 -UdfMessage "Invoke-WebRequest Failed. We stop."
        Write-Error -Message "Invoke-WebRequest Failed. Installation Archive not downloaded." -Category OpenError -ErrorAction Stop
        $UdfContent += "_IVWR:Invoke ERROR| "
    }

    $Hashesverify = Get-FileHash $Installer.path
    #write-hosts for testing
    Write-Verbose "GETTING HASH"
    Write-Verbose $Hashesverify.hash

    if ($Hashesverify.hash -eq $Installer.hash) {
        Write-Verbose "Hashes match - proceeding"
    } else {
        WriteTo-UDF -udfNumber 15 -UdfMessage "Archive Hash Mismatch"
        Write-Error -Message "Hashes do not match - corrupt Installers Archive detected." -Category InvalidData -ErrorAction Stop 
        $UdfContent += "_InstallerHash:hash Failed|"
    } 
    
}

#Desktop Install
$ExePath = 'C:\Program Files\Tableau\Tableau 2022.4\bin\tableau.exe'
$fileExists = Test-Path $ExePath  -erroraction continue
if ($fileExists) {
    $UdfContent = "_Desktop:PreExisting|"
    Write-Verbose "Current Desktop version already installed"
} else {
    Write-Verbose "Current Desktop is not installed."

    # Find Shortcuts
    ForEach ($file in (Get-ChildItem "C:\users\$userID\appdata\" -Include "*tableau*.lnk" -Recurse) ) {

        Remove-Item $file.FullName
    }
    ForEach ($file in (Get-ChildItem "C:\users\Public\Desktop\" -Include "*tableau*.lnk" -Recurse) ) {
        Remove-Item $file.FullName
    }

    #Install Current Version
    Write-Verbose "Current Desktop NOT Installed....installing" 
    $UdfContent += "_Destop:Installed|"

   
    $p = Start-Process "c:\temp\TableauDesktop-64bit-2022-4-1.exe" -ArgumentList "ACCEPTEULA=1 DESKTOPSHORTCUT=1 REMOVEINSTALLEDAPP=1 /quiet" -PassThru
    $p.WaitForExit()
 
    $UdfContent += "_Destop:Installed "
    $fileExists = Test-Path $ExePath
    if ($fileExists) {
        Write-Verbose "Current Desktop is installed!"
        $UdfContent = "_Desktop:NewInstall |"
    } else {
        WriteTo-UDF -UdfNumber 15 -UdfMessage "Desktop Install Failed"
        $UdfContent += "_Desktop:NO "
        Write-Error -Message "Installation process failed: Executable not found" -Category InvalidResult -ErrorAction Stop
    }
}

#Prep Install
#check for existence...not there we install
$PrepPath = "C:\Program Files\Tableau\Tableau Prep Builder 2022.4\Tableau Prep Builder.exe"
$fileExists = Test-Path $PrepPath
$p = Start-Process "C:\temp\TableauPrep-2022-4-2.exe" -ArgumentList "ACCEPTEULA=1 DESKTOPSHORTCUT=1 REMOVEINSTALLEDAPP=1 /quiet" -PassThru
$p.WaitForExit()
if ($fileExists) {
    $UdfContent += "_Prep:PreExisting|"
    Write-Verbose "Current Prep version already installed"
} else {
    #Install Current Version
    $UdfContent += "_Prep:NO| "
    Write-Verbose "Prep NOT Installed....installing Prep"
    Start-Process "c:\temp\TableauPrep-2022-4-2.exe" -ArgumentList "ACCEPTEULA=1 DESKTOPSHORTCUT=1 /quiet"
}

# import installersAray.csv into array
# loop through the array
# foreach: compare $installed.installedhash with get-filehash $installed.installedpath
# if $installed.installedhash -eq $get-filehash $installed.installedpath
# EQUAL:  we know exe is good.  Move one
# NOT-EQUAL  STOP.  Hashes don't match
$installed = Import-Csv -Path "C:\temp\installersArray.csv"
foreach ($i in $installed) {
    if ($i.installedhash -eq $(Get-FileHash $i.installedpath).hash) {
        Write-Verbose "$($i.installedname) is OK:  hashes match" 
        $UdfContent += "_InstallerHash:YES| " 
    }
    else {
        Write-Verbose "$($i.installedname) has an incorrect hash so we must stop."
        writeto-udf -udfNumber 15 "$($i.installedName) hash is incorrect so we must stop"
        $UdfContent += "_InstallerHash:NO| "
        Write-Error -Message "We have bad hash" -Category InvalidData -ErrorAction Stop
    }
}

$UdfContent
# Uninstall Old 2021 Preps
Delete-OldTableauPrep -Year 2021

# Uninstall Old 2020 Preps
Delete-OldTableauPrep -Year 2020

# Uninstall Old 2019 Preps
Delete-OldTableauPrep -Year 2019



if (Test-Path "C:\temp\TableauPrep-2022-4-2.exe") 
    {Remove-Item "C:\temp\TableauPrep-2022-4-2.exe"
    }
if (Test-Path -path "C:\temp\TableauDesktop-64bit-2022-4-1.exe")
    {Remove-Item "C:\temp\TableauDesktop-64bit-2022-4-1.exe"}

$UdfContent += "_SCRIPT:DONE"


