#!/bin/bash

cd ~
# Install Node
echo "installing nodejs..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install node
echo "Done!"

# Configure Python
echo "configuring python..."
sudo apt -y -qq upgrade
sudo apt -y -qq install python3-pip
sudo apt -y -qq install build-essential libssl-dev libffi-dev python3-dev
echo "Done!"

# configure .npmrc
echo "Configuring npm..."
read -p "Packaging personal access token (generated from VSTS): " token
b64=$(echo $token | base64)
printf '%s\n' "${b64}"

npmrc="@azure-iot:registry=https://msazure.pkgs.visualstudio.com/_packaging/AzureIOTSaas/npm/registry/\n
always-auth=true\n
; begin auth token\n
//msazure.pkgs.visualstudio.com/_packaging/AzureIOTSaas/npm/registry/:username=msazure\n
//msazure.pkgs.visualstudio.com/_packaging/AzureIOTSaas/npm/registry/:_password=$b64\n
//msazure.pkgs.visualstudio.com/_packaging/AzureIOTSaas/npm/registry/:email=email\n
//msazure.pkgs.visualstudio.com/_packaging/AzureIOTSaas/npm/:username=msazure\n
//msazure.pkgs.visualstudio.com/_packaging/AzureIOTSaas/npm/:_password=$b64\n
//msazure.pkgs.visualstudio.com/_packaging/AzureIOTSaas/npm/:email=email\n
; end auth token"

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
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
# sudo apt -y -qq update
# apt-cache policy docker-ce
sudo apt-get remove docker docker-engine docker.io
sudo apt install -y -qq containerd docker.io
sudo systemctl unmask docker
sudo systemctl start docker
sudo systemctl enable docker
docker --version
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo "Done"

# configure user.env
echo "Configuring user.env..."
read -p "Please provide alias: " user
user_env ="SERVICE_BUS_TOPIC=WFH_$user\n
COMMON_NAMESPACE=WFH_$user\n
IOTHUB_USE_ENVIRONMENT_POOLING=false\n
MONITOR_IOTHUB_ENABLE=true\n
# SERVICE_BUS_CONNECTION_STRING={ \"id\": \"https://projectsantorini-local.vault.azure.net/secrets/service-bus-connection-string\" }\n
IOTHUBS_EVENT_HUB_CONNECTION_STRING={ \"id\": \"https://projectsantorini-local.vault.azure.net/secrets/iothubs-event-hub-connection-string-4\" }\n
"
cd azure-iots-saas/infrastructure
rm user.env
echo $user_env > user.env
echo "user.env configured!"
echo "Running IoT Central..."
npm ci && npm run build
npm run refresh-local-keys
npm run ecosystem -- -d
echo "IoT Central running successfully!"