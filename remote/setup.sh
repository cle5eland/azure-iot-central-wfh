#!/bin/bash

printf '\n%s\n' "Starting setup..."
set +e
cd ~
read -p "Please provide alias: " user
read -p "Packaging personal access token (generated from VSTS): " token

printf '\n%s\n' "Updating apt..."
sudo apt-get update -y
printf '\n%s\n' "Done."

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
cleanToken=$(echo $token | tr -d '\n')
b64=$(echo -n $cleanToken | base64)

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
read -p "git will ask for your password--this should be the Personal Access Token generated with git permissions on VSTS. Press enter to continue." throwaway
sudo rm -rf azure-iots-saas
git clone https://$user@msazure.visualstudio.com/DefaultCollection/One/_git/azure-iots-saas

printf '\n%s\n' "Repo cloned!"

# Install docker
printf '\n%s\n' "Installing docker..."
sudo apt-get install -y uidmap
sudo apt -y remove docker docker-engine docker.io >/dev/null
sudo apt -y install containerd docker.io >/dev/null
sudo getent group docker || sudo groupadd docker
sudo usermod -aG docker $USER
# enable rootless
# TODO: ensure I actually need rootless
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

printf '\n%s\n' "Setup Complete!"