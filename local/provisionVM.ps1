#! /usr/bin/pwsh

$subscriptionName=Read-Host -Prompt "Enter Azure Subscription [default: Visual Studio Enterprise Subscription]"
if ([string]::IsNullOrWhiteSpace($subscriptionName))
{
    $subscriptionName = "Visual Studio Enterprise Subscription"
}
$rg="IOTC_WFH"
$vmName="IOTC_WFH_MACHINE"
az account set --subscription $subscriptionName
$subscriptionId=az account show --query id -o tsv
az account list-locations --query [].name
$loc=Read-Host -Prompt "Enter resource location [westus]"
if ([string]::IsNullOrWhiteSpace($loc))
{
    $loc = "westus"
}
$userId=Read-Host -Prompt "Enter Microsoft alias"
az group create --name $rg --location $loc
az vm create --resource-group $rg --name $vmName --admin-username $userId --image UbuntuLTS --generate-ssh-keys --authentication-type ssh --size Standard_B8ms --os-disk-size-gb 100 --public-ip-address-allocation static 
az vm open-port -g $rg -n $vmName --port 22
$email=$userId+'@microsoft.com'
az vm auto-shutdown -g $rg -n $vmName --time 0200 --email $email
Write-Host "Provisioning Complete! Note the publicIpAddress field above. Now generating scripts with your public IP..."
./generateUserScripts.ps1 $userId $vmName $rg $subscriptionId
Write-Host "Complete!"