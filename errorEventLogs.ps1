<#
.Synopsis - The function collects the System and Application Error logs for the last one month. If the error has occured more than 10 times, it writes on the console the logs
.Description - The function gets the system and application Error logs that have happened in the last one month, It then finds which errors occured more than 10 times. For the source of that event
it then collects the newest 10 logs and writes to the console.
.example : Get-ErrorEventLogs
#>
 function Get-ErrorEventLogs {
    <# Calculates the date that was a month before from today #>
    $monthago = (Get-date).AddDays(-30)
    <# Machine name on which the function is running #>
    $machine = Get-KaseyaMachineID
    <# Create an array of only 2 objects #>
    $events = "System","Application"
    <# $e below is each element of the array #>
    foreach ($e in $events) {
        <# gets the error logs of $e be it System or Application after a month and of type Error #>
        $errorlogs = Get-EventLog -LogName $e -After $monthago -EntryType Error | Where-Object {$_.Source -notlike 'DCOM'}
        <# All the logs of type $e are collected and grouped together to get the name and count of each #>
        $counterrors = $errorlogs | Group-Object -Property Source -NoElement | Select-Object Count,Name
            <# again foreach is used to iterate through the above collected information $c is each row with the count and the name of the event log #>
            foreach ($c in $counterrors) {
                <# if the count is more than 10, $e is either system or application and $c is the source of the event #>
                if ($c.count -gt 10) {
                $source = $c.name
                $count = $c.count
                $logs += "Error event with $source in $e Event logs occured $count times in the last 1 month. Below is one such log (the newest)"
                $logs += Get-EventLog -LogName $e -EntryType Error -Source $source -Newest 1 | fl | Out-String
                 }
               }
             }
              if ($logs) {
                    <# if errors are present it writes the logs to the console#>
                    Write-Host $logs
                    }
              else {
                    write-host "No Errors (system or application) have occured more than 10 times in the last month"
              }
        
  }