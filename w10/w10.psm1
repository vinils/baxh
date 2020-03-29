#env:PSMOdulePath
#load module automatically https://stackoverflow.com/questions/23909746/powershell-v4-not-importing-module-automatically
#install module Find-Module -Name windows | Install-Module -Force -AllowClobber
#Publish-Module -Path C:\Users\MyUser\source\repos\baxh\windows\ -NuGetApiKey $nugetapikey
#import raw file https://stackoverflow.com/questions/48751933/get-content-fails-from-a-file-in-a-shared-folder
#iex (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/vinils/baxh/master/windows/windows.psm1')
#iex (iwr https://raw.githubusercontent.com/vinils/baxh/master/windows/windows.psm1 -UseBasicParsing | Select-Object -Expand Content)

<#
@FncParam = @{
Name = $Name
NewVHDFolderPath = "C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks"
OSIsoFilePath = "D:\Files\en_windows_10_enterprise_version_1703_updated_june_2017_x64_dvd_10720664.iso"
}
New-VM @FncParam
#>
#New-VM -Name $Name -NewVHDFolderPath "C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks" -OSIsoFilePath "D:\Files\en_windows_10_enterprise_version_1703_updated_june_2017_x64_dvd_10720664.iso"
Function New-VM
{
	Param(
		[string]$Name,
		[string]$OSISOFilePath,
		[string]$NewVHDFolderPath,
		[int]$Generation=2,
		[string]$MemoryStartUpBytes=2GB,
		[string]$SwitchName='Default Switch',
		[string]$NewVHDSizeBytes=30GB,
		[int]$ProcessorCount=2,
		[bool]$DynamicMemory=$True,
		[string]$MemoryMinimumBytes=512MB,
		[string]$MemoryMaximumBytes=6Gb
	)

	if ($Name -eq "") {
		$Name = Read-Host -Prompt 'VM Name'
	}

	if (-not ($OSISOFilePath | Test-Path)) {
		$OSISOFilePath = Read-Host -Prompt 'Please specify your OS ISO'
	}

	if($NewVHDFolderPath -eq "") {
		$NewVHDFolderPath=(Get-VMHost).VirtualHardDiskPath
		$NewVHDFolderPath=$NewVHDFolderPath.Substring(0,$NewVHDFolderPath.Length-1)
	}

	$NewVMParam = @{
		Name = $Name
		Generation = $Generation
		MemoryStartUpBytes = $MemoryStartUpBytes
		SwitchName = $SwitchName
		NewVHDPath = "$NewVHDFolderPath\$Name.vhdx"
		NewVHDSizeBytes = $NewVHDSizeBytes
		# ErrorAction = 'Stop'
		Verbose = $True
	}

	$VM = hyper-v\New-VM @NewVMParam

	$SetVMParam = @{
		ProcessorCount = $ProcessorCount
		DynamicMemory = $DynamicMemory
		MemoryMinimumBytes = $MemoryMinimumBytes
		MemoryMaximumBytes = $MemoryMaximumBytes
		# ErrorAction = 'Stop'
		# PassThru = $True
		Verbose = $True
	}

	$VM = $VM | Set-VM @SetVMParam

	Add-VMScsiController -VMName $Name
	Add-VMDvdDrive -VMName $Name -ControllerNumber 1 -ControllerLocation 0 -Path $OSISOFilePath
	$DVDDrive = Get-VMDvdDrive -VMName $Name
	Set-VMFirmware -VMName $Name -FirstBootDevice $DVDDrive
}

# New-VMW10 `
	# -Name VMWDev1 `
	# -VHDTemplate 'D:\Hyper-V\Virtual Hard Disks\Virtual Hard Disks\W10Temp.vhdx' `
	# -VHDFolderPath 'C:\Hyper-V\Virtual Hard Disks\' `
	# -SwitchName "ExternalSwitch"
