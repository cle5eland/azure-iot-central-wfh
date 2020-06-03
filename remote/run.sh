# login to docker hub
docker login

# configure user.env
printf '\n%s\n' "Configuring user.env..."
user_env="SERVICE_BUS_TOPIC=WFH_$user\n
COMMON_NAMESPACE=WFH_$user\n
IOTHUB_USE_ENVIRONMENT_POOLING=false\n
MONITOR_IOTHUB_ENABLE=true\n
# SERVICE_BUS_CONNECTION_STRING={ \"id\": \"https://projectsantorini-local.vault.azure.net/secrets/service-bus-connection-string\" }\n
IOTHUBS_EVENT_HUB_CONNECTION_STRING={ \"id\": \"https://projectsantorini-local.vault.azure.net/secrets/iothubs-event-hub-connection-string-4\" }\n
"
cd azure-iots-saas/infrastructure
sudo rm user.env
echo $user_env > user.env
echo "user.env configured!"
echo "Running IoT Central..."
npm ci && npm run build
sudo rm -rf projectsantorini-keyvault-int*
npm run refresh-local-keys
npm run ecosystem -- -d
printf '\n%s\n' "IoT Central running successfully!"
