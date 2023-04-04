import-csv C:\temp\installersArray.csv
$tableauObjects = @(
    [pscustomobject]@{}
    
    [pscustomobject]@{}
)


import-csv C:\temp\installersArray.csv

$tableauObjects = @(
    [path]@{
        FirstName = 'Adam'
        LastName = 'Bertram'
        Department = 'Executive Office'
    })
    [hash]@{
        FirstName = 'Don'
        LastName = 'Jones'
        Department = 'Janitorial Services'
    }
        [name]@{
        FirstName = 'Don'
        LastName = 'Jones'
        Department = 'Janitorial Services'
    }
        [url]@{
        FirstName = 'Don'
        LastName = 'Jones'
        Department = 'Janitorial Services'
    }
)