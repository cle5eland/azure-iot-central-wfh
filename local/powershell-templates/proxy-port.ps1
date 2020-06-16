#! /usr/bin/pwsh
$alias=$args[0]
$ip=$args[1]
$endpoint=$alias + '@' + $ip
Start-Process ssh -ArgumentList '-D', '9030', '-f', '-C', '-q', '-N', $endpoint, '-p', '22'