Function New-VMW10
{
	Param(
		[System.Management.Automation.PSCredential]$Credential=$Global:VMCredential,
		[string]$Name=$Global:VMName,
		[string]$VHDTemplate,
		[string]$OSISOFilePath,
		[string]$VHDFolderPath,
		[string]$NewVHDFolderPath,
		[int]$Generation=2,
		[string]$MemoryStartUpBytes=2GB,
		[string]$SwitchName,
		[int]$ProcessorCount=2,
		[bool]$DynamicMemory=$True,
		[string]$MemoryMinimumBytes=512MB,
		[string]$MemoryMaximumBytes=6Gb
	)
	
	if(!$Credential) {
		$Credential = Get-Credential
		$global:VMCredential=$Credential
	}

	if ($Name -eq "") {
		$Name = Read-Host -Prompt 'VM Name'
		$Global:VMName = $Name
	}
	
	if ($VHDTemplate -eq "") {
		$VHDTemplate = Read-Host -Prompt 'VHD Windows 10 Template'
	}
	
	if ($VHDFolderPath -eq "") {
		$VHDFolderPath = Read-Host -Prompt 'Virtual hard disk folder path'
	}
	
	if ($SwitchName -eq "") {
		$SwitchName = Read-Host -Prompt 'VM Switch name (eg.: Default Switch)'
	}
	
	Write-Host "Copying VM Template file..."
	$NewVHDFilePath="$VHDFolderPath\$Name.vhdx"
	Copy-Item $VHDTemplate $NewVHDFilePath

	Write-Host "Creating VM"
	$NewVMParam = @{
		Name = $Name
		Generation = $Generation
		MemoryStartUpBytes = $MemoryStartUpBytes
		SwitchName = $SwitchName
		VHDPath = $NewVHDFilePath
		# ErrorAction = 'Stop'
		Verbose = $True
	}

	$VM = hyper-v\New-VM @NewVMParam

	Write-Host "Setting VM configurations"
	$SetVMParam = @{
		ProcessorCount = $ProcessorCount
		DynamicMemory = $DynamicMemory
		MemoryMinimumBytes = $MemoryMinimumBytes
		MemoryMaximumBytes = $MemoryMaximumBytes
		# ErrorAction = 'Stop'
		# PassThru = $True
		Verbose = $True
	}

	$VM = $VM | Set-VM @SetVMParam
	
	Write-Host "Startting VM"
	Start-VM -Name $Name
	hyper-v\Wait-VM -Name $Name -For Heartbeat
	
}

