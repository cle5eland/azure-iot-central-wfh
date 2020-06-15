#! /usr/bin/pwsh
$alias=$args[0]
$ip=$args[1]
$machineName=$args[2]
$rg=$args[3]
$subscription=$args[4]
az vm start --name $machineName -g $rg --subscription $subscription
sh ./proxy-port.sh $alias $ip
sh ./ssh.sh $alias $ip
