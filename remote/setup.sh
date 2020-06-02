#!/bin/bash

printf '\n%s\n' "Starting setup..."
set +e
$wd=$(pwd) 
cd ~
# Install Node
printf '\n%s\n' "installing nodejs..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash >/dev/null
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install node >/dev/null
printf '\n%s\n' "Done!"

# Configure Python
printf '\n%s\n' "configuring python..."
sudo apt -y -qq upgrade >/dev/null
sudo apt -y -qq install python3-pip >/dev/null
sudo apt -y -qq install build-essential libssl-dev libffi-dev python3-dev >/dev/null
echo "Done!"

# configure .npmrc
printf '\n%s\n' "Configuring npm..."
read -p "Packaging personal access token (generated from VSTS): " token
b64=$(echo $token | base64)

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

printf '\n%s\n' "npm configured successfully!"

# Clone the repo
echo "Cloning the IoT Central Repository..."
git config --global credential.helper store
# Generate a PAT before this step.
read -p "git will ask for you username and password. Your username should be your alias, and your password should be the Personal Access Token generated with git permissions on VSTS. Press enter to continue." throwaway
sudo rm -rf azure-iots-saas
git clone https://msazure.visualstudio.com/DefaultCollection/One/_git/azure-iots-saas

printf '\n%s\n' "Repo cloned!"


# Install docker
printf '\n%s\n' "Installing docker..."
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
# sudo apt -y -qq update
# apt-cache policy docker-ce
sudo apt -y remove docker docker-engine docker.io >/dev/null
sudo apt -y install containerd docker.io >/dev/null
sudo getent group docker || sudo groupadd docker
sudo usermod -aG docker $USER
# enable rootless
curl -fsSL https://get.docker.com/rootless | sh
printf '\n%s\n' "unmasking docker..."
sudo systemctl unmask docker >/dev/null
printf '\n%s\n' "starting docker..."
systemctl --user start docker
printf '\n%s\n' "enabling docker..."
systemctl --user enable docker
sudo loginctl enable-linger $(whoami)
printf '\n%s\n' "installing docker compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# sudo groupadd docker;
# sudo rm ~/.docker
printf '\n%s\n' "Done!"



# configure hosts file
printf '\n%s\n' "Configuring hosts file..."
hosts="127.0.0.1 localhost\n
\n
# The following lines are desirable for IPv6 capable hosts\n
::1 ip6-localhost ip6-loopback\n
fe00::0 ip6-localnet\n
ff00::0 ip6-mcastprefix\n
ff02::1 ip6-allnodes\n
ff02::2 ip6-allrouters\n
ff02::3 ip6-allhosts\n
127.0.0.1       saas.localhost\n
127.0.0.1       apps.saas.localhost\n
127.0.0.1       static.saas.localhost\n
127.0.0.1       rp.saas.localhost\n
127.0.0.1       auth.saas.localhost\n
127.0.0.1       assets.saas.localhost\n
127.0.0.1       api.saas.localhost\n
127.0.0.1       management.saas.localhost"
sudo rm /etc/hosts
echo $hosts | sudo tee /etc/hosts
printf '\n%s\n' "Done!"

# configure user.env
printf '\n%s\n' "Configuring user.env..."
read -p "Please provide alias: " user
user_env="SERVICE_BUS_TOPIC=WFH_$user\n
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
sudo rm -rf projectsantorini-keyvault-int*
npm run refresh-local-keys
newgrp docker <<EONG
npm run ecosystem -- -d
EONG
echo "IoT Central running successfully!"

cd $wd