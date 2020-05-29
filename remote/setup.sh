#!/bin/bash

cd ~
# Install Node
echo "installing nodejs..."
sudo apt update
sudo apt install nodejs
sudo apt install npm
nodejs -v
echo "Done!"

# Configure Python
echo "configuring python..."
sudo apt -y upgrade
sudo apt install -y python3-pip
sudo apt install build-essential libssl-dev libffi-dev python3-dev
echo "Done!"

# configure .npmrc
echo "Configuring npm..."
read -p "Packaging personal access token (generated from VSTS): " token
b64=($(echo $token | base64))
printf '%s\n' "${b64}"

npmrc="@azure-iot:registry=https://msazure.pkgs.visualstudio.com/_packaging/AzureIOTSaas/npm/registry/
always-auth=true
//msazure.pkgs.visualstudio.com/_packaging/AzureIOTSaas/npm/registry/:username=msazure
//msazure.pkgs.visualstudio.com/_packaging/AzureIOTSaas/npm/registry/:_password=$b64
//msazure.pkgs.visualstudio.com/_packaging/AzureIOTSaas/npm/registry/:email=npm requires email to be set but doesn't use the value
//msazure.pkgs.visualstudio.com/_packaging/AzureIOTSaas/npm/:username=msazure
//msazure.pkgs.visualstudio.com/_packaging/AzureIOTSaas/npm/:_password=$b64
//msazure.pkgs.visualstudio.com/_packaging/AzureIOTSaas/npm/:email=npm requires email to be set but doesn't use the value
"

rm ~/.npmrc
echo $npmrc > ~/.npmrc

echo "npm configured successfully!"

# Clone the repo
echo "Cloning the IoT Central Repository..."
git config --global credential.helper store
# Generate a PAT before this step.
read -p "git will ask for you username and password. Your username should be your alias, and your password should be the Personal Access Token generated with git permissions on VSTS."
git clone https://msazure.visualstudio.com/DefaultCollection/One/_git/azure-iots-saas

echo "Repo cloned!"

# Install docker
echo "Installing docker..."
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce
sudo systemctl status docker
echo "Done"

cd azure-iots-saas/infrastructure
npm ci && npm run build
npm run ecosystem -- -d