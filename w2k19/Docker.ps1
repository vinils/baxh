Write-Host "Installing Docker"
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Module -Name DockerMsftProvider -Repository PSGallery -Force }
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Package -Name docker -ProviderName DockerMsftProvider -Force -Verbose }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Module DockerMsftProvider -Force }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Package Docker -ProviderName DockerMsftProvider -Force }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Start-Service docker }
