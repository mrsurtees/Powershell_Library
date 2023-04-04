$file = [System.IO.File]::Create("C:\temp\1gig.txt") 
$file.SetLength([double]1024mb) #Change file size here
$file.Close()

