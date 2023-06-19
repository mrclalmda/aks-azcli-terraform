# Getting started with Terraform and Kubernetes on Azure AKS
We will learn how to create Kubernetes clusters on Azure Kubernetes Service (AKS) with the Azure CLI and Terraform.

Automate creating two clusters (dev and prod) complete with an Ingress controller.

## Lessons
<details>
  <summary>Create and update AKS cluster though AZ CLI</summary>

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

## Deleting resources

First we shall delete the cluster
```
az aks delete -name ClusterName --resource-group Resource GroupName
```
Then finally the group
```
az group delete --resource-group ResourceGroupName
```
**DONE!** All resources previously created were destroyed, check by using the ```list``` command for both group and cluster
  
</details>
<details>
  <summary>AKS cluster with Terraform</summary>

# AKS cluster with Terraform

- Terraform is an opensource IaaC tool
- With HCL, plan and translate it into code so Terraform can take on the rest
- Make sure to have Terraform binary installed

## How to

- 1) Get subscription ID and take note of it
```
az account list
```

- 2) We need to create a Contributor Service Principal to provide Terraform so it can act on our behalf
```
az ad sp create for-rabc --role="Contributor" --scopes="/subscriotions/YOUR_SUB_ID"
```
Will return appId, password, tenant, displayName and name.

- 3) Export environment variables so Terraform can access them
```
export ARM_CLIENT_ID = appId
export ARM_SUBSCRIPTION_ID = subscription ID 
export ARN_TENANT_ID = tenant
export ARM_CLIENT_SECRET = password
```

- 4) Create the most basic .tf file called main.tf and write the following code. As we can see, we can co-relate with lesson number 1.

Here, instead of running every single command through Az CLI, we will set it up and Terraform will automate its creation.

```
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.48.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "learnk8sResourceGroup"
  location = "northeurope"
}
```

- 5) Run init so Terraform can prepare by translating the instructions into API calls and it will create a state file to keep track of what it has already done
```
terraform init
```

- 6) Plan and revise before creating. The following command allows us to do just that
```
terraform plan
```

- 7) Apply the plan
```
terraform apply
```

And DONE! We have successfully used Terraform to create a resource group

- 8) Destroy everything created
```
terraform destroy
```
</details>


<details>
  <summary>Create production-ready cluster adding a second pool to it</summary>
 
1) Reduce node count from 2 to 1, under default_node_pool in main.tf file

2) Add following resouce creating to main.tf
```
resource "azurerm_kubernetes_cluster_node_pool" "mem" {
 kubernetes_cluster_id = azurerm_kubernetes_cluster.cluster.id
 name                  = "mem"
 node_count            = "1"
 vm_size               = "standard_d11_v2"
}
```
3) Plan, check and apply
```
terraform plan
```
```
terraform apply
```

4) Verify the new pool has been created
```
kubeclt get nodes --kubeconfig kubeconfig
```

 </details>  
<details>
  <summary>Deploy simple app</summary>
  
1) Create YAML deployment file
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-kubernetes
spec:
  selector:
    matchLabels:
      name: hello-kubernetes
  template:
    metadata:
      labels:
        name: hello-kubernetes
    spec:
      containers:
        - name: app
          image: paulbouwer/hello-kubernetes:1.8
          ports:
            - containerPort: 8080
```
2) Submit definition to the cluster
```
kubectl apply -f deployment.yaml
```
*Export Kubeconfig file to ~/.kube/config so you dont have to passs ```--kubeconfig kubeconfig``` all the time

3) Get the name of the pod 
```
kubectl get pods
```  

4) Connect to the pod
```
kubectl port-foward <NAME-OF-THE-POD> 8080:8080
```
The application is exposed, but that is not a great way to do it. Use service of type loadbalancer to expose them.

5) Create service-loadbalancer.yaml file
```
apiVersion: v1
kind: Service
metadata:
  name: hello-kubernetes
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 8080
  selector:
    name: hello-kubernetes
```

6) Submit YAML
```
kubectl apply -f service-loadbalancer.yaml
```

7) DONE! Application is exposed through its public IP
 ```
 kubectl get svc
 ```

However, the loadbalancer created only services one service at a time. Load balancers are expensive and theres a way to get around this.
  </details> 

## Thank you!

@Kristijan Mitevski
