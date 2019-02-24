# Kubernetes on azure

## The hussle-free way
[Azure AKS](https://docs.microsoft.com/en-us/azure/aks/)

## The EZ way
[Azure ACS](https://github.com/Azure/acs-engine/blob/master/docs/kubernetes/deploy.md)

## The geeky way
[kubeadm on azure](docs/azure-kubeadm.md)

This walkthough is fully inspired by a [Swan](https://medium.com/@shawnlu_86806)'s [article on medium](https://medium.com/@shawnlu_86806/how-to-create-a-k8s-cluster-with-kubeadm-on-azure-357210e2eb50)  
I simply tried to put everything together in a very simple way to help anyone else who is interested on following the same approach.  
Any improvements, refinements and suggestions are more then welcome: **please fork and send pull requests!**  

This tutorial is part of the journey of using kubeadm on azure that started w/ an [issue using Calico CNI](https://docs.projectcalico.org/v3.5/reference/public-cloud/azure).  
Calico was the perfect choice on all cloud providers tested so far (AWS an GCP) but azure, so I decide to investigate an alternative solution.
