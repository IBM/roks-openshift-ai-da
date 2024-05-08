provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

provider "helm" {
  kubernetes {
    host  = data.ibm_container_cluster_config.da_cluster_config.host
    token = data.ibm_container_cluster_config.da_cluster_config.token
  }
}

provider "kubernetes" {
  host  = data.ibm_container_cluster_config.da_cluster_config.host
  token = data.ibm_container_cluster_config.da_cluster_config.token
}