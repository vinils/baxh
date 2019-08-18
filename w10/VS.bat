#https://github.com/MicrosoftDocs/visualstudio-docs/blob/master/docs/install/create-a-network-installation-of-visual-studio.md
#https://github.com/MicrosoftDocs/visualstudio-docs/blob/master/docs/install/automated-installation-with-response-file.md
#https://docs.microsoft.com/en-us/visualstudio/install/command-line-parameter-examples?view=vs-2019
#https://docs.microsoft.com/en-us/visualstudio/install/create-a-network-installation-of-visual-studio?view=vs-2019

#net use z: \\192.168.15.250\z$

##https://www.visualstudio.com/thank-you-downloading-visual-studio/?sku=Community&rel=16
##Invoke-WebRequest https://www.visualstudio.com/thank-you-downloading-visual-studio/?sku=Community&rel=16 -OutFile C:\Users\MyUser\Downloads\vs_community.exe
Invoke-WebRequest -Uri 'https://download.visualstudio.microsoft.com/download/pr/818029a2-ea31-4a6a-8bed-f50abbaf9716/ff2d0f080b97ad9de29126e301f93a26/vs_community.exe' -OutFile VS2019Community.exe

#.\VS2019Community.exe --layout 'Z:\SOFTWARES\WORK\MS Visual Studio\DOT NET 2019 Community' --lang en-US
#.\VS2019Community.exe --passive --wait --norestart
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
##vs_community.exe --includeRecommended --quiet --wait
##vs_community.exe --includeRecommended --passive --wait
#start /wait vs_community.exe --includeRecommended --passive --wait > nul

#to get the add list - open visual studio installer > go to more > export configuration
#& "Z:\SOFTWARES\WORK\MS Visual Studio\DOT NET 2019 Community\VS2019Community.exe" `
& .\VS2019Community.exe `
--add "Microsoft.VisualStudio.Component.CoreEditor" `
--add "Microsoft.VisualStudio.Workload.CoreEditor" `
--add "Microsoft.VisualStudio.Component.NuGet" `
--add "Microsoft.Net.Component.4.6.1.TargetingPack" `
--add "Microsoft.VisualStudio.Component.Roslyn.Compiler" `
--add "Microsoft.VisualStudio.Component.Roslyn.LanguageServices" `
--add "Microsoft.VisualStudio.Component.FSharp" `
--add "Microsoft.Net.Core.Component.SDK.2.1" `
--add "Microsoft.NetCore.ComponentGroup.DevelopmentTools.2.1" `
--add "Microsoft.VisualStudio.Component.FSharp.WebTemplates" `
--add "Microsoft.VisualStudio.ComponentGroup.WebToolsExtensions" `
--add "Microsoft.VisualStudio.Component.DockerTools" `
--add "Microsoft.NetCore.ComponentGroup.Web.2.1" `
--add "Microsoft.Net.Component.4.7.2.SDK" `
--add "Microsoft.Net.Component.4.7.2.TargetingPack" `
--add "Microsoft.Net.ComponentGroup.DevelopmentPrerequisites" `
--add "Microsoft.VisualStudio.Component.TypeScript.3.5" `
--add "Microsoft.VisualStudio.Component.JavaScript.TypeScript" `
--add "Microsoft.VisualStudio.Component.JavaScript.Diagnostics" `
--add "Microsoft.Component.MSBuild" `
--add "Microsoft.VisualStudio.Component.TextTemplating" `
--add "Component.Microsoft.VisualStudio.RazorExtension" `
--add "Microsoft.VisualStudio.Component.IISExpress" `
--add "Microsoft.VisualStudio.Component.SQL.ADAL" `
--add "Microsoft.VisualStudio.Component.SQL.LocalDB.Runtime" `
--add "Microsoft.VisualStudio.Component.Common.Azure.Tools" `
--add "Microsoft.VisualStudio.Component.SQL.CLR" `
--add "Microsoft.VisualStudio.Component.MSODBC.SQL" `
--add "Microsoft.VisualStudio.Component.MSSQL.CMDLnUtils" `
--add "Microsoft.VisualStudio.Component.ManagedDesktop.Core" `
--add "Microsoft.Net.Component.4.5.2.TargetingPack" `
--add "Microsoft.Net.Component.4.5.TargetingPack" `
--add "Microsoft.VisualStudio.Component.SQL.SSDT" `
--add "Microsoft.VisualStudio.Component.SQL.DataSources" `
--add "Component.Microsoft.Web.LibraryManager" `
--add "Microsoft.VisualStudio.ComponentGroup.Web" `
--add "Microsoft.VisualStudio.Component.Web" `
--add "Microsoft.VisualStudio.Component.IntelliCode" `
--add "Microsoft.Net.Component.4.TargetingPack" `
--add "Microsoft.Net.Component.4.5.1.TargetingPack" `
--add "Microsoft.Net.Component.4.6.TargetingPack" `
--add "Microsoft.Net.ComponentGroup.TargetingPacks.Common" `
--add "Component.Microsoft.VisualStudio.Web.AzureFunctions" `
--add "Microsoft.VisualStudio.ComponentGroup.AzureFunctions" `
--add "Microsoft.VisualStudio.Component.Azure.Compute.Emulator" `
--add "Microsoft.VisualStudio.Component.Azure.Storage.Emulator" `
--add "Microsoft.VisualStudio.Component.Azure.ClientLibs" `
--add "Microsoft.VisualStudio.Component.Azure.AuthoringTools" `
--add "Microsoft.VisualStudio.Component.CloudExplorer" `
--add "Microsoft.VisualStudio.ComponentGroup.Web.CloudTools" `
--add "Microsoft.VisualStudio.Component.DiagnosticTools" `
--add "Microsoft.VisualStudio.Component.EntityFramework" `
--add "Microsoft.VisualStudio.Component.AspNet45" `
--add "Microsoft.VisualStudio.Component.AppInsights.Tools" `
--add "Microsoft.VisualStudio.Component.WebDeploy" `
--add "Microsoft.VisualStudio.Component.Debugger.JustInTime" `
--add "Microsoft.VisualStudio.Workload.NetWeb" `
--add "Microsoft.VisualStudio.Component.ManagedDesktop.Prerequisites" `
--add "Microsoft.ComponentGroup.Blend" `
--add "Microsoft.VisualStudio.Workload.ManagedDesktop" `
--quiet --wait --norestart | Out-Null

##Nuget prompt
#choco install -y --limit-output --no-progress nuget.commandline

##### INSTALL SQL - https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017
