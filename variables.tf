variable "ibmcloud_api_key" {
  description = "APIkey that's associated with the account to use"
  type        = string
  sensitive   = true
}

variable "cluster-name" {
  type        = string
  description = "Name of the target or new IBM Cloud OpenShift Cluster"
}

variable "region" {
  type        = string
  description = "IBM Cloud region. Use 'ibmcloud regions' to get the list"
}

variable "number-gpu-nodes" {
  type        = number
  description = "The number of GPU nodes expected to be found or to create in the cluster"
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
  description = "COS instance where a bucket will be created to back ROKS internal registry. Leave blank if you want the DA to create a new COS instance"
  default     = null
}

variable "resource-group" {
  type        = string
  description = "Specify an existing resource group if you want to use it. Leave blank to have a new one created"
  default     = null
}
