#Set-ItemProperty REGISTRY::HKLM\SOFTWARE\Classes\SOFTWARE\think-cell -Name licensekey -Value NG3XR-3BXMW-S2ZNG-LFM4X-95XF5
$regcheck = Get-ItemProperty REGISTRY::HKLM\SOFTWARE\Classes\SOFTWARE\think-cell -name licensekey # | Out-File C:\temp\name.txt
if ($regcheck -like '*NG3*' )
{
  $verified = "Custom"+'9' 
  New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $verified  -PropertyType String -value $regcheck
}

#New-ItemProperty -Path HKLM:\SOFTWARE\CentraStage -Name $verified -PropertyType String -value "V"
