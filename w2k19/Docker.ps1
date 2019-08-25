Write-Host "Installing Docker"
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Module DockerMsftProvider -Force }
##Bug Cannot verify the file SHA256 - problem to download file
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Start-BitsTransfer -Source https://dockermsft.blob.core.windows.net/dockercontainer/docker-19-03-1.zip -Destination C:\Users\ADMINI~1\AppData\Local\Temp\2\DockerMsftProvider\Docker-19-03-1.zip }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Package -Name docker -ProviderName DockerMsftProvider }
#Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Install-Package Docker -ProviderName DockerMsftProvider -Force }
Invoke-Command -VMName $Name -Credential $Credential -ScriptBlock { Start-Service docker }
