echo "Configure master node"

sudo kubeadm init --config kubeadm.conf

sleep 5

echo
echo "Configure kubectl. The same script is part of the kubeadm init output"

mkdir -p $HOME/.kube

sleep 2

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sleep 2

sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo
echo "Download Canal plugin and RBAC YAML files and apply"

#wget https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/canal/rbac.yaml -O rbac.yaml
#wget https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/canal/canal.yaml  -O canal.yaml
wget https://docs.projectcalico.org/v3.8/manifests/canal.yaml  -O canal.yaml

#kubectl apply -f rbac.yaml
kubectl apply -f canal.yaml
sleep 3

echo
echo "Master node configuration Done"
