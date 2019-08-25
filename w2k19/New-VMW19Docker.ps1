$Name = $args[0]
$DriveOpt = $args[1]

switch($DriveOpt) {
   1 { $drive = 'D:' }
   2 { $drive = 'E:' }
   3 { $drive = 'F:' }
   4 { $drive = 'G:' }
   5 { $drive = 'H:' }
   6 { $drive = 'Z:' }
}

New-VMW19 $Name $DriveOpt https://raw.githubusercontent.com/vinils/baxh/master/w2k19/Docker.ps1