Function Wait-VM
{
	Param(
		[string]$Name=$Global:VMName,
		[System.Management.Automation.PSCredential]$Credential=$Global:VMCredential
	)
	
	# Turn on virtual machine if it is not running
	If ((Get-VM -Name $Name).State -eq "Off") {
		Write-Host "Starting VM $($global:VMName)"
		Start-VM -Name $Name -ErrorAction Stop | Out-Null
	}

	hyper-v\Wait-VM -Name $Name -For Heartbeat
	#Start-Sleep -Seconds 20
	$startTime = Get-Date
	do {
		$timeElapsed = $(Get-Date) - $startTime
		if ($($timeElapsed).TotalMinutes -ge 10) {
			Write-Host "Could not connect to PS Direct after 10 minutes"
			throw
		} 
		
		Start-Sleep -sec 1
		$psReady = Invoke-Command -VMName $Name -Credential $Credential `
			-ScriptBlock { $True } -ErrorAction SilentlyContinue
	} 
	until ($psReady)
}

# #$global:VMName="#W10Temp"
# #$global:VMCredential=$(Get-Credential MyVMUser)
# #$global:WindowsSource='https://raw.githubusercontent.com/vinils/baxh/master/windows/windows.psm1'
# #$global:HyperVSource='https://raw.githubusercontent.com/vinils/baxh/master/hyperv/hyperv.psm1'
# Function SwitchToHyperV
# {
	# if(!$global:HyperVSource) {
		# $global:HyperVSource = Read-Host -Prompt 'hyperv.psm1 source'
	# }
	
	# if (!$global:VMName) {
		# $global:VMName = Read-Host -Prompt 'VM Name'
	# }

	# if(!$global:VMCredential) {	
		# $global:VMCredential = $(Get-Credential VMUser)
	# }

	# if(!$global:WindowsSource) {
		# $global:WindowsSource = Read-Host -Prompt 'windows.psm1 source'
	# }
	
	# Set-ExecutionPolicy Bypass -Scope Process -Force
	# [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
	# iex (iwr $global:HyperVSource -Headers @{"Cache-Control"="no-cache"} -UseBasicParsing | Select-Object -Expand Content)
	
	# Wait-VM
	
	# SetDefaultScriptsSession
# }

Function ChangeUser
{
	Param(
		[System.Management.Automation.PSCredential]$Credential
	)

	Write-Host "password unset"
	Set-LocalUser -name $Credential.Username -Password $Credential.Password
}

#SetupMachine -InstallProxyScript -InstallProxyEnviromentVariable -EnableRDP -EnableRDPBlankPassword -UACLower -ControlPainelSmallIcons -ShowHiddenFiles -ShowFileExtensions -InstallChocolatey
Function SetupMachine
{
	Param(
		[switch]$EnableRDP,
		[switch]$EnableRDPBlankPassword,
		[switch]$UACLower,
		[switch]$ControlPainelSmallIcons,
		[switch]$ShowHiddenFiles,
		[switch]$ShowFileExtensions,
		[switch]$InstallChocolatey,
		[switch]$InstallNotepadPlusPlus,
		[switch]$Install7Zip,
		[switch]$InstallGit,
		[switch]$InstallDockerCli,
		[switch]$InstallVisualstudio2017testagent,
		[switch]$InstallDotNetFramework471DeveloperPack,
		[switch]$InstallPython2_7_15,
		[switch]$InstallCurl,
		[switch]$InstallCMake,
		[switch]$InstallNugetPackageProvider,
		[switch]$InstallNugetPSWindowsUpdate,
		[switch]$InstallIISASPNET45,
		[switch]$InstallDotNetFramework472,
		[switch]$InstallChrome,
		[switch]$InstallSQLManagementStudio,
		[switch]$InstallWindowsSubsystemLinux,
		[switch]$InstallVirtualMachinePlatform,
		[switch]$InstallHyperV,
		[switch]$InstallVisualStudio2019Community,
		[switch]$DisableWindowsDefender,
		[switch]$UnpinEdge,
		[switch]$UnpinMSStore,
		[switch]$UnpinMail,
		[switch]$DisableFirewall
	)

	if($EnableRDP) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Enabling Remote Desktop"
		Write-Host "-----------------------------------------------------"
		Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name "fDenyTSConnections" -Value 0
		Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' -Name "UserAuthentication" -Value 0
	}

	if($EnableRDPBlankPassword) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> enabling rdp with blank password"
		Write-Host "-----------------------------------------------------"
		Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name LimitBlankPasswordUse -Value 0
		netsh advfirewall firewall set rule group="remote desktop" new enable=Yes
	}
	
	if ($UACLower) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Lowering UAC"
		Write-Host "-----------------------------------------------------"
		Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0
	}

	if ($DisableFirewall) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Disabling firewall"
		Write-Host "-----------------------------------------------------"
		NetSh Advfirewall set allprofiles state off
	}

	if ($UnpinEdge) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Unpinning Edge"
		Write-Host "-----------------------------------------------------"
		DoUnpin 'Microsoft Edge'
	}

	if ($UnpinMSStore) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Unpinning MS Store"
		Write-Host "-----------------------------------------------------"
		DoUnpin 'Microsoft Store'
	}

	if ($UnpinMail) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Unpinning Mail"
		Write-Host "-----------------------------------------------------"
		DoUnpin 'Mail'
	}
	
	#DoPin 'Google Chrome'; DoPin 'Visual Studio 2019'
	
	if ($ControlPainelSmallIcons) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> control painel small icons"
		Write-Host "-----------------------------------------------------"
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel"
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "StartupPage" -Type DWord -Value 1
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "AllItemsIconView" -Type DWord -Value 1
	}
	
	if ($DisableWindowsDefender) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Disabling windows defender..."
		Write-Host "-----------------------------------------------------"
		Stop-Service WinDefend
		Reg add 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender' /v DisableAntiSpyware /t REG_DWORD /d 1 /f
		Reg add 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f
		Reg add 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' /v DisableOnAccessProtection /t REG_DWORD /d 1 /f
		Reg add 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' /v DisableScanOnRealtimeEnable /t REG_DWORD /d 1 /f
		Reg add 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' /v DisableRoutinelyTakingAction /t REG_DWORD /d 1 /f
	}
	
	if ($ShowHiddenFiles) {
		Write-Host "-----------------------------------------------------"
		Write-Output "---> Showing hidden files..."
		Write-Host "-----------------------------------------------------"
		Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1
	}

	if ($ShowFileExtensions) {
		Write-Host "-----------------------------------------------------"
		Write-Output "---> Showing known file extensions..."
		Write-Host "-----------------------------------------------------"
		Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0
	}

	if ($InstallNugetPackageProvider) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing Nuget"
		Write-Host "-----------------------------------------------------"
		Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
		Install-PackageProvider -Name NuGet -Force
	}

	if ($InstallNugetPSWindowsUpdate) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing update tools"
		Write-Host "-----------------------------------------------------"
		Install-Module PSWindowsUpdate -Force
		Install-Module -Name PendingReboot -Force
	}
	
	if ($InstallChocolatey `
	-or $InstallNotepadPlusPlus `
	-or $Install7Zip `
	-or $InstallGit `
	-or $InstallDockerCli `
	-or $InstallVisualstudio2017testagent `
	-or $InstallDotNetFramework471DeveloperPack `
	-or $InstallPython2_7_15 `
	-or $InstallCMake `
	-or $InstallChrome `
	-or $InstallSQLManagementStudio `
	-or $InstallCurl) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing chocolatey..."
		Write-Host "-----------------------------------------------------"
		Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	}

	if ($Install7Zip) {
		#Wait-WebAccess -Name $Name -Credential $Credential -URL https://www.nuget.org/api/v2/package/7-Zip.CommandLine/18.1.0 
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing 7zip..."
		Write-Host "-----------------------------------------------------"
		#choco install -y 7zip
		Install-7zip
	}

	if ($InstallNotepadPlusPlus) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing notepad++..."
		Write-Host "-----------------------------------------------------"
		choco install -y --limit-output notepadplusplus
	}

	if ($InstallGit) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing Git..."
		Write-Host "-----------------------------------------------------"
		choco install -y git
	}

	if ($InstallDockerCli) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing docker cli..."
		Write-Host "-----------------------------------------------------"
		choco install -y --limit-output docker-cli
	}
	
	if ($InstallVisualstudio2017testagent) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing Visual Studio 2017 Test Agent..."
		Write-Host "-----------------------------------------------------"
		choco install -y --limit-output visualstudio2017testagent
	}
	
	if ($InstallDotNetFramework471DeveloperPack) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing .Net Framework 4.7.1 Developer Pack..."
		Write-Host "-----------------------------------------------------"
		choco install -y --limit-output netfx-4.7.1-devpack
	}

	if ($InstallPython2_7_15) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing Python 2.7.15..."
		Write-Host "-----------------------------------------------------"
		choco install -y --limit-output python2 --version=2.7.15
	}

	if ($InstallCurl) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing Curl..."
		Write-Host "-----------------------------------------------------"
		choco install curl -y --limit-output
	}

	if ($InstallCMake) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing CMake..."
		Write-Host "-----------------------------------------------------"
		choco install -y --limit-output cmake --installargs '"ADD_CMAKE_TO_PATH=System"'
	}
	
	if ($InstallChrome) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing Chrome..."
		Write-Host "-----------------------------------------------------"
		choco install -y --limit-output googlechrome --ignore-checksums
	}
	
	if ($InstallSQLManagementStudio) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing SQL Management Studio..."
		Write-Host "-----------------------------------------------------"
		choco install -y --limit-output sql-server-management-studio
	}
	
	if ($InstallSQLManagementStudio) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing SQL Management Studio..."
		Write-Host "-----------------------------------------------------"
		choco install -y --limit-output sql-server-management-studio
	}
	
	if ($InstallVisualStudio2019Community) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing IISASPNet45..."
		Write-Host "-----------------------------------------------------"
		#choco install -y visualstudio2019enterprise --package-parameters='--add Microsoft.VisualStudio.Component.Git'
		choco install -y --limit-output visualstudio2019community --package-parameters='--add Microsoft.VisualStudio.Component.CoreEditor --add Microsoft.VisualStudio.Workload.CoreEditor --add Microsoft.NetCore.Component.SDK --add Microsoft.VisualStudio.Component.NuGet --add Microsoft.Net.Component.4.6.1.TargetingPack --add Microsoft.VisualStudio.Component.Roslyn.Compiler --add Microsoft.VisualStudio.Component.Roslyn.LanguageServices --add Microsoft.VisualStudio.Component.FSharp --add Microsoft.NetCore.Component.DevelopmentTools --add Microsoft.VisualStudio.Component.FSharp.WebTemplates --add Microsoft.VisualStudio.ComponentGroup.WebToolsExtensions --add Microsoft.VisualStudio.Component.DockerTools --add Microsoft.NetCore.Component.Web --add Microsoft.Net.Component.4.8.SDK --add Microsoft.Net.Component.4.7.2.TargetingPack --add Microsoft.Net.ComponentGroup.DevelopmentPrerequisites --add Microsoft.VisualStudio.Component.TypeScript.3.7 --add Microsoft.VisualStudio.Component.JavaScript.TypeScript --add Microsoft.VisualStudio.Component.JavaScript.Diagnostics --add Microsoft.Component.MSBuild --add Microsoft.VisualStudio.Component.TextTemplating --add Component.Microsoft.VisualStudio.RazorExtension --add Microsoft.VisualStudio.Component.IISExpress --add Microsoft.VisualStudio.Component.SQL.ADAL --add Microsoft.VisualStudio.Component.SQL.LocalDB.Runtime --add Microsoft.VisualStudio.Component.Common.Azure.Tools --add Microsoft.VisualStudio.Component.SQL.CLR --add Microsoft.VisualStudio.Component.MSODBC.SQL --add Microsoft.VisualStudio.Component.MSSQL.CMDLnUtils --add Microsoft.VisualStudio.Component.ManagedDesktop.Core --add Microsoft.Net.Component.4.5.2.TargetingPack --add Microsoft.Net.Component.4.5.TargetingPack --add Microsoft.VisualStudio.Component.SQL.SSDT --add Microsoft.VisualStudio.Component.SQL.DataSources --add Component.Microsoft.Web.LibraryManager --add Microsoft.VisualStudio.ComponentGroup.Web --add Microsoft.VisualStudio.Component.Web --add Microsoft.VisualStudio.Component.IntelliCode --add Microsoft.Net.Component.4.TargetingPack --add Microsoft.Net.Component.4.5.1.TargetingPack --add Microsoft.Net.Component.4.6.TargetingPack --add Microsoft.Net.ComponentGroup.TargetingPacks.Common --add Microsoft.Net.Core.Component.SDK.2.1 --add Component.Microsoft.VisualStudio.Web.AzureFunctions --add Microsoft.VisualStudio.ComponentGroup.AzureFunctions --add Microsoft.VisualStudio.Component.Azure.Compute.Emulator --add Microsoft.VisualStudio.Component.Azure.Storage.Emulator --add Microsoft.VisualStudio.Component.Azure.ClientLibs --add Microsoft.VisualStudio.Component.Azure.AuthoringTools --add Microsoft.VisualStudio.Component.CloudExplorer --add Microsoft.VisualStudio.ComponentGroup.Web.CloudTools --add Microsoft.VisualStudio.Component.DiagnosticTools --add Microsoft.VisualStudio.Component.EntityFramework --add Microsoft.VisualStudio.Component.AspNet45 --add Microsoft.VisualStudio.Component.AppInsights.Tools --add Microsoft.VisualStudio.Component.WebDeploy --add Component.Microsoft.VisualStudio.LiveShare --add Microsoft.VisualStudio.Workload.NetWeb'
	}

	if ($InstallWindowsSubsystemLinux) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing Windows Subsystem Linux..."
		Write-Host "-----------------------------------------------------"
		DISM /online /enable-feature /NoRestart /FeatureName:Microsoft-Windows-Subsystem-Linux -NoRestart
	}

	if ($InstallVirtualMachinePlatform) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing VirtualMachinePlatform..."
		Write-Host "-----------------------------------------------------"
		DISM /online /enable-feature /NoRestart /FeatureName:VirtualMachinePlatform -NoRestart
	}

	if ($InstallIISASPNET45) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing IIS ASPNET45..."
		Write-Host "-----------------------------------------------------"
		dism /online /enable-feature /all /featurename:IIS-ASPNET45 -NoRestart
	}

	if ($InstallHyperV) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing VirtualMachinePlatform..."
		Write-Host "-----------------------------------------------------"
		Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
	}

	if ($InstallDotNetFramework472) {
		Write-Host "-----------------------------------------------------"
		Write-Host "---> Installing .NET472..."
		Write-Host "-----------------------------------------------------"
		choco install dotnet4.7.2 -y
	}
}

