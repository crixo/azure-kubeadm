# Install k8s cluster on azure VMs using kubeadm

This walkthough is full inspired by a [Swan](https://medium.com/@shawnlu_86806)'s [article on medium](https://medium.com/@shawnlu_86806/how-to-create-a-k8s-cluster-with-kubeadm-on-azure-357210e2eb50)
I simply try to put everything together in a very simple way to help anyone else who is interested on following the same approach.
Any improvement, refinements and suggestions are more then welcome.

*<code>&ast;</code>local.<code>&ast;</code>* files contains sensitive data so they have not been pushed on the remote repo. The equivalent file contains the value placeholder to be replaced w/ your personal values.

-  provision azure resources
*from local shell*
```
cd extras/azure-kubeadm/
./azure-resources-provisioning.sh
scp azure-cloud-conf.local.conf cristiano@master1-testk8s.westeurope.cloudapp.azure.com:~/cloud.conf
scp kubeadm.conf cristiano@master1-testk8s.westeurope.cloudapp.azure.com:~/
```

*from k8s-master1 shell*
```
sudo cp ~/cloud.conf /etc/kubernetes
```

-  create the cluster using kubeadm and configure master node
```
bash ./k8sMaster.sh | tee ~/master.out
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

-  deploy a basic ngnix app
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

-  test ClusterIP on all nodes
*from k8s nodes shell*
```
curl http://<basicservice ClusterIP> 
```