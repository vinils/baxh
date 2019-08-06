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

#https://www.visualstudio.com/thank-you-downloading-visual-studio/?sku=Community&rel=19

##VS build
#choco install -y --limit-output --no-progress microsoft-build-tools
choco install -y --limit-output --no-progress visualstudio2017buildtools

#Nuget prompt
choco install -y --limit-output --no-progress nuget.commandline
