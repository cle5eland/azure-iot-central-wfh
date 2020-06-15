#!/bin/bash
$alias=$args[0]
$ip=$args[1]
$machineName=$args[2]
$rg=$args[3]
$subscription=$args[4]
az vm deallocate --name $machineName -g $rg --subscription $subscription
