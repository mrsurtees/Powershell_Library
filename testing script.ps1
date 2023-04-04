###################   ONLY FOR TESTING    ###################
#
############

Clear-Host
$TestMode = $false
Write-Host "Running in testmode: $TestMode"

# #############validate logged in user....yes or no
$liu = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
$userID = $liu.split("\")[1]
$user = New-Object System.Security.Principal.NTAccount($liu) 
$userSID = $user.Translate([System.Security.Principal.SecurityIdentifier]) 

###############

# Ensure there is a user logged in; abort execution if not
if ($userid -like "") {
    $verified = "Custom15"
    New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $verified -PropertyType String -Value "Walls:  No user logged in"
    Write-Error -Message "Error: No user logged into system. Script execution terminating." -Category ObjectNotFound -ErrorAction Stop
} else {
    $verified = "Custom15"
    New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $verified -PropertyType String -Value "Running for user: $userid"
    Write-Host "Detected logged-in user: $liu"
}

# Establish target paths
# Now get all the other variables that depend on the logged-in user's name and path
# Full Registry path to the profile key for the logged in user
$RegProfilePath = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\' + $userSID
Write-Host "Registry Profile Path: $RegProfilePath"

# Full Registry path to the logged-in user's shell folders registry key.
$RegUserShellFolders = 'HKEY_USERS\' + $userSID + '\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders'
Write-Host "Registry Path to User's shell folders: $RegUserShellFolders"
#
# File system path to user's profile folder
$userProf = (Get-ItemProperty -Path Registry::$RegProfilePath -Name 'ProfileImagePath').'ProfileImagePath'   #gather and assign user profile path
Write-Host "File system path to user profile: $userProf"

# File system path to user's Pictures folder
$picfolders = (Get-ItemProperty -Path Registry::$RegUserShellFolders -Name 'My Pictures').'My Pictures'      #assign user My Pictures folder
Write-Host "File system path to user's Pictures folder: $picfolders"

# File system path to user's AppData/Roaming folder
$appdataRoaming = (Get-ItemProperty -Path Registry::$RegUserShellFolders -Name 'AppData').'AppData'          #assign user AppData folder
Write-Host "File system path to AppData \ Roaming folder: $appdataRoaming"

# File system path to user's personal Templates folders

#setting templates folder - word
try {
    $PersonalTemplatesFolder_word = (Get-ItemProperty -Path registry::"HKEY_USERS\$usersid\SOFTWARE\Microsoft\Office\16.0\Word\Options" -Name "PersonalTemplates" -ErrorAction Stop).'PersonalTemplates'
} catch {
    $message = New-ItemProperty -Path "Registry::HKEY_USERS\$usersid\Software\Microsoft\Office\16.0\Word\Options" -Name PersonalTemplates -Value "C:\users\$userid\appdata\roaming\microsoft\windows\templates" -PropertyType string
    $PersonalTemplatesfolder_word = (Get-ItemProperty -Path "Registry::HKEY_USERS\$usersid\SOFTWARE\Microsoft\Office\16.0\Word\Options" -Name "PersonalTemplates" -ErrorAction SilentlyContinue).'PersonalTemplates'
    Write-Host "Created Registry Entry: $($message.PersonalTemplates)"
}

#setting templates folder - excel
try {
    $PersonalTemplatesFolder_excel = (Get-ItemProperty -Path registry::"HKEY_USERS\$usersid\SOFTWARE\Microsoft\Office\16.0\Excel\Options" -Name "PersonalTemplates" -ErrorAction Stop).'PersonalTemplates'
} catch {
    $message = New-ItemProperty -Path "Registry::HKEY_USERS\$usersid\Software\Microsoft\Office\16.0\Excel\Options" -Name PersonalTemplates -Value "C:\users\$userid\appdata\roaming\microsoft\windows\templates" -PropertyType string -Force
    $PersonalTemplatesfolder_excel = (Get-ItemProperty -Path "Registry::HKEY_USERS\$usersid\SOFTWARE\Microsoft\Office\16.0\Excel\Options" -Name "PersonalTemplates" -ErrorAction SilentlyContinue).'PersonalTemplates'
    Write-Host "Created Registry Entry: $($message.PersonalTemplates)"
}

#setting templates folder - powerpoint
try {
    $PersonalTemplatesFolder_powerpoint = (Get-ItemProperty -Path registry::"HKEY_USERS\$usersid\SOFTWARE\Microsoft\Office\16.0\Powerpoint\Options" -Name "PersonalTemplates" -ErrorAction Stop).'PersonalTemplates'
} catch {
    $message = New-ItemProperty -Path "Registry::HKEY_USERS\$usersid\Software\Microsoft\Office\16.0\Powerpoint\Options" -Name PersonalTemplates -Value "C:\users\$userid\appdata\roaming\microsoft\windows\templates" -PropertyType string
    $PersonalTemplatesFolder_powerpoint = (Get-ItemProperty -Path "Registry::HKEY_USERS\$usersid\SOFTWARE\Microsoft\Office\16.0\Powerpoint\Options" -Name "PersonalTemplates" -ErrorAction SilentlyContinue).'PersonalTemplates'
    Write-Host "Created Registry Entry: $($message.PersonalTemplates)"
}


#ensure paths are ready

# File system path to target data folders
$chartissavers = "$picfolders\Chartis Screensavers"
Write-Host "Screen Savers folder: $chartissavers"

$chartiswalls = "$picfolders\Chartis Wallpapers"
Write-Host "Wallpapers folder: $chartiswalls"

$chartisvalues = "$chartissavers\Chartis Values"
Write-Host "Values image files folder: $chartisvalues"

$installs = "$userProf\Installs"
Write-Host "Our temporary folder path for archive extraction: $installs"

# Prepare an array of all folders to be checked
$AllFolders = @(
    $userProf,
    $picfolders,
    $appdataRoaming,
    $PersonalTemplatesFolder_word,
    $PersonalTemplatesFolder_excel,
    $PersonalTemplatesFolder_powerpoint
    $chartissavers,
    $chartiswalls,
    $chartisvalues,
    $installs
)

Write-Host "Folder List"
$AllFolders

foreach ($folder in $AllFolders) {
    #If the folder exists, we'll check the files inside of it and will delete the files that should not be there
    Write-Host "Testing for folder $folder"
    if (Test-Path -Path $folder) {
        Write-Host "Path $folder exists on disk."
        try {
            $allfiles = Get-ChildItem -Path $folder -ErrorAction Stop
        } catch {
            Write-Error -Message "Error reading contents of folder $Folder." -Category ReadError -ErrorAction Stop
        }
        try {
            if ($allfiles.Count -gt 0) {
                # Process only non-empty folders
                Write-Host "Folder: $folder"
                foreach ($file in $allfiles) {
                    # Remove files that are in the "Screen Savers", "Wallpapers", "Installs" folders.
                    if ($file.DirectoryName.Contains("Screen Savers") -or $File.DirectoryName.Contains("Wallpapers") -or $File.DirectoryName.Contains("Installs")) {
                        try {
                            $ftr = $file.DirectoryName + "\" + $file.Name
                            Write-Host "Removing file: $ftr"
                            if (-not $TestMode) {
                                Remove-Item -Path $ftr
                            }
                        } catch {
                            Write-Error "There was an unexpected error removing file $file" -Category WriteError -ErrorAction Stop
                        }
                    }
                    # REmove files that have the word "Template" in the file name
                    elseif ($file.Name.Contains("Template")) {
                        try {
                            $ftr = $file.DirectoryName + "\" + $file.Name
                            Write-Host "Removing file: $ftr"
                            if (-not $TestMode) {
                                Remove-Item -Path $ftr
                            }
                        } catch {
                            Write-Error "There was an unexpected error removing file $file" -Category WriteError -ErrorAction Stop
                        }
                    }
                }
            }
        } catch {
            Write-Host "Folder $folder was empty"
        }
    } else {
        # If the folder does not exist, just create it
        try {
            $junkVar = New-Item -Path $folder -ItemType Directory
            Write-Host "Created folder $folder"
        } catch {
            Write-Error -Message "Error creating folder $folder. Script run terminating." -Category WriteError -ErrorAction Stop
        }
    }
}


#grab the archives
Invoke-WebRequest -Method get -Uri "https://www.dropbox.com/s/mtwe45nmboxxl8c/Screensavers.zip?dl=1" -OutFile "$installs\2023 Chartis Wallpapers.zip"
Invoke-WebRequest -Method get -Uri "https://www.dropbox.com/s/6udld74k6tdqrod/2023%20Chartis%20Word%20Template.zip?dl=1" -OutFile "$Installs\2023 Chartis Office Templates.zip"
Invoke-WebRequest -Method get -Uri "https://www.dropbox.com/s/fj11iy8anhpsgf8/Chartis%20Wallpapers_Dark-Chevron.jpg?dl=1" -OutFile "$installs\Chartis Wallpapers_Dark-Chevron.jpg"
Invoke-WebRequest -Method get -Uri "https://www.dropbox.com/s/dymt8k1a0v3wmbm/Chartis%20Wallpapers_Light-Chevron.jpg?dl=1" -OutFile "$installs\Chartis Wallpapers_Light-Chevron.jpg"

#
# Test that the four archives were successfully downloaded

$allFiles = @(
    "$Installs\2023 Chartis Wallpapers.zip"
    "$Installs\2023 Chartis Office Templates.zip",
    "$Installs\Chartis Wallpapers_Dark-Chevron.jpg",
    "$Installs\Chartis Wallpapers_Light-Chevron.jpg"
)

foreach ($file in $allfiles) {
    if (Get-Item -Path $file) {
        # If the file is a .zip archive, then extract its contents to $Installs
        if ($file.Split(".")[1] -eq "zip") {
            Write-Host "Extracting contents of $file"
            Expand-Archive -Path $file -DestinationPath $Installs
        } else {
            # If not, just acknowledge its existence.
            Write-Host "File $file exists in $Installs"
        }
    } else {
        # This should never happen, but if there is an error reading the file, we have to abort
        Write-Error -Message "The file $file could not be located in $Installs. Aborting..." -Category ReadError -ErrorAction Stop
    }
}

# Now we verify that each of the 11 target files exists and, if it does, we move it to its intended destination
# If the name contains template, to the relevant template folder
# If the name contains screensavers, to $chartisvalues, and
# If the name contains wallpapers, to $chartiswalls

$allFiles = @(
    "$Installs\2023 Chartis Excel Template.xltx",
    "$Installs\2023 Chartis Word Template.dotx",
    "$installs\2023 Chartis PowerPoint Template_Standard.potx",
    "$installs\2023 Chartis PowerPoint Template_Widescreen.potx",
    "$installs\Chartis_Screensavers_2022-2023_V3-01.jpg",
    "$installs\Chartis_Screensavers_2022-2023_V3-02.jpg",
    "$installs\Chartis_Screensavers_2022-2023_V3-03.jpg",
    "$installs\Chartis_Screensavers_2022-2023_V3-04.jpg",
    "$installs\Chartis_Screensavers_2022-2023_V3-05.jpg",
    "$Installs\Chartis Wallpapers_Dark-Chevron.jpg",
    "$Installs\Chartis Wallpapers_Light-Chevron.jpg"
)


foreach ($file in $allfiles) {
    if (Get-Item -Path $file) {
        if ($file.Contains("Template")) {
            # Word files to $PersonalTemplatesFolder_word
            if ($File.Contains("Word")) {
                Write-Host "Copying $file to $PersonalTemplatesFolder_word"
                Copy-Item -Path $file -Destination $PersonalTemplatesFolder_word
            }
            # Excel files to $PersonalTemplatesFolder_excel
            elseif ($file.Contains("Excel")) {
                Write-Host "Copying $file to $PersonalTemplatesFolder_excel"
                Copy-Item -Path $file -Destination $PersonalTemplatesFolder_excel
            }
            # Powerpoint files to $PersonalTemplatesFolder_powerpoint
            elseif ($file.Contains("PowerPoint")) {
                Write-Host "Copying $file to $PersonalTemplatesFolder_powerpoint"
                Copy-Item -Path $file -Destination $PersonalTemplatesFolder_powerpoint
            }
            # We should never hit the 'else' clause, so error out
            else {
                Write-Host "Unidentified Template file $file found."
                Write-Error -Message "Unexpected Condition Error" -Category InvalidData -ErrorAction Stop
            }
        }
        # If it is not a template, it must be a screen saver... 
        elseif ($file.Contains("Screensavers")) {
            Write-Host "Copying file $file to $chartisvalues"
            Copy-Item -Path $file -Destination $chartisvalues
        }
        # ... or a wallpaper
        elseif ($file.Contains("Wallpapers")) {
            Write-Host "Copying file $file to $chartiswalls"
            Copy-Item -Path $file -Destination $chartiswalls
        } else {
            # Any other file is an anomaly and we must error out
            Write-Host "Unidentified Template file $file found."
            Write-Error "Unexpected Condition Error" -Category InvalidData -ErrorAction Stop
        }
    }
}

Remove-Item -Path $installs -Recurse
