md "c:\temp"  -ErrorAction ignore
md "c:\users\$env:username\Pictures\Chartis Wallpapers"
md "c:\users\$env:username\Pictures\Chartis Screensavers"
md "c:\users\$env:username\Pictures\Chartis Screensavers\Chartis Values"
remove-item "c:\users\$env:username\Pictures\Chartis Screensavers\*.*"
remove-item "c:\users\$env:username\Pictures\Chartis Wallpapers\*.*"
remove-Item "c:\users\$env:username\AppData\Roaming\Microsoft\Templates\2023 Chartis*.*"

$filecheck = ""
Invoke-WebRequest -Method get -uri "https://www.dropbox.com/s/mtwe45nmboxxl8c/Screensavers.zip?dl=1" -outfile "C:\temp\screensavers.zip"

$testfile = "C:\temp\screensavers.zip"
$filecheck = "sczip1, "
if (gi -Path $testfile)
{

$filecheck = "sczip1, "
  
}
else
{

  $filecheck = "sczip0, "
  
}

$filecheck

Invoke-WebRequest -Method get -uri "https://www.dropbox.com/s/6udld74k6tdqrod/2023%20Chartis%20Word%20Template.zip?dl=1" -OutFile "c:\temp\2020 Chartis Word Template.zip"
$testfile = "c:\temp\2020 Chartis Word Template.zip"
if (gi -Path $testfile)
{
 $filecheck = $filecheck + "wlzip1, " 
}
else
{

$filecheck = $filecheck + "wlzip0, "
}

$filecheck

Invoke-WebRequest -Method get -uri "https://www.dropbox.com/s/fj11iy8anhpsgf8/Chartis%20Wallpapers_Dark-Chevron.jpg?dl=1"  -outfile "C:\users\$env:username\Pictures\Chartis Wallpapers\Chartis Wallpapers_Dark-Chevron.jpg"
$testfile = "C:\users\$env:username\Pictures\Chartis Wallpapers\Chartis Wallpapers_Dark-Chevron.jpg"
if (gi -Path $testfile)
{
 $filecheck = $filecheck + "dark.1, "
}
else
{

 $filecheck = $filecheck + "dark.0, "
}

$filecheck

Invoke-WebRequest -Method get -uri "https://www.dropbox.com/s/dymt8k1a0v3wmbm/Chartis%20Wallpapers_Light-Chevron.jpg?dl=1"  -outfile "C:\users\$env:username\Pictures\Chartis Wallpapers\Chartis Wallpapers_Light-Chevron.jpg"
$testfile = "C:\users\$env:username\Pictures\Chartis Wallpapers\Chartis Wallpapers_Light-Chevron.jpg"
if (gi -Path $testfile)
{
 $filecheck = $filecheck + "light.1, "
}
else
{
$filecheck = $filecheck + "light.0, "
}
$filecheck

#Expand the zips
Expand-Archive "c:\temp\2020 Chartis Word Template.zip" "C:\users\$env:username\AppData\Roaming\Microsoft\Templates" -Force
$testfile = "C:\users\$env:username\AppData\Roaming\Microsoft\Templates\2023 Chartis Excel Template.xltx"
if (gi -Path $testfile)
{
 $filecheck = $filecheck + "excel.1, "
}
else
{
 $filecheck = $filecheck + "excel.0, "
}

$filecheck

$testfile = $testfile = "C:\users\$env:username\AppData\Roaming\Microsoft\Templates\2023 Chartis PowerPoint Template_Standard.potx"
if (gi -Path $testfile)
{
 $filecheck = $filecheck + "pps.1, "
}
else
{
$filecheck = $filecheck + "pps.0, "
}
$filecheck

$testfile = "C:\users\$env:username\AppData\Roaming\Microsoft\Templates\2023 Chartis PowerPoint Template_Widescreen.potx"
if (gi -Path $testfile)
{
 $filecheck = $filecheck + "ppw.1, "
}
else
{ $filecheck = $filecheck + "ppw.0, "
}
$filecheck

$testfile = "C:\users\$env:username\AppData\Roaming\Microsoft\Templates\2023 Chartis Word Template.dotx"
if (gi -Path $testfile)
{
 $filecheck = $filecheck + "w.1, "
}
else
{$filecheck = $filecheck + "w.0, "
}
$filecheck


Expand-Archive "C:\temp\screensavers.zip" "C:\users\$env:username\Pictures\Chartis Screensavers\Chartis Values" -Force
$testfile = "C:\users\$env:username\pictures\chartis screensavers\chartis values\Chartis_Screensavers_2022-2023_V3-01.jpg"
if (gi -Path $testfile)
{
 $filecheck = $filecheck + "sc1.1, "
}
else
{$filecheck = $filecheck + "sc1.0, "
}
$filecheck

$testfile = "C:\users\$env:username\pictures\chartis screensavers\chartis values\Chartis_Screensavers_2022-2023_V3-02.jpg"
if (gi -Path $testfile)
{
 $filecheck = $filecheck + "sc2.1, "
}
else
{$filecheck = $filecheck + "sc2.0, "
}
$filecheck
$testfile = "C:\users\$env:username\pictures\chartis screensavers\chartis values\Chartis_Screensavers_2022-2023_V3-03.jpg"
if (gi -Path $testfile)
{
 $filecheck = $filecheck + "sc3.1, "
}
else
{$filecheck = $filecheck + "sc3.0, "
}
$filecheck
$testfile = "C:\users\$env:username\pictures\chartis screensavers\chartis values\Chartis_Screensavers_2022-2023_V3-04.jpg"
if (gi -Path $testfile)
{
 $filecheck = $filecheck + "sc4.1, "
}
else
{$filecheck = $filecheck + "sc4.0, "
}
$filecheck
$testfile = "C:\users\$env:username\pictures\chartis screensavers\chartis values\Chartis_Screensavers_2022-2023_V3-05.jpg"
if (gi -Path $testfile)
{
 $filecheck = $filecheck + "sc5.1"
}
else
{$filecheck = $filecheck + "sc5.0"
}
$filecheck

#Put output into UDF.
  $verified = "Custom"+'15' 

  New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $verified  -PropertyType String -value $filecheck

  $verified = "Custom"+'16' 
  $usernametest = $env:username
  New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $verified  -PropertyType String -value $usernametest



#Clean up temp and previous templates.  Try the 'next intelligence' but just leave otherwise
remove-Item "c:\temp\screensavers.zip"
remove-Item "c:\temp\2020 chartis word template.zip"
remove-Item "C:\users\$env:username\AppData\Roaming\Microsoft\Templates\2022*.*" -ErrorAction ignore
remove-Item "C:\users\$env:username\AppData\Roaming\Microsoft\Templates\2021*.*" -ErrorAction ignore
remove-Item "C:\users\$env:username\AppData\Roaming\Microsoft\Templates\2020*.*" -ErrorAction ignore
remove-Item -Recurse "c:\users\$env:username\Pictures\Chartis Wallpapers\Next Intelligence" -ErrorAction ignore #can stay if necessary
remove-Item -Recurse "c:\users\$env:username\Pictures\Next Intelligence"  -ErrorAction ignore  #can stay if necessary
remove-Item -Recurse "c:\users\$env:username\Pictures\Chartis Screensavers\Next Intelligence"  -ErrorAction ignore #can stay if necessary

$filecheck  
$verified = "Custom"+'15' 
New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $verified  -PropertyType String -value $filecheck
$verified = "Custom"+'16' 
$usernametest = $env:username
New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $verified  -PropertyType String -value $usernametest

