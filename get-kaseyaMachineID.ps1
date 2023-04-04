<#
.Synopsis
   Finds Kaseya Machine ID of or pc name
.DESCRIPTION
   Checks the registry for the Kaseya Machine ID...if not found it returns the Win pc name
.PARAMETER
    None availble
.EXAMPLE
  Get-KaseyaMachineID
#>
function Get-KaseyaMachineID
{
    Param
    ()
    
    Process
    {
        try
        {
            if($(Get-Process -Name AgentMon -ErrorAction SilentlyContinue).Name)
                {$(Get-ItemProperty -Path “HKLM:\Software\WOW6432Node\Kaseya\Agent\INTTSL74824010499872” -Name MachineID -ErrorAction Stop -ErrorVariable CurrentError).MachineID}
            Else{$env:computername}
        }
        Catch
        {$env:computername}   
    }
}
