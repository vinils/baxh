@echo off

set url=%1
set file=%random%%random%.%url:~-3%
set filepath=%HOMEDRIVE%%HOMEPATH%\onlinerun

IF NOT EXIST %filepath% ( mkdir %filepath% )

powershell.exe -command "& Invoke-WebRequest %url% -OutFile %filepath%\%file%"
%filepath%\%file% %2 %3 %4 %5 %6 %7 %8 %9 %10 %11

del %filepath%\%file%
