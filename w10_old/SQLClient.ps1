Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?linkid=2099720' -OutFile C:\Users\Public\Downloads\SSMS-Setup-ENU.exe
C:\Users\Public\Downloads\SSMS-Setup-ENU.exe /install /quiet /norestart | Out-Null
del C:\Users\Public\Downloads\SSMS-Setup-ENU.exe
