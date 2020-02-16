#https://trycatch.me/publishing-custom-powershell-modules-to-myget/

# $global:VMName="#VMATTemp"
# $global:VMCredential=$(Get-Credential MyVMUser)
# $global:WindowsSource="\\WTBRSENXKQX2L.gmea.gad.schneider-electric.com\Files\Scripts\windows.psm1"
# $global:NetWorkCredential=$(Get-Credential WindowsPSM1NetWorkCredential)


#Wait-WebAccess -Name "#VMAtTemp" -URL "www.uol.com" -NetWorkCredential $(Get-Credential)
Function Wait-WebAccess
{
	Param(
		[string]$URL
	)
	
	if(!$global:Session) {
		SetDefaultScriptsSession
	}

	Invoke-Command -Session $global:Session -ScriptBlock {
		Wait-WebAccess -URL $using:URL
	}
}

Function ChangeUser
{
	Param(
		[System.Management.Automation.PSCredential]$Credential=$Global:DefaultCredential
	)
	
	if(!$global:Session) {
		SetDefaultScriptsSession
	}

	Invoke-Command -Session $global:Session -ScriptBlock {
		ChangeUser -Credential $using:Credential
	}
}

# Function New-VMTemplate
# {
	# Param(
		# [string]$OSIsoFilePath,
		# [string]$NewVHDFolderPath
	# )

	# if (-not ($OSISOFilePath | Test-Path)) {
		# $OSISOFilePath = Read-Host -Prompt 'Please specify your OS ISO'
	# }

	# if($NewVHDFolderPath -eq "") {
		# $NewVHDFolderPath=(Get-VMHost).VirtualHardDiskPath
		# $NewVHDFolderPath=$NewVHDFolderPath.Substring(0,$NewVHDFolderPath.Length-1)
	# }

	# New-VM `
		# -Name $global:VMName`
		# -OSIsoFilePath $OSISOFilePath `
		# -NewVHDFolderPath $NewVHDFolderPath
		
	# Write-Host "Waiting you to install OS and set a user..."
	# Pause
	
	# if (!$Credential) {
		# $Credential = Get-Credential
	# }

	# Setup-VM -Name $global:VMName -CertFilePath "D:\Files\certexport.pfx"
	
	
	# if($script:DefaultCredential) {
		# $Credential = $script:DefaultCredential
	# }
	
	# Setup-Machine -Name $global:VMName -Credential = $Credential
	
			# # [string]$global:VMName,
		# # [System.Management.Automation.PSCredential]$Credential=$Global:DefaultCredential,
		# # [switch]$NoVMIntegrationService,
		# # [switch]$NoUACLower,
		# # [switch]$NoControlPainelSmallIcons,
		# # [switch]$NoShowingHiddenFiles,
		# # [switch]$NoShowingFileExtensions,
	
	# Restart-VM $global:VMName -Force
	# Wait-VM -Name $global:VMName -Credential $Credential

	# Write-Host $(Invoke-Command -VMName $global:VMName -Credential $Credential -ScriptBlock { ipconfig | findstr /i "ipv4" })
# }

#Update-VM
Function Update-VMW
{
	Param(
		[switch]$Install
	)
	
	if(!$Credential) {	
		SetDefaultScriptsSession
	}

	if ($Install) {
		Write-Host "Installing Nuget"
		Invoke-Command -Session $global:Session -ScriptBlock { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force }
		Invoke-Command -Session $global:Session -ScriptBlock { Install-PackageProvider -Name NuGet -Force }
		Write-Host "Installing update tools"
		Invoke-Command -Session $global:Session -ScriptBlock { Install-Module PSWindowsUpdate -Force }
		Invoke-Command -Session $global:Session -ScriptBlock { Install-Module -Name PendingReboot -Force }
	}

	Wait-VM -Name $global:VMName -Credential $Credential

	do {
		$updatesNumber = Invoke-Command -Session $global:Session -ScriptBlock { return (Get-WindowsUpdate).Count }
		$isRebootPending = Invoke-Command -Session $global:Session -ScriptBlock { return (Test-PendingReboot).IsRebootPending }

		Write-Host "Updating windows"
		Invoke-Command -Session $global:Session -ScriptBlock { Install-WindowsUpdate -AcceptAll -IgnoreReboot }

		if($isRebootPending) {
			Write-Host "Restarting VM"
			Restart-VM $global:VMName -Force
			Wait-VM -Name $global:VMName -Credential $Credential
		}
	} while($isRebootPending -or $updatesNumber -gt 0)
}

