RESOURCE_GROUP='testk8s'
LOCATION='westeurope'
IMAGE='UbuntuLTS'
#MASTER_SKU='Standard_D1_v2'
MASTER_SKU='Standard_B2s'
AGENT_SKU='Standard_B1s'
VNET='testk8s-vnet'
SUBNET='default'
NSG='testk8s-nsg'
ROUTE_TABLE='testk8s-routetable'
SUBSCRIPTION='d9e06499-49d3-4d60-b301-3ff03e019bb7' # "Visual Studio Ultimate with MSDN"
MASTERS_AVAILABILITY_SET='testk8s-m'
WORKERS_AVAILABILITY_SET='testk8s-w'
MASTER_PREFIX_NAME='master'
WORKER_PREFIX_NAME='worker'
ASG_NODE_NAME='asg-k8s-node'
PUBLIC_SSH_KEY_FILE_PATH='@/Users/cristiano/.ssh/azure-vm_rsa.pub'
STORAGE_SKU='StandardSSD_LRS'
OS_DISK_SIZE_GB=10
VM_STARTUP_SCRIPT='k8s-node.sh'


az login

echo "Setting the azure subscription"
az account set --subscription=$SUBSCRIPTION

# echo "Creating the Service Principal"
# this is a one-time operation: the SP could remain on your subscription/tenant after resource group deletion
# az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION"

echo "Creating the resource group"
az group create -g $RESOURCE_GROUP -l $LOCATION

echo "Creating the application security group"
az network asg create \
  --resource-group $RESOURCE_GROUP\
  --name $ASG_NODE_NAME \
  --location $LOCATION

echo "Creating the route table"
# https://docs.microsoft.com/en-us/cli/azure/network/route-table?view=azure-cli-latest#az-network-route-table-create
az network route-table create -g $RESOURCE_GROUP -n $ROUTE_TABLE

echo "Creating the network security group"
# https://docs.microsoft.com/en-us/cli/azure/network/nsg?view=azure-cli-latest#az-network-nsg-create
az network nsg create -g $RESOURCE_GROUP  -n $NSG

echo "Creating the SSH inbound rule"
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
  --destination-port-range 22
  --destination-asgs $ASG_NODE_NAME \

echo "Creating the VNET"
# https://docs.microsoft.com/en-us/azure/virtual-network/quick-create-cli
# https://docs.microsoft.com/en-us/azure/virtual-network/tutorial-filter-network-traffic-cli
# https://docs.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az-network-vnet-create
az network vnet create -g $RESOURCE_GROUP \
-n $VNET \
--address-prefix 192.169.0.0/16 \
# --subnet-name $SUBNET \
# --subnet-prefix 192.169.0.0/16

echo "Creating the SUBNET"
az network vnet subnet create \
  --vnet-name $VNET \
  --resource-group $RESOURCE_GROUP  \
  --name $SUBNET \
  --address-prefix 192.169.0.0/16 \
  --network-security-group $NSG

echo "Creating the master node VM"
# https://docs.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az-vm-create
az vm create -g $RESOURCE_GROUP -n "$MASTER_PREFIX_NAME1" \
  --size $MASTER_SKU \
  --image $IMAGE \
  --public-ip-address-dns-name "$MASTER_PREFIX_NAME1-$RESOURCE_GROUP" \
  --nsg "" \
  --asg $ASG_NODE_NAME \
  --vnet-name $VNET \
  --subnet $SUBNET \
  --availability-set $MASTERS_AVAILABILITY_SET \
  --custom-data $VM_STARTUP_SCRIPT \
  --storage-sku $STORAGE_SKU \
  --os-disk-size-gb $OS_DISK_SIZE_GB \
  --ssh-key-value $PUBLIC_SSH_KEY_FILE_PATH
  ##--generate-ssh-keys

echo "Creating the first worker node VM"
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
  --os-disk-size-gb $OS_DISK_SIZE_GB \
  --ssh-key-value $PUBLIC_SSH_KEY_FILE_PATH
  #--generate-ssh-keys

echo "Creating the second worker node VM"
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
  --os-disk-size-gb $OS_DISK_SIZE_GB \
  --ssh-key-value $PUBLIC_SSH_KEY_FILE_PATH

# https://github.com/kubernetes/cloud-provider-azure/blob/master/docs/cloud-provider-config.md
echo "Azure resources provisioning done"
