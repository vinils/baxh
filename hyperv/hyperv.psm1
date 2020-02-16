#https://trycatch.me/publishing-custom-powershell-modules-to-myget/

# $global:VMName="#VMATTemp"
# $global:VMCredential=$(Get-Credential MyVMUser)
# $global:WindowsSource="\\WTBRSENXKQX2L.gmea.gad.schneider-electric.com\Files\Scripts\windows.psm1"
# $global:NetWorkCredential=$(Get-Credential WindowsPSM1NetWorkCredential)


#Wait-WebAccess -Name "#VMAtTemp" -URL "www.uol.com" -NetWorkCredential $(Get-Credential)
Function Wait-WebAccess
{
	Param(
		[System.Management.Automation.Runspaces.PSSession]$Session=$Global:Session,
		[string]$URL
	)
	
	if(!$Session) {
		SetDefaultScriptsSession
	}

	Invoke-Command -Session $global:Session -ScriptBlock {
		Wait-WebAccess -URL $using:URL
	}
}

Function ChangeUser
{
	Param(
		[System.Management.Automation.Runspaces.PSSession]$Session=$Global:Session,
		[System.Management.Automation.PSCredential]$Credential
	)
	
	if(!$Credential) {
		$Credential=$(Get-Credential NewUser)
	}

	if(!$Session) {
		SetDefaultScriptsSession
	}
	
	$Name=$Session.ComputerName

	Invoke-Command -Session $global:Session -ScriptBlock {
		ChangeUser -Credential $using:Credential
	}
	
	SetDefaultScriptsSession -VMName $Name -OldCredential $Session
}

Function SetupMachine
{
	Param(
		[System.Management.Automation.Runspaces.PSSession]$Session=$Global:Session,
		[switch]$EnableVMIntegrationService,
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
		[switch]$InstallIIS,
		[switch]$InstallDotNetFrameWork35,
		[switch]$InstallDotNetFramework472,
		[switch]$DisableAutomaticCheckpoints
	)
	
	if(!$Session) {
		SetDefaultScriptsSession
	}
	
	$Name=$Session.ComputerName

	if($EnableVMIntegrationService) {
		Write-Host "enable VM Integration Service"
		Get-VM -Name $Name | Get-VMIntegrationService | ? {-not($_.Enabled)} | Enable-VMIntegrationService -Verbose
	}
	
	if($DisableAutomaticCheckpoints) {
		Write-Host "disabling automatic checkpoints"
		Set-VM -Name $Name -AutomaticCheckpointsEnabled $false
	}

	Invoke-Command -Session $global:Session -ScriptBlock {
		Write-Host "enable execution of PowerShell scripts"
		set-executionpolicy remotesigned
		
		if($InstallDotNetFrameWork35) {
			Write-Host "Installing Net Framework 3.5"
			dism /online /enable-feature /featurename:NetFX3 /all /Source:d:\sources\sxs /LimitAccess
		}

		SetupMachine @using:psboundparameters
	}
}

