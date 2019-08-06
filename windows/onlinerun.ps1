$command = ((new-object net.webclient).DownloadString($args[0]))
Invoke-Command -ScriptBlock ([scriptblock]::Create($command)) -Argumentlist @args