Function ActiveWindows
{
	Param(
		[switch]$Key
	)

	$computer = gc env:computername
	$service = get-wmiObject -query "select * from SoftwareLicensingService" -computername $computer
	$service.InstallProductKey($Key)
	$service.RefreshLicenseStatus()
}


Function UpdateWindows
{
	Param(
		[switch]$Install
	)
	
	if($Install) {
		SetupMachine -InstallNugetPackageProvider -InstallNugetPSWindowsUpdate
	}
	
	Install-WindowsUpdate -AcceptAll -IgnoreReboot
}

Function Install-7zip
{
	Param(
		[string]$7ZipUrl="https://www.7-zip.org/a/7z1900-x64.msi"
	)
	
	$7Zip = $true;
	$WebClient = New-Object -TypeName System.Net.WebClient;
	$7ZipInstaller = "$env:TEMP\7z920-x64.msi";
 
	try {
	 
		$7ZipPath = Resolve-Path -Path ((Get-Item -Path HKLM:\SOFTWARE\7-Zip -ErrorAction SilentlyContinue).GetValue("Path") + '\7z.exe');
		if (!$7ZipPath) {
			$7Zip = $false;
		}
	}
	catch {
		$7Zip = $false;
	}
	 
	if (!$7Zip) {
		$WebClient.DownloadFile($7ZipUrl,$7ZipInstaller);
		Start-Process -Wait -FilePath $7ZipInstaller;
		Remove-Item -Path $7ZipInstaller -Force -ErrorAction SilentlyContinue;
	}
	else
	{
	   #Write-Warning &amp;quot;7 Zip already installed&amp;quot; 
	}
}

