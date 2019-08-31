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
 - New-VMW19 <BR>
   powershell.exe -command "& Invoke-WebRequest https://raw.githubusercontent.com/vinils/baxh/master/w2k19/New-VMW19.ps1 -OutFile C:\WINDOWS\System32\New-VMW19.ps1"
  - New-VMW19Docker <BR>
   powershell.exe -command "& Invoke-WebRequest https://raw.githubusercontent.com/vinils/baxh/master/w2k19/New-VMW19Docker.ps1 -OutFile C:\WINDOWS\System32\New-VMW19Docker.ps1"
 - New-VMW10 <BR>
   powershell.exe -command "& Invoke-WebRequest https://raw.githubusercontent.com/vinils/baxh/master/w2k19/New-VMW10.ps1 -OutFile C:\WINDOWS\System32\New-VMW10.ps1"



SAMPLES: <BR>
 - W19Temp <BR>
   onlinerun https://raw.githubusercontent.com/vinils/baxh/master/w2k19/w2k19Temp.ps1
 - W19Docker <BR>
   New-VMW19Docker W19Docker 4 
  - W10 Node <BR>
   New-VMW10 VMNode1 5 https://raw.githubusercontent.com/vinils/baxh/master/w10/Node.ps1
  - W10 VS <BR>
   New-VMW10 VMNode1 5 https://raw.githubusercontent.com/vinils/baxh/master/w10/VS%2BSQLClient.ps1
 
