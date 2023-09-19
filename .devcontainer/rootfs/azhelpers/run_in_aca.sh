
az account show
if [ $? -ne 0 ]; then
    echo "Please log in with 'az login'"
    exit 1
fi

if [ -z "$SANDBOX_SUBSCRIPTION" ]; then 
    echo "Please define the SANDBOX_SUBSCRIPTION."
    exit 1
fi

az account set --subscription=${SANDBOX_SUBSCRIPTION}

if [ -z "$AZ_SB_CONTEXT" ]; then
    export AZ_SB_CONTEXT=dev
fi

export ACR_NAME=dogsb${AZ_SB_CONTEXT}sharedacr
export APP_RG_NAME=dog-sb-${AZ_SB_CONTEXT}-shared-app
export VNET_NAME=dog-sb-${AZ_SB_CONTEXT}-shared-app-vnet
export CAE_NAME=dog-sb-${AZ_SB_CONTEXT}-shared-app-cae
export PG_NAME=dog-sb-${AZ_SB_CONTEXT}-shared-app-psql

export GIT_HASH=$(git log --format="%h" -n 1)

export ACR_USER=$(az acr credential show -n $ACR_NAME | jq -r .username)
export ACR_PASS=$(az acr credential show -n $ACR_NAME | jq -r .passwords[0].value)
export SUB_ID=$(az account show | jq -r .id)

if $(az group exists --name ${APP_RG_NAME}); then az group create --location eastus --name ${APP_RG_NAME}; fi

# We assume that the VNET will be created in a bundle with all other components and only check to see if it exists.
az network vnet show --name $VNET_NAME --resource-group $APP_RG_NAME

if [ $? -ne 0 ]; then
    echo "VNet does not exist, creating."
    az network vnet create --name $VNET_NAME --resource-group $APP_RG_NAME --address-prefix 10.0.0.0/16 --subnet-name infrastructure-subnet --subnet-prefixes 10.0.0.0/23
    az network vnet subnet create --resource-group $APP_RG_NAME --vnet-name $VNET_NAME --address-prefixes 10.0.2.0/24 --name dbsubnet
    az network private-dns zone create -g $APP_RG_NAME -n ${AZ_SB_CONTEXT}.private.postgres.database.azure.com
    az postgres flexible-server create --location eastus --resource-group ${APP_RG_NAME} --name ${PG_NAME} --admin-user username --admin-password password --sku-name Standard_B1ms \
        --tier Burstable --private-dns-zone /subscriptions/${SUB_ID}/resourceGroups/${APP_RG_NAME}/providers/Microsoft.Network/privateDnsZones/${AZ_SB_CONTEXT}.private.postgres.database.azure.com \
        --vnet $VNET_NAME --subnet dbsubnet

    INFRASTRUCTURE_SUBNET=`az network vnet subnet show --resource-group ${APP_RG_NAME} --vnet-name $VNET_NAME --name infrastructure-subnet --query "id" -o tsv | tr -d '[:space:]'`

    az containerapp env create --name ${CAE_NAME} --resource-group ${APP_RG_NAME} --location eastus --infrastructure-subnet-resource-id $INFRASTRUCTURE_SUBNET
else
    echo "VNet already exists, continuing."
fi

az containerapp up --name doggy --env-vars ConnectionStrings__PostgreSQL="Server=dog-sb-dev-shared-app-psql.postgres.database.azure.com;Database=postgres;Port=5432;User Id=username;Password=password;" \
    --environment ${CAE_NAME} -i $ACR_NAME.azurecr.io/doggy:${GIT_HASH} --ingress external --registry-password ${ACR_PASS} --registry-username ${ACR_USER} --registry-server $ACR_NAME.azurecr.io -g ${APP_RG_NAME}
