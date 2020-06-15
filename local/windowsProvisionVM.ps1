#! /usr/bin/pwsh

$rg="IOTC_WFH"
$vmName="IOTC_WFH_MACHINE"
az account set --subscription "Visual Studio Enterprise"
$subscriptionId=az account show --query id -o tsv
az account list-locations --query [].name
$loc=Read-Host -Prompt "Enter resource location [westus]"
if ([string]::IsNullOrWhiteSpace($loc))
{
    $loc = "westus"
}
$userId=Read-Host -Prompt "Enter Microsoft alias"
az group create --name $rg --location $loc
az vm create --resource-group $rg --name $vmName --admin-username $userId --image UbuntuLTS --generate-ssh-keys --authentication-type ssh --size Standard_E4s_v3 --os-disk-size-gb 100 --public-ip-address-allocation static 
az vm open-port -g $rg -n $vmName --port 22 >/dev/null
$email=$userId+'@microsoft.com'
az vm auto-shutdown -g $rg -n $vmName --time 0200 --email $email >/dev/null
Write-Host "Provisioning Complete! Note the publicIpAddress field above. Now generating scripts with your public IP..."
sh ./generateUserScripts.sh $userId $vmName $rg $subscriptionId >/dev/null
Write-Host "Complete!"