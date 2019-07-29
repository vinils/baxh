$url=$args[0]
$file="$(Get-Random)$(Get-Random).$($url.Substring($url.Length - 3))"
$filepath="$home\onlinerun"

if (!(Test-Path $filepath)) { mkdir $filepath }

Invoke-WebRequest $url -OutFile "$filepath\$file"
#echo "$filepath\$file $($args[1]) $($args[2]) $($args[3]) $($args[4]) $($args[5]) $($args[6]) $($args[7]) $($args[8]) $($args[9]) $($args[10]) $($args[11])"
Invoke-Expression -Command "$filepath\$file $($args[1]) $($args[2]) $($args[3]) $($args[4]) $($args[5]) $($args[6]) $($args[7]) $($args[8]) $($args[9]) $($args[10]) $($args[11])"

del "$filepath\$file"
