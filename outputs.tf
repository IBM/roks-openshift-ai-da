##############################################################################
# Outputs
##############################################################################
output cluster_id {
    description = "The ID of the created cluster"
    value       = module.ocp_base.cluster_id
}

output cos_instance_crn {
    description = "The CRN of the COS instance used by the ROKS cluster"
    value       = module.ocp_base.cos_crn
}

output resource_group_id {
    description = "The ID of the resource group created or used"
    value       = module.resource_group.resource_group_id
}

output vpc_id {
    description = "The ID of the created VPC"
    value       = module.slz_vpc.vpc_id
}