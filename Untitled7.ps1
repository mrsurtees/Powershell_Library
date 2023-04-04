Process-Folder($targetPath, $targetPath)

function Process-Folder
{
    param()
    #([var]$ProcessName,[var]$fullpath)}

#Get JUSt the filenames
#
$sourcePath = "C:\zeros"
$fileNames = Get-ChildItem $sourcePath\*.* | % { ($_.basename)}
$filenames


if($fileList -ne $null){
    Write-Host "I'M NOT NULL"

        foreach($file in $fileList){
        {if(Test-Path $file)
    {Write-Host "HELLO"}}


#$fileList = Get-ChildItem "c:\zeros"
#    
#    
#    }
#
    Process-Folder($targetPath, $targetPath)

#
#    $path = "C:\zeros\*.*"
#$basename = gi $path | select basename
#$b = $basename[0] 
#$b.BaseName
#
#



