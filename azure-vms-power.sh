if [ -z "$1" ]
  then
    echo "No argument supplied"
    exit
fi

RESOURCE_GROUP=$2

if [ $1 = 'stop' ]
  then
    echo "Stopping VMs"

    az vm stop -g $RESOURCE_GROUP -n 'master-1'
    az vm stop -g $RESOURCE_GROUP -n 'worker-1'
    az vm stop -g $RESOURCE_GROUP -n 'worker-2'
fi

az vm show -d --ids $(az vm list -g $RESOURCE_GROUP --query "[].id" -o tsv) | grep powerState