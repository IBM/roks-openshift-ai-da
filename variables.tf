variable "ibmcloud_api_key" {
  description = "APIkey that's associated with the account to use"
  type        = string
  sensitive   = true
}

variable "cluster-name" {
  type        = string
  description = "Name of new IBM Cloud OpenShift Cluster"
}

variable "region" {
  type        = string
  description = "IBM Cloud region. Use 'ibmcloud regions' to get the list"
}

variable "zone" {
  type        = number
  description = "The region availability zone. Allowable values are 1, 2, or 3"
  default     = 1
}

variable "number-gpu-nodes" {
  type        = number
  description = "The number of GPU nodes to create in the cluster"
  default     = 2
}

variable "ocp-version" {
  type        = string
  description = "Major.minor version of the OCP cluster to provision"
}

variable "machine-type" {
  type        = string
  description = "Worker node machine type. Should be a GPU flavor. Use 'ibmcloud ks flavors --zone <zone>' to retrieve the list."
}

variable "cos-instance" {
  type        = string
  description = "COS instance where a bucket will be created to back ROKS internal registry. Leave blank if you want the DA to create a new COS instance named rhoai-cos-instance, or specify a name for a new COS instance or an existing COS instance."
  default     = null
}

variable "resource-group" {
  type        = string
  description = "Leave blank if you want the DA to create a new resource group named rhoai-resource-group, or specify the name for a new or existing resource group."
  default     = null
}
