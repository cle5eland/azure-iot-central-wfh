#!/bin/bash
az account set --subscription "Visual Studio Enterprise"
az account list-locations --query [].name
read -p "Enter resource location [westus]: " loc
loc=${loc:-westus}
read -p "Enter Microsoft alias: " userId
rg="IOTC_WFH"
vmName="IOTC_WFH_MACHINE"
az group create --name $rg --location $loc
az vm create \
    --resource-group $rg \
    --name $vmName \
    --admin-username $userId \
    --image UbuntuLTS \
    --generate-ssh-keys \
    --authentication-type ssh \
    --size Standard_E4s_v3 \
    --os-disk-size-gb 100 \
    --public-ip-address-allocation static 
az vm open-port -g $rg -n $vmName --port 22 >/dev/null