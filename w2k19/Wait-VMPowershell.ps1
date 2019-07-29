[CmdletBinding()]
param(
        $Name,
        [System.Management.Automation.PSCredential]
	$Credential = $(Get-Credential)
    )

# Turn on virtual machine if it is not running
If ((Get-VM -VMName $Name).State -eq "Off")
{
  Write-Host "Starting VM $($Name)"
  Start-VM -Name $Name -ErrorAction Stop | Out-Null
}

Wait-VM -Name $Name -For Heartbeat
#Start-Sleep -Seconds 20
$startTime = Get-Date
do 
{
  $timeElapsed = $(Get-Date) - $startTime
  if ($($timeElapsed).TotalMinutes -ge 10)
  {
      Write-Host "Could not connect to PS Direct after 10 minutes"
      throw
  } 
  Start-Sleep -sec 1
  $psReady = Invoke-Command -VMName $Name -Credential $Credential `
                            -ScriptBlock { $True } -ErrorAction SilentlyContinue
} 
until ($psReady)
