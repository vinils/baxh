[CmdletBinding()]
param(
        $Name,
        $Enable,
        [System.Management.Automation.PSCredential]
        $Credential = $(Get-Credential)
    )

#Get-VMProcessor -VMName $Name | fl *

If($Enable) {
  $bool = $true
  $OnOff = 'On'
  Stop-VM $Name -Force
} Else {
  $bool = $false
  $OnOff = 'Off'
}



Set-VMProcessor -VMName $Name -ExposeVirtualizationExtensions $bool
#(Get-VMProcessor -VMName $Name).ExposeVirtualizationExtensions
#disable Dynamic Memory on Virtual Machine
Set-VMMemory $Name -DynamicMemoryEnabled $bool
#(Get-VMMemory -VMName $Name).DynamicMemoryEnabled
#Enable mac address spoofing
Get-VMNetworkAdapter -VMname $Name | Set-VMNetworkAdapter -MacAddressSpoofing $OnOff
#(Get-VMNetworkAdapter -VMName $Name).MacAddressSpoofing

Restart-VM $Name -Force
Wait-VMPowershell -Name $Name -Credential $Credential

if($Enabled) {
  Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-WindowsFeature Hyper-V }
}
