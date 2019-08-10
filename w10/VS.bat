##https://docs.microsoft.com/pt-br/visualstudio/install/command-line-parameter-examples?view=vs-2019
#vs_enterprise.exe --installPath C:\minVS ^
#--add Microsoft.VisualStudio.Workload.CoreEditor ^
#--passive --norestart
######
#vs_enterprise.exe --update --quiet --wait
#vs_enterprise.exe update --wait --passive --norestart --installPath "C:\installPathVS"
######
#vs_enterprise.exe --installPath C:\desktopVS ^
#--addProductLang fr-FR ^
#--add Microsoft.VisualStudio.Workload.ManagedDesktop ^
#--includeRecommended --quiet --wait
######
#start /wait vs_professional.exe --installPath "C:\VS" --passive --wait > nul
#echo %errorlevel%
######
#vs_community.exe --layout C:\VS
#--lang en-US ^
#--add Microsoft.VisualStudio.Workload.CoreEditor
######
#vs_community.exe --layout C:\VS ^
#--lang en-US ^
#--add Microsoft.VisualStudio.Workload.NetWeb ^
#--add Microsoft.VisualStudio.Workload.ManagedDesktop ^
#--add Component.GitHub.VisualStudio ^
#--includeRecommended
######
#vs_enterprise.exe --all

##https://www.visualstudio.com/thank-you-downloading-visual-studio/?sku=Community&rel=16
##Invoke-WebRequest https://www.visualstudio.com/thank-you-downloading-visual-studio/?sku=Community&rel=16 -OutFile C:\Users\MyUser\Downloads\vs_community.exe
##vs_community.exe --includeRecommended --quiet --wait
##vs_community.exe --includeRecommended --passive --wait
#start /wait vs_community.exe --includeRecommended --passive --wait > nul

##VS build
#choco install -y --limit-output --no-progress microsoft-build-tools
#choco install -y --limit-output --no-progress visualstudio2017buildtools

#Nuget prompt
choco install -y --limit-output --no-progress nuget.commandline




##### INSTALL SQL - https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017
