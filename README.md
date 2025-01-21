# OpenShift AI on IBM Cloud
The goal of this Deployable Architecture is to quickly create an environment to get hands on Red Hat OpenShift AI using an OpenShift cluster in IBM Cloud. The resources created are simple and concerns like high availability, observability, and security are not taken into account. Again, the goal is to quickly go from zero to a ready and usable Red Hat OpenShift cluster with OpenShift AI installed.
<br/><br/>
This Deployable Architecture calls the OpenShift AI add-on to install the Red Hat OpenShift AI operator and all its dependencies. You will be charged for the use of the cluster and OpenShift AI in your IBM Cloud bill.
<br/><br/>
As mentioned above, the cluster that will be created will be a single zone cluster. It will be created in the specified zone in the region selected. A new VPC is created with a new default subnet created in the specified zone. Attached to that subnet is a public gatway. The cluster is created in this new VPC.
<br/><br/>
You must provide a target region and zone for all of the vpc resources created. You can get the list of regions and zones via the following command:
```
ibmcloud regions
ibmcloud is zones
```
The cluster created will have two worker pools. A default worker pool will be created with two `bx2.8x32` workers. This allows you to run any application pod on nodes other than your GPU nodes to keep workloads from taking up space on your GPU worker(s). A second GPU worker pool will also be created based on the worker type and quantity you specify as inputs. You must provide the GPU machine-type of the GPU worker node. This requires that you choose a machine-type that exists in the specified zone in the region you select. For example, if you want to create a pool with L4 GPUs, you must make sure you select a region that has an L4 GPU flavor in the selected zone of the selected region. If for example you select the Toronto MZR, you can execute this command to see the list of flavors available in the first zone in the Toronto MZR:
```
ibmcloud ks flavors --provider vpc-gen2 --zone ca-tor-1
```
And you will see that there are 3 L4 flavors in that zone - gx3.16x80.l4, gx3.32x160.2l4, and gx3.64x320.4l4. You would supply one of these as the value for the machine-type input variable and provide ca-tor as the value for the region. Also ensure you understand the cost of this worker profile by consulting the IBM Cloud portal.
<br/><br/>
OpenShift on IBM Cloud uses an IBM Cloud Object Storage bucket as the storage backing for its internal registry. The provisioning process creates a bucket in the provided COS instance. Provide the name of an existing IBM Cloud Object Storage instance that you want to use. If you don't provide an instance name, one will be created for you.
<br/><br/>
If you choose OpenShift 4.15 or greater, Red Hat CoreOS will be specified as the worker node operating system.
<br/><br/>
## Created Resources
The following items will get created:
1. A resource group if you don't provide the name of an existing one (default value is `rhoai-resource-group`)
2. A subnet named `rhoai-subnet` in specified zone of the chosen region in the resource group
3. A public gateway named `rhoai-gateway` attached to the subnet in the resource group
4. A vpc named `rhoai-vpc` containing the above subnet and public gateway in the resource group
5. A COS instance if you don't provide the name of an existing one (default value is `rhoai-cos-instance`)
6. A single zone cluster in the created subnet and vpc with the user specified number of workers in the resource group. The cluster does not have logging, monitoring, secrets manager, or encryption attached at all. It will be publicly accessible.

## Required IAM access policies
You need the following permissions to run this module.

- IAM Services
  - **Kubernetes** service (to create and access a cluster)
      - `Administrator` platform access
      - `Manager` service access
  - **VPC Infrastructure** service (to create VPC resources)
      - `Administrator` platform access
      - `Manager` service access
  - **All Account Management** service (to create a resource group)
      - `Administrator` platform access
      - `Manager` service access
  - **Cloud Object Storage** service (to create a COS instance)
      - `Administrator` platform access
      - `Manager` service access

## Requirements
| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0, <1.7.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.59.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.16.1 |

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ibmcloud_api_key | APIkey that's associated with the account to use | `string` | none | yes |
| cluster-name | Name of the target or new IBM Cloud OpenShift Cluster | `string` | none | yes |
| region | IBM Cloud region. Use 'ibmcloud regions' to get the list | `string` | none | yes |
| zone | The availability zone in the selected region. Values are 1, 2, or 3 | `number` | 1 | yes |
| number-gpu-nodes | The number of GPU nodes expected to be found or to create in the cluster | `number` | 1 | yes |
| ocp-version | Major.minor version of the OCP cluster to provision | `string` | none | yes |
| machine-type | Worker node machine type. Should be a GPU flavor. Use 'ibmcloud ks flavors --zone <zone>' to retrieve the list.| `string` | none | yes |
| cos-instance | A COS service instance where a bucket will be provisioned to back the internal registry. You have 3 choices. If you leave this blank, a new COS instance will be created for you named `rhoai-cos-instance`. If you specify the name of a COS instance that already exists, it will be used. Or a new instance will be provided for the name you provide. | `string` | none | no |
| resource-group | A resource group. You have 3 choices. If you leave this blank, a new resource group will be created for you named `rhoai-resource-group`. If you specify the name of a resource group that already exists, it will be used. Or a new resource group will be provided for the name you provide. | `string` | none | no |

## Sample terraform.tfvars file

**NOTE:** If running Terraform yourself, pass in your `ibmcloud_api_key` in the environment variable `TF_VAR_ibmcloud_api_key`

