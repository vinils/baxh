#!/bin/bash

mkdir /var/onlinerun/
randomStr=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
filePath="/var/onlinerun/tmp$randomStr.bash"
curl $1 -o $filePath
chmod +xr $filePath
./$filePath $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 
rm $filePath
