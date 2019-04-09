if [ -z "$1" ]
  then
    echo "No resource group supplied"
    exit
fi

RESOURCE_GROUP=$1
LOCATION='westeurope'
IMAGE='Canonical:UbuntuServer:16.04.0-LTS:16.04.201903130'
MASTER_SKU='Standard_B2s'
AGENT_SKU='Standard_B1s'
VNET="$RESOURCE_GROUP-vnet"
SUBNET='default'
NSG="$RESOURCE_GROUP-nsg"
ROUTE_TABLE="$RESOURCE_GROUP-routetable"
SUBSCRIPTION='d9e06499-49d3-4d60-b301-3ff03e019bb7' # "Visual Studio Ultimate with MSDN"
MASTERS_AVAILABILITY_SET="$RESOURCE_GROUP-m"
WORKERS_AVAILABILITY_SET="$RESOURCE_GROUP-w"
MASTER_PREFIX_NAME='master'
WORKER_PREFIX_NAME='worker'
ASG_NODE_NAME='asg-k8s-node'
PUBLIC_SSH_KEY_FILE_PATH='@/Users/cristiano/.ssh/azure-vm_rsa.pub'
STORAGE_SKU='StandardSSD_LRS'
#OS_DISK_SIZE_GB=10
VM_STARTUP_SCRIPT='k8s-node.sh'


az login

echo -e "\033[1;36m Setting the azure subscription \033[0m"
az account set --subscription=$SUBSCRIPTION
az account show

# echo "Creating the Service Principal"
# this is a one-time operation: the SP could remain on your subscription/tenant after resource group deletion
# az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION"

echo -e "\033[1;36m Creating the resource group \033[0m"
az group create -g $RESOURCE_GROUP -l $LOCATION

echo -e "\033[1;36m Creating the application security group \033[0m"
az network asg create \
  --resource-group $RESOURCE_GROUP\
  --name $ASG_NODE_NAME \
  --location $LOCATION

echo -e "\033[1;36m Creating the route table \033[0m"
# https://docs.microsoft.com/en-us/cli/azure/network/route-table?view=azure-cli-latest#az-network-route-table-create
az network route-table create -g $RESOURCE_GROUP -n $ROUTE_TABLE

echo -e "\033[1;36m Creating the network security group \033[0m"
# https://docs.microsoft.com/en-us/cli/azure/network/nsg?view=azure-cli-latest#az-network-nsg-create
az network nsg create -g $RESOURCE_GROUP  -n $NSG

echo -e "\033[1;36m Creating the SSH inbound rule \033[0m"
az network nsg rule create \
  -g $RESOURCE_GROUP  \
  --nsg-name $NSG \
  -n Allow-SSH-All \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 110 \
  --source-address-prefix Internet \
  --source-port-range "*" \
  --destination-port-range 22 \
  --destination-asgs $ASG_NODE_NAME

az network nsg rule create \
  -g $RESOURCE_GROUP  \
  --nsg-name $NSG \
  -n Allow-NodePorts \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 120 \
  --source-address-prefix Internet \
  --source-port-range "*" \
  --destination-port-range 30000-32767 \
  --destination-asgs $ASG_NODE_NAME

echo -e "\033[1;36m Creating the VNET \033[0m"
# https://docs.microsoft.com/en-us/azure/virtual-network/quick-create-cli
# https://docs.microsoft.com/en-us/azure/virtual-network/tutorial-filter-network-traffic-cli
# https://docs.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az-network-vnet-create
az network vnet create -g $RESOURCE_GROUP \
-n $VNET \
--address-prefix 192.169.0.0/16
# --subnet-name $SUBNET \
# --subnet-prefix 192.169.0.0/16

echo -e "\033[1;36m Creating the SUBNET \033[0m"
az network vnet subnet create \
  --vnet-name $VNET \
  --resource-group $RESOURCE_GROUP  \
  --name $SUBNET \
  --address-prefix 192.169.0.0/16 \
  --network-security-group $NSG

echo -e "\033[1;36m Creating the master node(s) availability set \033[0m"
az vm availability-set create -n $MASTERS_AVAILABILITY_SET -g $RESOURCE_GROUP

echo -e "\033[1;36m Creating the master node VM \033[0m"
# https://docs.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az-vm-create
az vm create -g $RESOURCE_GROUP -n "$MASTER_PREFIX_NAME-1" \
  --size $MASTER_SKU \
  --image $IMAGE \
  --public-ip-address-dns-name "$MASTER_PREFIX_NAME-1-$RESOURCE_GROUP" \
  --nsg "" \
  --asg $ASG_NODE_NAME \
  --vnet-name $VNET \
  --subnet $SUBNET \
  --availability-set $MASTERS_AVAILABILITY_SET \
  --custom-data $VM_STARTUP_SCRIPT \
  --storage-sku $STORAGE_SKU \
  --ssh-key-value $PUBLIC_SSH_KEY_FILE_PATH
  ##--generate-ssh-keys
  ##--os-disk-size-gb $OS_DISK_SIZE_GB \

echo -e "\033[1;36m Creating the worker node(s) availability set \033[0m"
az vm availability-set create -n $WORKERS_AVAILABILITY_SET -g $RESOURCE_GROUP

echo -e "\033[1;36m Creating the first worker node VM \033[0m"
az vm create -g $RESOURCE_GROUP -n "$WORKER_PREFIX_NAME-1" \
  --size $AGENT_SKU \
  --image $IMAGE \
  --public-ip-address-dns-name "$WORKER_PREFIX_NAME-1-$RESOURCE_GROUP" \
  --nsg "" \
  --asg $ASG_NODE_NAME \
  --vnet-name $VNET \
  --subnet $SUBNET \
  --custom-data $VM_STARTUP_SCRIPT \
  --availability-set $WORKERS_AVAILABILITY_SET \
  --storage-sku $STORAGE_SKU \
  --ssh-key-value $PUBLIC_SSH_KEY_FILE_PATH
  #--generate-ssh-keys
  ##--os-disk-size-gb $OS_DISK_SIZE_GB \

echo -e "\033[1;36m Creating the second worker node VM \033[0m"
az vm create -g $RESOURCE_GROUP -n "$WORKER_PREFIX_NAME-2" \
  --size $AGENT_SKU \
  --image $IMAGE \
  --public-ip-address-dns-name "$WORKER_PREFIX_NAME-2-$RESOURCE_GROUP" \
  --nsg "" \
  --asg $ASG_NODE_NAME \
  --vnet-name $VNET \
  --subnet $SUBNET \
  --custom-data $VM_STARTUP_SCRIPT \
  --availability-set $WORKERS_AVAILABILITY_SET \
  --storage-sku $STORAGE_SKU \
  --ssh-key-value $PUBLIC_SSH_KEY_FILE_PATH

# https://github.com/kubernetes/cloud-provider-azure/blob/master/docs/cloud-provider-config.md
echo -e "\033[1;92m Azure resources provisioning DONE \033[0m"
