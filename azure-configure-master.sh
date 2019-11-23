# RESOURCE_GROUP='your_rg_group'
read -r -p "RESOURCE GROUP  " RESOURCE_GROUP
if [[ "$RESOURCE_GROUP" == "" ]]; then
    exit
fi

bash azure-resources-provisioning.sh $RESOURCE_GROUP

TEMPLATE_FILE=azure-cloud-conf-$RESOURCE_GROUP.local.template.conf
TARGET_FILE=azure-cloud-conf-$RESOURCE_GROUP.local.conf
cp $TEMPLATE_FILE $TARGET_FILE
sed -i.bak 's/@@RESOURCE_GROUP@@/'"$RESOURCE_GROUP"'/g' $TARGET_FILE
rm $TARGET_FILE.bak

#exit
MASTER_PREFIX_NAME='master'
MASTER_NODE_DNS="$MASTER_PREFIX_NAME-1-$RESOURCE_GROUP"
#MASTER_NODE_IP=az vm show -d -g $RESOURCE_GROUP -n "$MASTER_PREFIX_NAME-1" --query publicIps -o tsv
TEMPLATE_FILE=kubeadm.template.conf
TARGET_FILE=kubeadm.conf
cp $TEMPLATE_FILE $TARGET_FILE
sed -i.bak 's/@@MASTER_NODE_DNS@@/'"$MASTER_NODE_DNS"'/g' $TARGET_FILE
rm $TARGET_FILE.bak

#exit
scp "azure-cloud-conf-$RESOURCE_GROUP.local.conf" "cristiano@master-1-$RESOURCE_GROUP.westeurope.cloudapp.azure.com:~/cloud.conf"
scp kubeadm.conf k8sMaster.sh basic.yaml "cristiano@master-1-$RESOURCE_GROUP.westeurope.cloudapp.azure.com:~/"
ssh cristiano@master-1-$RESOURCE_GROUP.westeurope.cloudapp.azure.com