function ps1 {
param ([string]$targetPath,$targetPath)

    gci -Path $path | foreach-object {
        if ($_.length/1kb -eq 0)
        {
                $_.FullName
                $logRecord = $logRecord + $target.fullname + "," + $target.length + "," + "$searchFile" + "," + "exists," + $searchFile.Length + "`n"

        }
elseif 

($_.psiscontainer) {
    ps1 -path $_.fullname
    $logRecord = $logRecord + $target.fullname + "," + $target.length + "," + "$searchFile" + "," + "exists," + $searchFile.Length + "`n"

    }
}
}

#[system.io.path]::getDirectoryName($path)

ps1 -path C:\zeros | export-csv C:\rmm-mgmt\tset.txt
