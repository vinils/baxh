#VSCode
choco install vscode -y --limit-output --no-progress --params "/NoDesktopIcon /NoQuicklaunchIcon /NoContextMenuFiles /NoContextMenuFolders"

#choco install nodejs.install

#NodeJs throw NVM
choco install -y --limit-output --no-progress nvm
start /wait nvm install latest
#nvm ls
#nvm use 12.7.0

#Yarn
choco install -y --limit-output --no-progress yarn

##gulp
#choco install -y --limit-output --no-progress gulp-cli

