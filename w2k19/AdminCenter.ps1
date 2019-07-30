Set-Item wsman:localhost\client\trustedhosts 192.168.15.243 -Concatenate -Force
$cred = Get-Credential
Enter-PSSession 192.168.15.251 -Credential $cred
#Enter-PSSession -HostName UserA@LinuxServer02:22 -KeyFilePath c:\<path>\userAKey_rsa

$dlPath = 'C:\Users\Administrator\Downloads\WAC.msi'
Invoke-WebRequest 'http://aka.ms/WACDownload' -OutFile $dlPath

$port = 443
msiexec /i $dlPath /qn /L*v log.txt SME_PORT=$port SSL_CERTIFICATE_OPTION=generate
#msiexec /i $dlPath /qn /L*v log.txt SME_PORT=$port SME_THUMBPRINT=$CertThumprint SSL_CERTIFICATE_OPTION=installed
#check
#Get-CimInstance -ClassName Win32_softwarefeature | where productname -like "Windows Admin*" |fl

#get-service -DisplayName "*Admin*"
(get-service ServerManagementGateway).start()
set-service ServerManagementGateway -startuptype "Automatic"

##cehck
#Test-NetConnection -Port $port -ComputerName 127.0.0.1 -InformationLevel Detailed
#https://192.168.15.251/
