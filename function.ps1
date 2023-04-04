

function Process-Folder
{
    param($sourcePath)

#Get JUST the filenames
#
$filenames = ""
$sourcePath = "C:\zeros"
$logRecord = ""
$fileNames = Get-ChildItem -recurse -Path  "c:\zeros" # | % { ($_.basename)}
$folderlist = ''

#if($fileNames -ne $null)
#    {

        foreach($file in $fileNames)
        {
            $searchFile = $filenames.fullname
            if(Test-Path $filenames.fullname)
                { $logRecord = $logRecord + $file.name + ","  + "`n" # + "," + $target.length + "," + "$searchFile" + "," + "exists," + $searchFile.Length  + "`n" 
               
                 }
                 }
#    }
# }
}

#$fileList = Get-ChildItem "c:\zeros"
#    }
#
    Process-Folder 
    #($targetPath, $targetPath)

#
#    $path = "C:\zeros\*.*"
#$basename = gi $path | select basename
#$b = $basename[0] 
#$b.BaseName
