#VSCode
choco install vscode -y --limit-output --no-progress --params "/NoDesktopIcon /NoQuicklaunchIcon /NoContextMenuFiles /NoContextMenuFolders"

##old way
#choco install nodejs.install

#bug problem using nvm through choco - next time try invoke-webrequest nvm release page "https://github.com/coreybutler/nvm-windows/releases" unzip nvm and nvm-setup.exe /?
##NodeJs throw NVM
#choco install -y --limit-output --no-progress nvm
#start powershell -wait {nvm install latest}
##nvm ls
##nvm use 12.7.0
#start powershell -wait {nvm use $(nvm ls)}

#Yarn
choco install -y --limit-output --no-progress yarn

##gulp
#choco install -y --limit-output --no-progress gulp-cli