Function Wait-WebAccess
{
	Param(
		[string]$URL
	)
	
	if(!($URL.Substring(0,4) -eq "http")) {
		$URL = "http:\\" + $URL
	}
	
	do{
		Start-Sleep -sec 2

		Write-Host "Veriffing $URL access"
		# First we create the request.
		$HTTP_Request = [System.Net.WebRequest]::Create($URL)

		# We then get a response from the site.
		$HTTP_Response = $HTTP_Request.GetResponse()

		# We then get the HTTP code as an integer.
		$HTTP_Status = [int]$HTTP_Response.StatusCode
		
		$hasConnection = $HTTP_Status -eq 200

		# Finally, we clean up the http request by closing it.
		$HTTP_Response.Close()
		
	}while(!$hasConnection)
}

Function Install-VS2008
{
	Param(
		[String]$Name,
		[System.Management.Automation.PSCredential]$Credential=$Global:DefaultCredential,
		[string]$ISOFilePath,
		[string]$ISOUpdateFilePath
	)

	if ($ISOFilePath -eq "") {
		$ISOFilePath = Read-Host -Prompt 'Visual Studio 2008 setup file path'
	}
	
	if ($ISOUpdateFilePath -eq "") {
		$ISOUpdateFilePath = Read-Host -Prompt 'Visual Studio 2008 update iso file path'
	}

	$drive = mount-diskimage $ISOFilePath -passthru
	$driveletter = ($drive | get-volume).driveletter + ":"
	start-process -filepath "$driveletter\Setup\setup.exe" -argumentlist '/q' -wait
	Dismount-DiskImage $ISOFilePath

	$drive = Mount-DiskImage $ISOUpdateFilePath -PassThru
	$driveLetter = ($drive | Get-Volume).DriveLetter + ":"
	Start-Process -FilePath "$driveLetter\vs90sp1\SPInstaller.exe" -ArgumentList '/passive' -Wait
	Dismount-DiskImage $ISOUpdateFilePath
}

