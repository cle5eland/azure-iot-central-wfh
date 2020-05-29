#!/bin/bash
alias=$1
machineName=$2
rg=$3
subscription=$4
ip=($(az vm show -d --resource-group $rg -n $machineName --subscription $subscription --query publicIps -o tsv))
rm -rf user
mkdir user
echo "sh ../templates/startWFH.sh $alias $ip $machineName $rg $subscription" > ./user/startWFH.sh
echo "sh ../templates/stopWFH.sh $alias $ip $machineName $rg $subscription" > ./user/stopWFH.sh
echo "sh ../templates/proxy-port.sh $alias $ip" > ./user/proxy-port.sh

