#%%%%%%%%%%%%%%%%%%
#      Start       #
#      PURPOSE:  reads in a csv with headings of "path, hash, name, url".  With these 
#      populated the script will install the requested software...in this case it's
#      for Chartis Tableau
# 
#      Checks if latest Tableau versions are installed and, if not, installs.  Old versions removed.
#%%%%%%%%%%%%%%%%%%

#
#

function UDF{
    Param
    (
         [Parameter(Mandatory = $false)]  [string]$var1,
         [Parameter(Mandatory = $false)]  [string]$errorMessage, 
         [Parameter(Mandatory = $false)]  [string]$goodResult
    )

        <#  FV - COMMENT
            Code to update the UDF is encapsulated into this function, which is good development practice; however, so is the code to
            determine if the UserID is blank and the script should stop executing. This makes the function less portable and introduces
            significant codependence with unrelated code.
        #>

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

## Main body of script starts here

Clear-Host

###Get username #####
$liu = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
$userID = $liu.split("\")[1]

<#  FV - COMMENT

    The preceding method does not account for the few scenarios where the Get-CimInstance call failes. There should
    be a conditional statement testing for an empty $UserID, falling back onto the method Datto suggested, which is based on
    reading the owner of the Explorer process in Windows. This should be done befoe trying to determine the SID for the logged in user.
#>

$user = New-Object System.Security.Principal.NTAccount($liu) 
$userSID = $user.Translate([System.Security.Principal.SecurityIdentifier]) 


#Poplate for UDF Function
#Ensure there is a user logged in; abort execution if not
#Used a multitude of times...just needs passing of the necessary parameters

<#  FV - COMMENT
    The logic to test if no logged-in user has been detected is split between the assignment below and the code within the UDF function.
    This makes it very difficult to understand what the script is doing.
#>

$var1 = $userID
$userLog = ""| out-file "c:\temp\errorlog.txt"

$errorMessage = "Tableau: No user logged in"
$goodResult = "Running for user: $var1"

<#  FV - COMMENT
    Coding practices: the function call below is an example of both poor coding practices and of missed opportunity. First,
    in a script a function call should always use explicit naming for the arguments, as it improves readability. Second, the
    function should return a value so that the calling code can determine whether it was successful and make appropriate decisions.
#>
UDF $var1 $errorMessage $goodResult

#%%%%%%%%%%%%%%%%%% DOWNLOAD Tableau INSTALLERS PREP AND DESKTOP %%%%%%%%%%%%%%%%%% 

<#  FV - COMMENT
    Coding practices: the code below is unclear in its purpose, and the comments do not mnitigate this. Issues:
        1. The contents of the control file are read into the pipeline but not stored anywhere. 
        2. The contents of the control file are sent to StdOut, only to immediately be sent to StdOut again.
        3. The choice of reading strategy forces the use of in-place execution - $(expression) -, which makes the
           code less readable.
        4. There is no error handling. If the Invoke-Webrequest command fails, the script will fail. 
#>

    Import-Csv C:\temp\installersArray.csv | ForEach-Object {
    "$($_.path)
     $($_.hash)
     $($_.name)
     $($_.url)"
        Write-Host "Downloading $($_.url)"
        #Invoke-WebRequest -Uri $($_.url) -OutFile $($_.path)}
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
<#  FV - COMMENT

    Coding practices. Although this section is better than previous ones, it still relies on an obscure methodology for gathering data.
    Code writes to StdOut but then pipes that to a simple text file. This seems less than desirable, given
    that we do not currently have a tested method for retrieving files from a component run.
    This is true for this section and for the next.
#>
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

<#  FV - COMMENT

    Coding practices. The section below also uses the relatively obscure and hard to read method of piping StdOut to a text file for logging
    purposes. While this will probably work as expected, it is a convoluted way of achieving somnething for which there are explicit
    cmdlets that can be used.
    Another thing to note is that pre-existing shortcuts are simply deleted instead of being archived.
#>

#%%%%%%%%%%%%%%%%%% LOG AND DELETE OLD Tableau SHORTCUTS %%%%%%%%%%%%%%%%%% 
if (Test-Path "C:\temp\foundShortcuts.csv") {Remove-Item "c:\temp\foundShortcuts.csv"}
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

<#  FV - COMMENT

    Coding practices: The code in the three sections that follow is unnecessarily complex; it is also devoid of error handling.
    The mnost likely error in this portion of the script would be a permissions error while trying to delete a file; the
    entire segment should be encapsulated in a try/catch block to help gracefully manage this type of condition.
#>

#Uninstall Old 2021 Preps
$oldPrepRemovals = Get-ChildItem -Recurse -Path "C:\programdata\Package Cache" -Include "Tableau-setup-p*2021*.exe"
$oldPrepRemovals.FullName 
if (Test-Path "C:\temp\foundOldPreps.csv") {Remove-Item "c:\temp\foundOldPreps.csv"}
$oldPrepRemovals.FullName | out-file "c:\temp\foundOldPreps.csv" -Append
start-process  $oldPrepRemovals.FullName -ArgumentList "/uninstall /quiet"

#Uninstall Old 2020 Preps
$oldPrepRemovals = Get-ChildItem -Recurse -Path "C:\programdata\Package Cache" -Include "Tableau-setup-p*2020*.exe"
$oldPrepRemovals.FullName 
$oldPrepRemovals.FullName | out-file "c:\temp\foundOldPreps.csv" -Append
start-process  $oldPrepRemovals.FullName -ArgumentList "/uninstall /quiet"

#Uninstall Old 2019 Preps
$oldPrepRemovals = Get-ChildItem -Recurse -Path "C:\programdata\Package Cache" -Include "Tableau-setup-p*2019*.exe"
$oldPrepRemovals.FullName 
$oldPrepRemovals.FullName | out-file "c:\temp\foundOldPreps.csv" -Append
start-process  $oldPrepRemovals.FullName -ArgumentList "/uninstall /quiet"


#Clean up downloaded files....keep logs
if (Test-Path "C:\temp\TableauPrep-2022-4-2.exe") {Remove-Item "C:\temp\TableauPrep-2022-4-2.exe"}
if (Test-Path "C:\temp\TableauDesktop-64bit-2022-4-1.exe") {Remove-Item "C:\temp\TableauDesktop-64bit-2022-4-1.exe"}

<#  FV - COMMENT

    The code below writes to a UDF directly instead of relying on the function that was declared for this purpose at the
    top of the script. This is bad for two reasons:
        1. It is a duplication of effort.
        2. It can lead to very hard-to-track errors.
#>

#Populate UDF with install log
$message = Get-Content -Path "C:\temp\errorlog.txt"
$verified = "Custom15"
New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $verified -PropertyType String -Value $Message
