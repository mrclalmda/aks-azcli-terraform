# aks-cli
Create and update AKS cluster though AZ CLI

# Ways to provide a cluster
3 ways
- (1) Using AWS Web interface through *ClickOps* -> avoid because does not scale well and it is error prone
- (2) Use Azure CLI
- (3) Define the cluster with code tool such as Terraform

You should aim to use 2 and 3 together.

In this lesson we will do the following though Azure CLI:
- Learn basic commands
- Create a new Resource Group
- Create a cluster
- Update cluster configurations such as location and node count
- Delete everything previously created

# Main concepts
- AKS is Azures equirvalent of Amazons EKS. A Kubernetes cloud service.
- Kubectl is AKS CLI.
- AKS manages the cluster control plane, Kubernetes API and etcd database
- Use az-cli

# How to
First list and can see if there are any clusters already created

```
az aks list
```

To create a new clust, first we need to have a **resource group** to assign one to.

Use an existing one
```
az group list
```

Or, create a new one.

```
az group create --namd ResourceGroupName --location brazil
```

Register a resource provider
```
az provider -n Microsfot.ContainerService
```

Create the cluster assigning it to a ResourceGroup. If you do not provide ssh credentials, you need to have them generated. Optionally you can chose how many nodes it should have.
```
az create -g ResourceGroupName -n ClusterName --generate-ssh-keys --node-count 2
```

Update it passing the parameters you wish to update. You should always provider the cluster and its group name
```
az aks update --resource-group ResourceGroupName --name ClusterName --enable-duster-auscaler --min-count 1 --max-count 2
```
**DONE!** Cluster created

Deleting resources

First we shall delete the cluster
```
az aks delete -name ClusterName --resource-group Resource GroupName
```
Then finally the group
```
az group delete --resource-group ResourceGroupName
```
**DONE!** All resources previously created were destroyed, check by using the ```list``` command for both group and cluster
