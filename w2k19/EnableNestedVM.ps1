[CmdletBinding()]
param(
        $Name,
        $Enable = $false,
        [System.Management.Automation.PSCredential]
        $Credential = $(Get-Credential)
    )

#Get-VMProcessor -VMName $Name | fl *

If($Enable) {
  $bool = $true
  $OnOff = 'On'
} Else {
  $bool = $false
  $OnOff = 'Off'
}

Stop-VM $Name -Force
while ((get-vm -name $Name).state -ne 'Off') { start-sleep -s 5 }

Set-VMProcessor -VMName $Name -ExposeVirtualizationExtensions $bool
#(Get-VMProcessor -VMName $Name).ExposeVirtualizationExtensions
#disable Dynamic Memory on Virtual Machine
Set-VMMemory $Name -DynamicMemoryEnabled $bool
#(Get-VMMemory -VMName $Name).DynamicMemoryEnabled
#Enable mac address spoofing
Get-VMNetworkAdapter -VMname $Name | Set-VMNetworkAdapter -MacAddressSpoofing $OnOff
#(Get-VMNetworkAdapter -VMName $Name).MacAddressSpoofing

Wait-VMPowershell -Name $Name -Credential $Credential

If($Enable) {
  Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-WindowsFeature Hyper-V }
  Restart-VM $Name -Force
}