```
cluster-name = "torgpu"
region = "ca-tor"
zone = 1
number-gpu-nodes = 2
ocp-version = "4.16"
machine-type = "gx3.16x80.l4"
# optional inputs
cos-instance = "my-COS-instance"
resource-group = "my-resource-group"
```

## How to Verify Your Cluster is Happy
You can run the following commands to check the health of your GPUs and OpenShift AI.

### Test that the GPU nodes were properly labled by the Node Feature Discovery operator
Check for the label `feature.node.kubernetes.io/pci-10de.present` on the GPU nodes.
```
$oc get nodes -L feature.node.kubernetes.io/pci-10de.present

NAME         STATUS   ROLES           AGE    VERSION            PCI-10DE.PRESENT
10.249.0.4   Ready    master,worker   141m   v1.27.10+28ed2d7   true
10.249.0.5   Ready    master,worker   141m   v1.27.10+28ed2d7   true
```

### Test the GPU Operator
Check the status of the pods in the `nvidia-gpu-operator` namespace. For the pods that have multiple versions of the same name, you should see the number of these pods be the same as the number of GPU worker nodes that you have. All of the pods should be `Running` with the exception of the `cuda-validator` pods that should be `Completed`.
```
$oc get pods -n nvidia-gpu-operator

NAME                                       READY   STATUS      RESTARTS   AGE
gpu-feature-discovery-r9hj2                1/1     Running     0          40m
gpu-feature-discovery-rw5l2                1/1     Running     0          40m
gpu-operator-c897f4b64-8xg84               1/1     Running     0          42m
nvidia-container-toolkit-daemonset-b9c9c   1/1     Running     0          40m
nvidia-container-toolkit-daemonset-v5tjk   1/1     Running     0          40m
nvidia-cuda-validator-rfzhr                0/1     Completed   0          37m
nvidia-cuda-validator-spvqg                0/1     Completed   0          35m
nvidia-dcgm-5m6d9                          1/1     Running     0          40m
nvidia-dcgm-exporter-hf5xj                 1/1     Running     0          40m
nvidia-dcgm-exporter-hfrcc                 1/1     Running     0          40m
nvidia-dcgm-fb47j                          1/1     Running     0          40m
nvidia-device-plugin-daemonset-c2bt4       1/1     Running     0          40m
nvidia-device-plugin-daemonset-pnlwg       1/1     Running     0          40m
nvidia-driver-daemonset-nxmjw              1/1     Running     0          41m
nvidia-driver-daemonset-t8jjn              1/1     Running     0          41m
nvidia-node-status-exporter-9dj9k          1/1     Running     0          41m
nvidia-node-status-exporter-t78km          1/1     Running     0          41m
nvidia-operator-validator-5rjk2            1/1     Running     0          40m
nvidia-operator-validator-8t6vc            1/1     Running     0          40m
```

Run these commands to deploy a simple CUDA VectorAdd sample, which adds two vectors together to ensure the GPUs have bootstrapped correctly.
```
$cat << EOF | oc create -f -

apiVersion: v1
kind: Pod
metadata:
  name: cuda-vectoradd
spec:
 restartPolicy: OnFailure
 containers:
 - name: cuda-vectoradd
   image: "nvidia/samples:vectoradd-cuda11.2.1"
   resources:
     limits:
       nvidia.com/gpu: 1
EOF

pod/cuda-vectoradd created

$oc logs cuda-vectoradd

[Vector addition of 50000 elements]
Copy input data from the host memory to the CUDA device
CUDA kernel launch with 196 blocks of 256 threads
Copy output data from the CUDA device to the host memory
Test PASSED
Done

$oc delete pod cuda-vectoradd

pod "cuda-vectoradd" deleted
```

### Check the status of the OpenShift AI pods

Check that the OpenShift AI pods are healthy. All of the pods (with the exception of the deprecated pod) should by `Running`. These pods will also vary if you have enabled other features of OpenShift AI outside of this deployable architecture.

```
$oc get pods -n redhat-ods-applications

NAME                                                              READY   STATUS      RESTARTS   AGE
data-science-pipelines-operator-controller-manager-799b75bmvkch   1/1     Running     0          119m
etcd-65c8cb4797-mvjmh                                             1/1     Running     0          119m
modelmesh-controller-869b44f89c-jv5cp                             1/1     Running     0          119m
modelmesh-controller-869b44f89c-m7txc                             1/1     Running     0          119m
modelmesh-controller-869b44f89c-nfrtp                             1/1     Running     0          119m
notebook-controller-deployment-76bfd4f8cf-mdflr                   1/1     Running     0          119m
odh-model-controller-6498f8b67c-2kmtr                             1/1     Running     0          119m
odh-model-controller-6498f8b67c-4fnzk                             1/1     Running     0          119m
odh-model-controller-6498f8b67c-b9vrb                             1/1     Running     0          119m
odh-notebook-controller-manager-799547f687-p9sgz                  1/1     Running     0          119m
remove-deprecated-monitoring-69rtn                                0/1     Completed   0          119m
rhods-dashboard-8bbc85997-72w5b                                   2/2     Running     0          119m
rhods-dashboard-8bbc85997-9f44t                                   2/2     Running     0          119m
rhods-dashboard-8bbc85997-jkwzl                                   2/2     Running     0          119m
rhods-dashboard-8bbc85997-x2knq                                   2/2     Running     0          119m
rhods-dashboard-8bbc85997-ztksv                                   2/2     Running     0          119m
```
