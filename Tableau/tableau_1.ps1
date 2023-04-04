#No "force" and no 'errorAcrtion' -ignore!!!
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
###Get username via Frank's tool#####
###Step by step. No jumping ahead
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#Clear-Host

##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#validate logged in user....yes or no
#$liu = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
#$userID = $liu.split("\")[1]
#$user = New-Object System.Security.Principal.NTAccount($liu) 
#$userSID = $user.Translate([System.Security.Principal.SecurityIdentifier]) 

# Ensure there is a user logged in; abort execution if not
#FUNCTION UpdateUDF(){}
#{if ($userid -like "") {
#    $verified = "Custom15"
 #   New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $verified -PropertyType String -Value "Tableau: No user logged in"
 #   Write-Error -Message "Error: No user logged into system. Script execution terminating." -Category ObjectNotFound -ErrorAction Stop
#STOP HERE!!} 
#else {
  #  $verified = "Custom15"
  #  New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $verified -PropertyType String -Value "Running for user: $userid"
  #  Write-Host "Detected logged-in user: $liu"
#}
#}
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#Initialize hashes....
#$expected_desktop_hash = ""
#$desktop_hash.hash = ""
#$expected_prep_hash = ""
#$prep_hash.Hash = ""

#INSTALLER files
#$installerFiles = @(
#    "c:\temp\TableauPrep-2022-4-2.exe"
#    "c:\temp\TableauDesktop-64bit-2022-4-2.exe")

#%%%%%%%%%%%%%%%%%% DOWNLOAD Tableau INSTALLERS PREP AND DESKTOP %%%%%%%%%%%%%%%%%% 
#Create our temporary install folder at c:\temp\tableau
##           Verify folder and:
#                  
#          YES:  Download files 2 files via Dropbox to c:\temp\ with invoke-webrequest FOR EACH IN ARRAY
#                    YES:  FOR EACH in $installerFiles
#                          Use switches /ACCEPTEULA /ACTIVATIONSERVER /AUTOUPDATE /DESKTOPSHORT
#                    NO:  Stop
#                    function update_udf
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#POPULATE HASHES FOR DOWNLOADED FILES
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#FUNCTION     user installerFiles
#PREP HASH
#$expected_prep_hash = "D200F6260D6360D54A71F4EE386A56FF6585DABBFD814474B340DF0F23479B7E"
#    #takes several seconds
#    $prep_hash = Get-FileHash "C:\temp\TableauPrep-2022-4-2.exe"
#DESKTOP HASH
#$expected_desktop_hash = "C63EC3AB246FDC19D89067C62F4F0078BBB0E3B7DE939A882D2901E7E9554E93"
#    #takes several seconds
#    $desktop_hash = Get-FileHash "C:\temp\TableauDesktop-64bit-2022-4-2.exe"
#

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#POPULATE HASHES FOR INSTALLED APPS
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#FUNCTION
#    #Needs new hashes in here
#$expected_prep_hash = "<value>"
#    $prep_hash = Get-FileHash "C:\program files\Tableau\TableauPrep-2022-4-2.exe"
#$expected_desktop_hash = "<value>"
#    $desktop_hash = Get-FileHash "C:\program files\Tableau\TableauDesktop-64bit-2022-4-2.exe"
#