Function Install-VS2012
{
	Param(
		[string]$ISOFilePath,
		[string]$ISOUpdateFilePath
	)

	if ($ISOFilePath -eq "") {
		$ISOFilePath = Read-Host -Prompt 'Visual Studio 2012 setup file path'
	}
	
	if ($ISOUpdateFilePath -eq "") {
		$ISOUpdateFilePath = Read-Host -Prompt 'Visual Studio 2012 update iso file path'
	}
	
	Write-Host "---> Installing VS2012"
	$drive = mount-diskimage $ISOFilePath -passthru
	$driveletter = ($drive | get-volume).driveletter + ":"
	start-process -filepath "$ISOFilePath\vs_premium.exe" -argumentlist '/passive' -wait
	Dismount-DiskImage $ISOFilePath

	$drive = Mount-DiskImage $ISOUpdateFilePath -PassThru
	$driveLetter = ($drive | Get-Volume).DriveLetter + ":"
	Start-Process -FilePath "$ISOUpdateFilePath\VS2012.5.exe" -ArgumentList '/Passive' -Wait
	Dismount-DiskImage $ISOUpdateFilePath
}

Function Install-VS2019
{
	Param(
		[string]$SetupFilePath,
		[string]$ConfigFilePath
	)

	if ($SetupFilePath -eq "") {
		$SetupFilePath = Read-Host -Prompt 'Visual Studio 2019 setup file path'
	}
	
	if ($ConfigFilePath -eq "") {
		$ConfigFilePath = Read-Host -Prompt 'Visual Studio 2019 vssconfig file path'
	}
	
	Start-Process -FilePath '$SetupFilePath' -ArgumentList '--config $ConfigFilePath --passive' -Wait
}

