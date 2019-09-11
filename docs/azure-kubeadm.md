# Install k8s cluster on azure VMs using kubeadm

*<code>&ast;</code>local.<code>&ast;</code>* files contains sensitive data so they have not been pushed on the remote repo. The equivalent file contains the value placeholder to be replaced w/ your personal values.

-  provision azure resources
*from local shell*
```
bash ./azure-configure-master.sh
```

*from k8s-master1 shell*
```
sudo cp ~/cloud.conf /etc/kubernetes
```

-  create the cluster using kubeadm and configure master node
```
bash k8sMaster.sh | tee ~/master.out
```

OR


-  create the cluster using kubeadm

*from k8s-master1 shell*
```
sudo kubeadm init --config kubeadm.conf
```

output should be the following

> Your Kubernetes master has initialized successfully!
> 
> To start using your cluster, you need to run the following as a regular user:
> 
>   mkdir -p $HOME/.kube
>   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
>   sudo chown $(id -u):$(id -g) $HOME/.kube/config
> 
> You should now deploy a pod network to the cluster.
> Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
>   https://kubernetes.io/docs/concepts/cluster-administration/addons/
> 
> You can now join any number of machines by running the following on each node
> as root:
> 
>   kubeadm join XXXX:6443 --token XXXX --discovery-token-ca-cert-hash > sha256:XXXX

-  configure kubectl config
*from k8s-master1 shell*
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

-  install Canal CNI pluging
*from k8s-master1 shell*
```
wget https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/canal/rbac.yaml -O rbac.yaml
wget https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/canal/canal.yaml  -O canal.yaml

kubectl apply -f rbac.yaml
kubectl apply -f canal.yaml
```

-  join the worker node(s)
*from worker node(s) shell*
use the kubeadm join... saved in master.out

- download k8s configuration
```
scp "cristiano@master-1-$RESOURCE_GROUP.westeurope.cloudapp.azure.com:~/.kube/config" k8s.local.conf
```

-  deploy a basic ngnix app
*from local shell*
```
kubectl --kubeconfig k8s.local.conf create -f basic.yaml
```

OR

*from k8s-master1 shell*
```
kubectl create -f basic.yaml
```

OR a more complex app
```
kubectl apply -f https://raw.githubusercontent.com/Azure-Samples/azure-voting-app-redis/master/azure-vote-all-in-one-redis.yaml
```

-  get pod and service
*from k8s-master1 shell*
```
kubectl get pod,svc
```

-  make sure canal has been installed on all nodes
```
kubectl get pods -n kube-system -o wide | grep canal
```

-  test ClusterIP on all nodes
*from k8s nodes shell*
```
curl http://<basicservice ClusterIP> 
```

-  test NodePort on all nodes
*from local shell*
```
curl http://master-1-testk8s.westeurope.cloudapp.azure.com:<NodePort>
curl http://worker-1-testk8s.westeurope.cloudapp.azure.com:<NodePort>
curl http://worker-2-testk8s.westeurope.cloudapp.azure.com:<NodePort>
```

-  if you'd like to deploy application workload on master node too, you have to remove the taint that prevent it
```
kubectl taint nodes --all node-role.kubernetes.io/master:NoSchedule-
```