#cONFIRMATION OF VALUES  --   GETS REMOVED after testing
#Write-Host "VERIFYING RESULTS FOR TESTING"
#$expected_prep_hash
#$prep_hash.Hash
#$expected_desktop_hash
#$desktop_hash.Hash

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#VERIFY HASHES FOR INSTALLED APPS
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#FUNCTION FUNCTION FUNCTION  use some more generic vars to make more universal#
#xxxxx if ($expected_prep_hash -eq $prep_hash.hash) { Write-Host "YES" } xxxx
#FOREACH ($item in $installerFiles) {
#    #Verify hashes for each downloaded file
#    Write-Host "Testing hash for $folder"
#    if (Test-Path -Path $folder) {
#        Write-Host "Path $folder exists on disk."
#        try {
#            $allfiles = Get-ChildItem -Path $folder -ErrorAction Stop
#        } catch {
#            Write-Error -Message "Error reading contents of folder $Folder." -Category ReadError -ErrorAction Stop
#        }
#        try {
#            if ($allfiles.Count -gt 0) {
#                # Process only non-empty folders
#                foreach ($file in $allfiles) {
#                    # Remove files that are in the "Screen Savers", "Wallpapers", "Installs" folders.
#                    if ($file.DirectoryName.Contains("Screen Savers") -or $File.DirectoryName.Contains("Wallpapers") -or $File.DirectoryName.Contains("Installs")) {
#                        Write-Host "Removing file: $file"
#                        try {
#                            if (-not $TestMode) {
#                                Remove-Item -Path $file
#                            }
#                        } catch {
#                            Write-Error "There was an unexpected error removing file $file" -Category WriteError -ErrorAction Stop
#                        }
#                    }
#                    # REmove files that have the word "Template" in the file name
#                    elseif ($file.Name.Contains("Template")) {
#                        Remove-Item -Path $file
#                    }
#                }
#            }
#        } catch {
#            Write-Host "Folder $folder was empty"
#            function_update_udf
#        }
#    } else {
        # If the folder does not exist, just create it
#        try {
#            $junkVar = New-Item -Path $folder -ItemType Directory
#            Write-Host "Created folder $folder"
#        } catch {
#            Write-Error -Message "Error creating folder $folder. Script run terminating." -Category WriteError -ErrorAction Stop
#            function_update_udf        
#}
#    }
#}

#else {
#    #            function_update_udf
#

#
#FUNCTION (USE FOR 'DESKTOP' TOO?)
#%%%%%%%%%%%%%%%%%% CHECK IF PREP INSTALLED AND OLD VERSIONS %%%%%%%%%%%%%%%%%% 
#Perform search through Prep Folders to get previous versions
#get-childitem -recurse -filter "xx"
#get-command -recurse filename   Put into our $Prep_versions
#Record each version number (get-command filename.FileVersionInfo.FileVersion)
#$prep_versions = array of these results
#Is latest installed?  Compare $prep_versions to published latest (2022.4.x  get-command filename.FileVersionInfo.FileVersion =?
#          YES:        mark as such in $latest_prep_version.  We now know we do not need to install latest
#          NO:         We'll install
                
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


#FUNCTION Desktop install
#%%%%%%%%%%%%%%%%%% CHECK IF LATEST DESKTOP INSTALLED %%%%%%%%%%%%%%%%%% 
#We only have to install latest to ensure it's on and previous versions will be pulled off
#Record  version number (get-command filename.FileVersionInfo.FileVersion)
#Is latest installed?  Compare $desktop_versions to published latest (2022.4.2  get-command filename.FileVersionInfo.FileVersion =?
#          YES:  We now know we do not need to install latest
#          NO:   Execute install of latest version
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

#%%%%%%%%%%%%%%%%%% INSTALL PREP BASED ON $latest_prep_version %%%%%%%%%%%%%%%%%% 
#Create our temporary install folder at c:\temp\tableau
#                Matches hash?
#                    YES:  We can install.  Use switches /ACCEPTEULA /ACTIVATIONSERVER /AUTOUPDATE /DESKTOPSHORT
#                     NO:  stop.
#                          function_update_udf
#                         
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

#%%%%%%%%%%%%%%%%%%%% VERIFY PREP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#Record  version number (get-command filename.FileVersionInfo.FileVersion)
#Record each version number (get-command filename.FileVersionInfo.FileVersion)
#$prep_versions = array of these results
#Is latest installed?  Compare $desktop_versions to published latest (2022.4.2  get-command filename.FileVersionInfo.FileVersion =?
#          YES:  We now know we do not need to install latest
#          NO:   Execute install of latest version
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

#%%%%%%%%%%%%%%%%%%%%% UNISTALL OLD PREPS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
#   Via a FOREACH in our array of old versions, we'll uninstall skipping lastest
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

#%%%%%%%%%%%%%%%%%%%%%%GET RID OF OLD SHORTCUTS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
#    Based on our var of versions, we'll remove any old prep shorcuts based on 202*.x
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

#CLEANUP
