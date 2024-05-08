terraform {
  required_version = ">= 1.6.0, <1.7.0"
  required_providers {
    # Use a range in modules
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.59.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.8.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.16.1"
    }
  }
}
