if [ -z "$1" ]
  then
    echo "No argument supplied"
    exit
fi

RESOURCE_GROUP=$2

if [ $1 = 'stop' ]
  then
    echo "Stopping VMs"

    vms_ids=$(az vm list -g "$RESOURCE_GROUP" --query "[].id" -o tsv)

    echo $vms_ids

    az vm stop --ids $vms_ids
    az vm deallocate --ids $vms_ids
fi

az vm show -d --ids $vms_ids | grep powerState