Function ActiveWindows
{
	Param(
		[System.Management.Automation.Runspaces.PSSession]$Session=$Global:Session,
		[switch]$Key
	)

	if(!$Session) {
		SetDefaultScriptsSession
	}
	
	Invoke-Command -Session $global:Session -ScriptBlock {
		ActiveWindows @using:Key
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
	
	# Restart-VM $global:VMName -Force
	# Wait-VM -Name $global:VMName -Credential $Credential

	# Write-Host $(Invoke-Command -VMName $global:VMName -Credential $Credential -ScriptBlock { ipconfig | findstr /i "ipv4" })
# }

#Update-VM
Function Update-VMW
{
	Param(
		[System.Management.Automation.Runspaces.PSSession]$Session=$Global:Session,
		[switch]$Install
	)
	
	if(!$Session) {
		SetDefaultScriptsSession
	}
	
	$Name=$Session.ComputerName

	if ($Install) {
		Invoke-Command -Session $global:Session -ScriptBlock {
			SetupMachine -InstallNugetPackageProvider -InstallNugetPSWindowsUpdate
		}
	}

	Wait-VM -Session $global:Session

	do {
		$updatesNumber = Invoke-Command -Session $global:Session -ScriptBlock { return (Get-WindowsUpdate).Count }
		$isRebootPending = Invoke-Command -Session $global:Session -ScriptBlock { return (Test-PendingReboot).IsRebootPending }

		Write-Host "Updating windows"
		Invoke-Command -Session $global:Session -ScriptBlock { Install-WindowsUpdate -AcceptAll -IgnoreReboot }

		if($isRebootPending) {
			Write-Host "Restarting VM"
			Restart-VM $Name -Force
			Wait-VM -Session $global:Session
		}
	} while($isRebootPending -or $updatesNumber -gt 0)
}

#Wait-VM
Function Wait-VM
{
	Param(
		[System.Management.Automation.Runspaces.PSSession]$Session=$Global:Session
	)
	
	if(!$Session) {
		SetDefaultScriptsSession
	}
	
	$Name=$Session.ComputerName

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
		[string]$VMName,
		[string]$DestinationPath
	)
	
	if(!$VMName) {
		if(!$global:Session) {
			$VMName = Read-Host -Prompt 'VM Name'
		} else {
			$VMName=$Session.ComputerName
		}
	}

	if ($DestinationPath -eq "") {
		$DestinationPath = Read-Host -Prompt 'Destination path'
	}

	Move-VMStorage $VMName -DestinationStoragePath $DestinationPath
}

# Function InstallScripts
# {
	# [string]$Destination="c:\"
	
	# "Import-Module $Destination\Scripts\windows.psm1 -force -global" > C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1
# }


#SetDefaultScriptsSession -Name "#VMATTemp" -NetWorkCredential $(Get-Credential) -WindowsSource "\\WTBRSENXKQX2L.gmea.gad.schneider-electric.com\Files\Scripts\windows.psm1"
Function SetDefaultScriptsSession
{
	Param(
		[string]$VMName,
		[System.Management.Automation.PSCredential]$VMCredential,
		[System.Management.Automation.Runspaces.PSSession]$OldSession=$Global:Session,
		[string]$WindowsSource=$global:WindowsSource,
		[System.Management.Automation.PSCredential]$NetWorkCredential=$Global:NetWorkCredential
	)
	
	if($OldSession) {
		if(!$VMName) {
			$VMName = $OldSession.ComputerName
		}

		if(!$VMCredential) {
			$VMCredential=$OldSession.Runspace.ConnectionInfo.Credential
		}
		
		Get-PSSession | where { $_.ComputerName -eq $VMName } | Remove-PSSession
	} else {
		if(!$VMName) {
			$VMName = Read-Host -Prompt 'Virtual machine name'
		}

		if(!$VMCredential) {
			$VMCredential = $(Get-Credential MyVMUser)
		}
	}
	
	$global:Session = New-PSSession -VMName $VMName -Credential $VMCredential
	
	if(!$WindowsSource) {
		$global:WindowsSource = Read-Host -Prompt 'windows.psm1 source'
	}
	
	Invoke-Command -Session $global:Session -ScriptBlock {

		if(($using:WindowsSource).substring(0,4) -eq "http") {
			Set-ExecutionPolicy Bypass -Scope Process -Force
			[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
			iex (iwr $using:WindowsSource -Headers @{"Cache-Control"="no-cache"} -UseBasicParsing | Select-Object -Expand Content)
		}
		
		if(($using:WindowsSource).substring(0,2) -eq "\\") {
			if($using:NetWorkCredential) {
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
		[System.Management.Automation.Runspaces.PSSession]$Session=$Global:Session,
		[string]$Source,
		[string]$Destination,
		[System.Management.Automation.PSCredential]$NetWorkCredential=$Global:NetWorkCredential,
		[switch]$Force
	)
	
	if(!$Session) {
		SetDefaultScriptsSession
	}
	
	Invoke-Command -Session $global:Session -ScriptBlock {
		$netCred=$using:NetWorkCredential

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

