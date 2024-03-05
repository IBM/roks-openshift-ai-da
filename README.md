# roks-openshift-ai-da
The repository holds the terraform code for the ROKS OpenShift AI Deployable Architecture

The goal of this Deployable Architecture is to quickly create an environment to get hands on with Red Hat OpenShift AI using a ROKS cluster in IBM Cloud. The DA itself will create a simple 1 zone cluster for the user if desired, or you can pre-create the cluster. The DA will then install the OpenShift AI stack.

If the user chooses to create a cluster, the following items will get created:
1. A resource group named ai-resource-group
2. A subnet named roks-gpu-subnet-1 in zone 1 of the chosen region in the resource group
3. A public gateway named roks-gpu-gateway-1 attached to the subnet in the resource group
4. A vpc named roks-gpu-vpc containing the above subnet and public gateway in the resource group
5. A single zone ROKS cluster in the created subnet and vpc with the user specified number of workers in the resource group. The cluster does not have logging, monitoring, secrets manager, or encryption attached at all. It will be publicly accessible.

This rest of the Terraform script will deploy the Operators necessary for the Red Hat OpenShift AI functionality to the new or existing ROKS cluster. The following Operators and their corresponding components are deployed.

1. Red Hat Pipelines Operator - Incorporate Tekton pipelines into your AI work
2. Red Hat Node Discovery Feature Operator
    - Node Discovery Feature instance - this instance actually does the work of labeling nodes
3. Nvidia GPU Operator
    - Cluster Policy instance - this instance installs the GPU stack of daemonsets and pods
4. Red Hat OpenShift AI Operator
    - OpenShift AI instance - this instance installs the components

## Required Inputs
This Terraform script works in two ways. You can pre-create your cluster and then use this Terraform to install the Opertors into your existing cluster. Or you can have the Terraform create a simple single zone cluster for you first and then it will apply the operators to that cluster.

## Required IAM access policies
You need the following permissions to run this module.

- IAM Services
  - **Kubernetes** service (to create and access a ROKS cluster)
      - `Administrator` platform access
      - `Manager` service access
  - **VPC Infrastructure** service (to create VPC resources)
      - `Administrator` platform access
      - `Manager` service access
  - **All Account Management** service (to create a resource group)
      - `Administrator` platform access
      - `Manager` service access

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, <1.6.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.8.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.59.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.16.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ibmcloud_api_key | APIkey that's associated with the account to use | `string` | none | yes |
| cluster-name | Name of the target or new IBM Cloud OpenShift Cluster | `string` | none | yes |
| region | IBM Cloud region. Use 'ibmcloud regions' to get the list | `string` | none | yes |
| number-gpu-nodes | The number of GPU nodes expected to be found or to create in the cluster | `number` | none | yes |

### The following inputs are only required if you want Terraform to create a cluster. All below values must be provided if you want Terraform to create a cluster.

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create-cluster | Set to true if you want a new cluster created. Set to false to use a pre-existing cluster. | `bool` | `false` | no |
| ocp-version | Major.minor version of the OCP cluster to provision | `string` | none | no |
| machine-type | Worker node machine type. Should be a GPU flavor. Use 'ibmcloud ks flavors --zone <zone>' to retrieve the list.| `string` | none | no |
| cos-instance | A pre-existing COS service instance where a bucket will be provisioned to back the ROKS internal registry | `string` | none | mo |

## Sample terraform.tfvars file

**NOTE:** If running Terraform yourself, pass in your `ibmcloud_api_key` in the environment variable `TF_VAR_ibmcloud_api_key`

```
cluster-name = "torgpu"
region = "ca-tor"
number-gpu-nodes = 2
# variables when creating a new cluster
create-cluster = true
ocp-version = "4.14"
machine-type = "gx3.16x80.l4"
cos-instance = "Cloud Object Storage-drs"
```



