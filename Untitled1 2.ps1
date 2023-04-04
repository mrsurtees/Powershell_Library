#Path to your wallpaper folder.. 
$myPictureFolder = Join-Path $env:USERPROFILE  -ChildPath "Pictures\Chartis Screensavers\" 
 
# doing DIR on a Picture folder and choosing the random 1 
$getRandomWallpaper = Get-ChildItem -Recurse $myPictureFolder | where  {$_.Extension -eq ".jpg"}  | Get-Random -Count 1  
 
 
# Setting wallpaper to the regisrty. 
Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value  $getRandomWallpaper.FullName   
 
# updating the user settings 
rundll32.exe user32.dll, UpdatePerUserSystemParameters  
rundll32.exe user32.dll, UpdatePerUserSystemParameters  
rundll32.exe user32.dll, UpdatePerUserSystemParameters  
 
 