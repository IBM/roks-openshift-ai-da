########################################################################################################################
# Determnine if the user named resource group and COS instance exists
########################################################################################################################
data "external" "resource_data" {
  program    = ["bash", "${path.module}/scripts/check-resources.sh"]
  query      = {
    rg_name  = var.resource-group == null ? "does not exist" : var.resource-group
    cos_name = var.cos-instance == null ? "does not exist" : var.cos-instance
  }
}

########################################################################################################################
# Resource Group
########################################################################################################################
module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.6"
  resource_group_name          = data.external.resource_data.result.create_rg == "true" ? (var.resource-group == null ? "rhoai-resource-group" : var.resource-group) : null
  existing_resource_group_name = data.external.resource_data.result.create_rg == "false" ? var.resource-group : null
}

##############################################################################
# Fetch the COS info if one already exists
##############################################################################
data "ibm_resource_instance" "cos_instance" {
  count             = data.external.resource_data.result.create_cos == "false" ? 1 : 0
  name              = var.cos-instance
  service           = "cloud-object-storage"
}

########################################################################################################################
# VPC + Subnet + Public Gateway
########################################################################################################################
module "slz_vpc" {
  source              = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version             = "7.19.1"
  region              = var.region
  resource_group_id   = module.resource_group.resource_group_id
  name                = "rhoai-vpc"
  subnets             = local.subnets
  network_acls        = [local.network-acl]
  use_public_gateways = local.gateways
}

locals {

  kubeconfig = data.ibm_container_cluster_config.da_cluster_config.config_file_path
  resource_group = module.resource_group.resource_group_id
  operating_system = var.ocp-version == "4.14" ? "REDHAT_8_64" : "RHCOS"

  subnet = {
    name           = "rhoai-subnet"
    cidr           = "10.10.10.0/24"
    public_gateway = true
    acl_name       = "rhoai-acl"
  }

  network-acl = {
    name = "rhoai-acl"
    add_ibm_cloud_internal_rules = false
    add_vpc_connectivity_rules   = false
    prepend_ibm_rules            = false
    rules = [ {
        name        = "rhoai-inbound"
        action      = "allow"
        source      = "0.0.0.0/0"
        destination = "0.0.0.0/0"
        direction   = "inbound"
      },
      {
        name        = "rhoai-outbound"
        action      = "allow"
        source      = "0.0.0.0/0"
        destination = "0.0.0.0/0"
        direction   = "outbound"
      }
    ]
  }

  subnets = {
    zone-1 = var.zone == 1 ? [local.subnet] : []
    zone-2 = var.zone == 2 ? [local.subnet] : []
    zone-3 = var.zone == 3 ? [local.subnet] : []
  }

  gateways = {
    zone-1 = var.zone == 1 ? true : false
    zone-2 = var.zone == 2 ? true : false
    zone-3 = var.zone == 3 ? true : false
  }

  cluster_vpc_subnets = {
    default = [
      {
        id         = module.slz_vpc.subnet_zone_list[0].id
        cidr_block = module.slz_vpc.subnet_zone_list[0].cidr
        zone       = module.slz_vpc.subnet_zone_list[0].zone
      } ],
      gpu = [
      {
        id         = module.slz_vpc.subnet_zone_list[0].id
        cidr_block = module.slz_vpc.subnet_zone_list[0].cidr
        zone       = module.slz_vpc.subnet_zone_list[0].zone
      } ]
  }

  default_worker_count = 2
  total_workers = sum([local.default_worker_count, var.number-gpu-nodes])
  worker_pools = [
    {
      subnet_prefix     = "default"
      pool_name         = "default" # ibm_container_vpc_cluster automatically names default pool "default" (See https://github.com/IBM-Cloud/terraform-provider-ibm/issues/2849)
      machine_type      = "bx2.8x32"
      operating_system  = local.operating_system
      workers_per_zone  = local.default_worker_count
    },
    {
      subnet_prefix     = "gpu"
      pool_name         = "GPU"
      machine_type      = var.machine-type
      operating_system  = local.operating_system
      workers_per_zone  = var.number-gpu-nodes
      secondary_storage = "300gb.5iops-tier"
    }
  ]
}

##############################################################################
# Create the cluster
##############################################################################
module "ocp_base" {
  source                              = "terraform-ibm-modules/base-ocp-vpc/ibm"
  version                             = "3.35.8"
  resource_group_id                   = local.resource_group
  region                              = var.region
  tags                                = ["createdby:RHOAI-DA"]
  cluster_name                        = var.cluster-name
  force_delete_storage                = true
  vpc_id                              = module.slz_vpc.vpc_id
  vpc_subnets                         = local.cluster_vpc_subnets
  ocp_version                         = var.ocp-version
  worker_pools                        = local.worker_pools
  ocp_entitlement                     = null
  disable_outbound_traffic_protection = true
  use_existing_cos                    = data.external.resource_data.result.create_cos == "false" ? true : false
  existing_cos_id                     = data.external.resource_data.result.create_cos == "false" ? data.ibm_resource_instance.cos_instance[0].id : null
  cos_name                            = var.cos-instance == null ? "rhoai-cos-instance" : var.cos-instance
}

##############################################################################
# Retrieve information about all the Kubernetes configuration files and
# certificates to access the cluster in order to run kubectl / oc commands
# (This is probabaly not needed any more)
##############################################################################
data "ibm_container_cluster_config" "da_cluster_config" {
  cluster_name_id = module.ocp_base.cluster_id
  config_dir      = "${path.module}/kubeconfig"
  endpoint_type   = null # null represents default
  admin           = true
}

##############################################################################
# Call the RHOAI add-on
##############################################################################
resource "null_resource" "call_rhoai_addon" {
    depends_on = [ data.ibm_container_cluster_config.da_cluster_config ]

    provisioner "local-exec" {
    command     = "${path.module}/scripts/call-rhoai-addon.sh ${var.cluster-name} ${local.total_workers}"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = local.kubeconfig
    }
  }
}

