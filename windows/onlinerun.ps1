$command = ((new-object net.webclient).DownloadString($args[0]))
Invoke-Command -ScriptBlock ([scriptblock]::Create($command)) -Argumentlist $args[1], $args[2], $args[3], $args[4], $args[5], $args[6], $args[7], $args[8], $args[9], $args[10], $args[11]