#Wait-VM
Function Wait-VM
{
	# Turn on virtual machine if it is not running
	If ((Get-VM -Name $global:VMName).State -eq "Off") {
		Write-Host "Starting VM $($global:VMName)"
		Start-VM -Name $global:VMName -ErrorAction Stop | Out-Null
	}

	hyper-v\Wait-VM -Name $global:VMName -For Heartbeat
	#Start-Sleep -Seconds 20
	$startTime = Get-Date
	do {
		$timeElapsed = $(Get-Date) - $startTime
		if ($($timeElapsed).TotalMinutes -ge 10) {
			Write-Host "Could not connect to PS Direct after 10 minutes"
			throw
		} 
		
		if(!$Credential) {
			SetDefaultScriptsSession
		}

		Start-Sleep -sec 1
		$psReady = Invoke-Command -Session $global:Session `
			-ScriptBlock { $True } -ErrorAction SilentlyContinue
	} 
	until ($psReady)
}

#Move-VMVHD -DestinationStoragePath "C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks"
Function Move-VMVHD
{
	Param(
		[string]$DestinationPath
	)
	
	if ($DestinationPath -eq "") {
		$DestinationPath = Read-Host -Prompt 'Destination path'
	}

	Move-VMStorage $global:VMName -DestinationStoragePath $DestinationPath
}

# Function InstallScripts
# {
	# [string]$Destination="c:\"
	
	# "Import-Module $Destination\Scripts\windows.psm1 -force -global" > C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1
# }

#SetDefaultScriptsSession -Name "#VMATTemp" -NetWorkCredential $(Get-Credential) -WindowsSource "\\WTBRSENXKQX2L.gmea.gad.schneider-electric.com\Files\Scripts\windows.psm1"
Function SetDefaultScriptsSession
{
	if ($global:VMName) {
		$VMName = $global:VMName
	} else {
		$VMName = Read-Host -Prompt 'VM Name'
		$global:VMName = $VMName
	}

	if(!$global:Session) {	
	
		if($global:VMCredential) {	
			$VMCredential = $global:VMCredential
		} else {
			$VMCredential = $(Get-Credential VMUser)
		}

		Get-PSSession | where { $_.ComputerName -eq $VMName } | Remove-PSSession
		$global:Session = New-PSSession -VMName $VMName -Credential $VMCredential
	}
	
	if($global:WindowsSource) {
		$WindowsSource = $global:WindowsSource
	} else {
		$WindowsSource = Read-Host -Prompt 'windows.psm1 source'
	}
	
	Invoke-Command -Session $global:Session -ScriptBlock {

		if(($using:windowssource).substring(0,4) -eq "http") {
			Set-ExecutionPolicy Bypass -Scope Process -Force
			[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
			iex (iwr $global:WindowsSource -Headers @{"Cache-Control"="no-cache"} -UseBasicParsing | Select-Object -Expand Content)
		}
		
		if(($using:windowssource).substring(0,2) -eq "\\") {
			if($global:WindowsSource) {
				$netCred=$using:NetWorkCredential
			}

			if($netCred) {
				$usr=$netCred.UserName
				$pwd=$netCred.GetNetworkCredential().Password
				$path=($using:WindowsSource).Substring(0,($using:WindowsSource).LastIndexOf('\'))
				net use $path $pwd /USER:$usr
			}

			Set-ExecutionPolicy Bypass -Scope Process -Force
			[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
			Import-Module $using:WindowsSource -Force -Global
		}
	}
}

#Download -Name "#VMATTemp" -Source "\\WTBRSENXKQX2L.gmea.gad.schneider-electric.com\Files\Scripts" -Destination "C:\" -NetCredential $(Get-Credential)
Function Download
{
	Param(
		[string]$Source,
		[string]$Destination,
		[System.Management.Automation.PSCredential]$VMCredential=$Global:DefaultCredential,
		[System.Management.Automation.PSCredential]$NetCredential,
		[switch]$Force
	)
	
	if(!$VMCredential) {	
		SetDefaultScriptsSession
	}
	
	Invoke-Command -Session $global:Session -ScriptBlock {
		$netCred=$using:NetCredential

		if (!(Test-Path $using:Destination)) {
			mkdir $using:Destination
		}
		
		if(($using:Source).Substring(0,4) -eq "http") {
			Invoke-WebRequest -Uri $using:Source -OutFile $using:Destination -Credential $netCred
		}
		
		if(($using:Source).Substring(0,2) -eq "\\") {
			if($netCred) {
				$usr=$netCred.UserName
				$pwd=$netCred.GetNetworkCredential().Password
				net use $using:Source $pwd /USER:$usr
			}
			
			# Copy-Item $using:Source -destination $using:Destination -Recurse -Force:($using:Force)
			Start-BitsTransfer -Source $using:Source -Destination $using:Destination -Credential $netCred
		}
	}
}

