#! /usr/bin/pwsh
$alias=$args[0]
$machineName=$args[1]
$rg=$args[2]
$subscription=$args[3]
$ip=$(az vm show -d --resource-group $rg -n $machineName --subscription $subscription --query publicIps -o tsv)
Remove-Item -Recurse -Force user
New-Item -ItemType directory -Name user
echo "../powershell-templates/startWFH.ps1 $alias $ip $machineName $rg $subscription" > ./user/startWFH.ps1
echo "../powershell-templates/stopWFH.ps1 $alias $ip $machineName $rg $subscription" > ./user/stopWFH.ps1
echo "../powershell-templates/proxy-port.ps1 $alias $ip" > ./user/proxy-port.ps1
echo "../powershell-templates/ssh.ps1 $alias $ip" > ./user/ssh.ps1

