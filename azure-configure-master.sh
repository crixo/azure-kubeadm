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
scp "azure-cloud-conf-$RESOURCE_GROUP.local.conf" "cristiano@master-1-$RESOURCE_GROUP.westeurope.cloudapp.azure.com:~/cloud.conf"
scp kubeadm.conf k8sMaster.sh basic.yaml "cristiano@master-1-$RESOURCE_GROUP.westeurope.cloudapp.azure.com:~/"
ssh cristiano@master-1-$RESOURCE_GROUP.westeurope.cloudapp.azure.com