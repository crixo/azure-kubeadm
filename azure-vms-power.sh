# if [ -z "$1" ]
#   then
#     echo "No argument supplied"
#     exit
# fi

read -r -p "ACTION(start|stop)  " ACTION
if [[ ! $ACTION =~ ^(start|stop)$ ]]; then 
    echo "ACTION parameter $ACTION is not valid"
    exit
fi

read -r -p "RESOURCE_GROUP  " RESOURCE_GROUP
if [[ "$RESOURCE_GROUP" == "" ]]; then
    exit
fi

# RESOURCE_GROUP=$2

vms_ids=$(az vm list -g "$RESOURCE_GROUP" --query "[].id" -o tsv)
echo $vms_ids

if [ $ACTION = 'stop' ]
  then
    echo "Stopping VMs"
    az vm stop --ids $vms_ids
    az vm deallocate --ids $vms_ids
fi

if [ $ACTION = 'start' ]
  then
    echo "Restarting VMs"

    az vm start --ids $vms_ids
fi

az vm show -d --ids $vms_ids | grep powerState