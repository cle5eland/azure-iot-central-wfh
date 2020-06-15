#! /usr/bin/pwsh
alias=$1
machineName=$2
rg=$3
subscription=$4
ip=$(az vm show -d --resource-group $rg -n $machineName --subscription $subscription --query publicIps -o tsv)
rm -rf user
mkdir user
echo "../powershell-templates/startWFH.ps1 $alias $ip $machineName $rg $subscription" > ./user/startWFH.ps1
echo "../powershell-templates/stopWFH.ps1 $alias $ip $machineName $rg $subscription" > ./user/stopWFH.ps1
echo "../powershell-templates/proxy-port.sh $alias $ip" > ./user/proxy-port.ps1
echo "../powershell-templates/ssh.sh $alias $ip" > ./user/ssh.ps1

