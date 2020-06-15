#!/bin/bash
alias=$1
machineName=$2
rg=$3
subscription=$4
ip=$(az vm show -d --resource-group $rg -n $machineName --subscription $subscription --query publicIps -o tsv)
rm -rf user
mkdir user
echo "../templates/startWFH.ps1 $alias $ip $machineName $rg $subscription" > ./user/startWFH.ps1
echo "../templates/stopWFH.ps1 $alias $ip $machineName $rg $subscription" > ./user/stopWFH.ps1
echo "sh ../templates/proxy-port.sh $alias $ip" > ./user/proxy-port.sh
echo "sh ../templates/ssh.sh $alias $ip" > ./user/ssh.sh