Function Download
{
	Param(
		[string]$Source,
		[string]$Destination,
		[System.Management.Automation.PSCredential]$Credential,
		[switch]$Force
	)
	
	if (!(Test-Path $using:Destination)) {
		mkdir $using:Destination
	}
	
	if(($using:Source).Substring(0,4) -eq "http") {
		Invoke-WebRequest -Uri $using:Source -OutFile $using:Destination -Credential $Credential
	}
	
	if(($using:Source).Substring(0,2) -eq "\\") {
		if($Credential) {
			$usr=$Credential.UserName
			$pwd=$Credential.GetNetworkCredential().Password
			net use $using:Source $pwd /USER:$usr
		}
		
		# Copy-Item $using:Source -destination $using:Destination -Recurse -Force:($using:Force)
		Start-BitsTransfer -Source "$using:Source\windows.psm1" -Destination $using:Destination -Credential $Credential
	}
}

function DoUnpin([string]$appname){
    $ErrorActionPreference= 'silentlycontinue'
    ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object {$_.Name -eq $appname}).Verbs() | Where-Object {$_.Name.replace('&','') -match 'Unpin from taskbar'} | ForEach-Object {$_.DoIt();}
    $ErrorActionPreference= 'continue'
}

function DoPin([string]$appname){
    if((Get-Process explorer).count -eq 1){
        Write-Host "Not running as explorer.exe! cannot pin to taskbar!"
        return
    }
    $ErrorActionPreference= 'silentlycontinue'
    ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object {$_.Name -eq $appname}).Verbs() | Where-Object {$_.Name.replace('&','') -match 'Pin to Taskbar'} |  ForEach-Object {$_.DoIt();}
    $ErrorActionPreference= 'continue'
}

Function Extend-WinOSDiskSize {
	foreach($disk in Get-Disk)
	{
		# Check if the disk in context is a Boot and System disk
		if((Get-Disk -Number $disk.number).IsBoot -And (Get-Disk -Number $disk.number).IsSystem)
		{
			# Get the drive letter assigned to the disk partition where OS is installed
			$driveLetter = (Get-Partition -DiskNumber $disk.Number | where {$_.DriveLetter}).DriveLetter
			Write-verbose "Current OS Drive: $driveLetter :\"

			# Get current size of the OS parition on the Disk
			$currentOSDiskSize = (Get-Partition -DriveLetter $driveLetter).Size        
			Write-verbose "Current OS Partition Size: $currentOSDiskSize"

			# Get Partition Number of the OS partition on the Disk
			$partitionNum = (Get-Partition -DriveLetter $driveLetter).PartitionNumber
			Write-verbose "Current OS Partition Number: $partitionNum"

			# Get the available unallocated disk space size
			$unallocatedDiskSize = (Get-Disk -Number $disk.number).LargestFreeExtent
			Write-verbose "Total Unallocated Space Available: $unallocatedDiskSize"

			# Get the max allowed size for the OS Partition on the disk
			$allowedSize = (Get-PartitionSupportedSize -DiskNumber $disk.Number -PartitionNumber $partitionNum).SizeMax
			Write-verbose "Total Partition Size allowed: $allowedSize"

			if ($unallocatedDiskSize -gt 0 -And $unallocatedDiskSize -le $allowedSize)
			{
				$totalDiskSize = $allowedSize
				
				# Resize the OS Partition to Include the entire Unallocated disk space
				$resizeOp = Resize-Partition -DriveLetter C -Size $totalDiskSize
				Write-verbose "OS Drive Resize Completed $resizeOp"
			}
			else {
				Write-Verbose "There is no Unallocated space to extend OS Drive Partition size"
			}
		}   
	}
}
