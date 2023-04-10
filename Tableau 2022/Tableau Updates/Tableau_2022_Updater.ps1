#Starting as pseudocode
#Update Tableau Apps
$ProgressPreference = "SilentlyContinue"

Clear-Host
copy-item "./*.csv" "c:\temp\installersArray.csv"
$VerbosePreference = "Continue"
#%%%%%%%%%%%%%%%%%%
#      Start       #
#      PURPOSE:  reads in a csv with headings of "path, hash, name, url".  With these
#      populated the script will install the requested software...in this case it's
#      for Chartis Tableau
#
#      Checks if latest Tableau versions are installed and, if not, installs.  Old versions removed.
#%%%%%%%%%%%%%%%%%%
#all working....get error checking in place

<#
•	To record in a UDF field during execution
o	user logged in y/n
o	versions and update already installed?
o	do installer files already exist
o	Invoke-web errors
o	Hash errors
o	Confirmation of upgrade
o	Verification of cleanup
•	Script will start with our default login verification/discovery piece
o Initialize logging file c: \temp before we do anything else
o	Determine who user is.  SID needed (required for profile folders)
o	If no user logged in terminate
o	Locate where user temp folder is via SID
o	Determine “Documents” Folder location via SID
•	Prepare user’s temp file space
o	Verify user temp folder exists
o	Create it if doesn’t exist
o	Create a ‘tableau’ temp sub-folder for installers, log, etc
•	Need csv imported to an array
o	Array with:  Path, installerHash, name, url, installedHash, installedPath, installedName
•	Support optional removal of old shortcuts
o	Remove broken shortcuts not pointing to any installed Tableau app
o	Remove shortcuts pointing to older versions instead of the updated version
	Tableau app’s Desktop shortcuts are only in Public\Desktop so user made ones will be safe
•	Optionally check for correct install
o	Verify hash of installed exe (which alone is not enough)
o	Verify some other (yet to be determined) files that are placed during install
o	Verify some other (yet to be determined) Registry entries created during install
•	Optionally update versions of Tableau apps
o	Download installers to user temp location
o	Verify hashes of the downloads
o	Desktop update/install with specific switches
o	Prep update/install with specific switches
o	Check that they installed correctly
•	Determine if older versions installed
o	ProgramData has the uninstallers .lnk that we can find to record\use
•	Optionally cleanup/copy/delete previous Tableau folders in “My Documents”
o	More info needed from Tableau support
•	Optionally uninstall the older versions
o	Execute tableau installed shortcuts which we already know from earlier
•	Clean-up temporary file spaces
o	Remove Tableau temp folder and recurse
o	Verify temp folder cleaned worked
o	Close log file
¬¬--
#>