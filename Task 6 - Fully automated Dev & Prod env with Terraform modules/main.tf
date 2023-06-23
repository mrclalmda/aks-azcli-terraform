module "dev_cluster" {
    source       = "./main"
    env_name     = "dev"
    cluster_name = "learnk8scluster"
}

module "prod_cluster" {
    source       = "./main"
    env_name     = "prod"
    cluster_name = "learnk8scluster"
}