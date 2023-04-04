# Delete any files that might have been added from previous run of the script
del C:\temp\*.txt -ErrorAction Ignore
$poop = "/domain"

$currentuser = (get-wmiobject -class win32_computersystem).username
$separator = "\"
$parts = $currentuser.split($separator) 
$parts[0] | add-content 'c:\temp\domain.txt'
$parts[1] | add-content 'c:\temp\username.txt'

$username = get-content c:\temp\username.txt ; $text = net user $username $poop | findstr /B /C:"Last logon"; $text | Add-Content c:\temp\logon.txt

$stream = [IO.File]::OpenWrite('c:\temp\logon.txt')
$stream.SetLength($stream.Length - 2)
$stream.Close()
$stream.Dispose()

$result = Get-Content C:\temp\logon.txt ; $result = $result.trim("Last logon") | Add-Content c:\temp\result.txt
$stream = [IO.File]::OpenWrite('c:\temp\result.txt')
$stream.SetLength($stream.Length - 2)
$stream.Close()
$stream.Dispose()
