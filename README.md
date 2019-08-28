# baxh
batchs and bashs

curl https://raw.githubusercontent.com/vinils/baxh/master/linux/onlinerun -o /bin/onlinerun<br>
chmod +xr /bin/onlinerun<br>
or<br>
powershell.exe -command "& Invoke-WebRequest https://raw.githubusercontent.com/vinils/baxh/master/windows/onlinerun.bat -OutFile C:\WINDOWS\System32\onlinerun.bat"<br>

- arch-install<br>
onlinerun https://raw.githubusercontent.com/vinils/baxh/master/arch/install.sh
- firstboot<br>
onlinerun https://raw.githubusercontent.com/vinils/baxh/master/arch/firstboot.sh $PWD
- samba<br>
onlinerun https://raw.githubusercontent.com/vinils/baxh/master/arch/samba.sh $PWD
- kvm<br>
onlinerun https://raw.githubusercontent.com/vinils/baxh/master/arch/kvm.sh
- W2k19 Drivers<br>
onlinerun https://raw.githubusercontent.com/vinils/baxh/master/w2k19/Drivers.bat




COMMMANDs:<BR>
 - New-VMW19 $Name $DriveOpt $UriSettings
   powershell.exe -command "& Invoke-WebRequest https://raw.githubusercontent.com/vinils/baxh/master/w2k19/New-VMW19.ps1 -OutFile C:\WINDOWS\System32\New-VMW19.ps1"
  - New-VMW19Docker $Name $DriveOpt
   powershell.exe -command "& Invoke-WebRequest https://raw.githubusercontent.com/vinils/baxh/master/w2k19/New-VMW19Docker.ps1 -OutFile C:\WINDOWS\System32\New-VMW19Docker.ps1"



HOST - W2K19<BR>
GUESTs:<BR>
 - W19Temp<BR>
   onlinerun https://raw.githubusercontent.com/vinils/baxh/master/w2k19/w2k19Temp.ps1
  - 
