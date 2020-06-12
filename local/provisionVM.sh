#!/bin/bash
sudo apt-get update
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login --use-device-code
rg="IOTC_WFH"
vmName="IOTC_WFH_MACHINE"
az account set --subscription "Visual Studio Enterprise"
subscriptionId=$(az account show --query id -o tsv)
az account list-locations --query [].name
read -p "Enter resource location [westus]: " loc
loc=${loc:-westus}
read -p "Enter Microsoft alias: " userId
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
read -p "Enter Microsoft Work email: " email
az vm auto-shutdown -g $rg -n $vmName --time 0200 --email $email >/dev/null
echo "Provisioning Complete! Note the publicIpAddress field above. Now generating scripts with your public IP..."
sh ./generateUserScripts.sh $userId $vmName $rg $subscriptionId >/dev/null
echo "Complete!"