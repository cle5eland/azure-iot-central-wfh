#!/bin/bash
alias=$1
ip=$2
machineName=$3
rg=$4
subscription=$5
az vm deallocate --name $machineName -g $rg --subscription $subscription
