#! /usr/bin/pwsh
$alias=$args[0]
$ip=$args[1]
$machineName=$args[2]
$rg=$args[3]
$subscription=$args[4]
az vm start --name $machineName -g $rg --subscription $subscription
./proxy-port.ps1 $alias $ip
./ssh.ps1 $alias $ip
