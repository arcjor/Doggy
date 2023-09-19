
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

export ACR_RG_NAME=dog-sb-${AZ_SB_CONTEXT}-shared-acr
export ACR_NAME=dogsb${AZ_SB_CONTEXT}sharedacr
export GIT_HASH=$(git log --format="%h" -n 1)

if $(az group exists --name ${ACR_RG_NAME}); then az group create --location eastus --name ${ACR_RG_NAME}; fi

# Check if the ACR has already been created
az acr show --name $ACR_NAME

if [ $? -ne 0 ]; then
    echo "ACR does not exist, creating."
    az acr create -n $ACR_NAME -g $ACR_RG_NAME --sku Standard
    az acr update -n $ACR_NAME --admin-enabled true
else
    echo "ACR already exists, continuing."
fi


export ACR_USER=$(az acr credential show -n $ACR_NAME | jq -r .username)
export ACR_PASS=$(az acr credential show -n $ACR_NAME | jq -r .passwords[0].value)
az acr login -n $ACR_NAME --username $ACR_USER --password $ACR_PASS

docker tag doggy:${GIT_HASH} $ACR_NAME.azurecr.io/doggy:${GIT_HASH}

docker push $ACR_NAME.azurecr.io/doggy:${GIT_HASH}
