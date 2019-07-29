###########
#NESTED 

#Get-VMProcessor -VMName $args[0] | fl *

If($args[1]) {
  $bool = $true
  $OnOff = 'On'
} Else {
  $bool = $false
  $OnOff = 'Off'
}

Set-VMProcessor -VMName $args[0] -ExposeVirtualizationExtensions $bool
#(Get-VMProcessor -VMName $args[0]).ExposeVirtualizationExtensions
#disable Dynamic Memory on Virtual Machine
Set-VMMemory $args[0] -DynamicMemoryEnabled $bool
#(Get-VMMemory -VMName $args[0]).DynamicMemoryEnabled
#Enable mac address spoofing
Get-VMNetworkAdapter -VMname $args[0] | Set-VMNetworkAdapter -MacAddressSpoofing $OnOff
#(Get-VMNetworkAdapter -VMName $args[0]).MacAddressSpoofing

Wait-VMPowershell -Name $args[0] -Credential

#Invoke-Command -VMName $args[0] -ScriptBlock { Get-Service }
