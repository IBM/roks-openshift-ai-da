---

copyright:
  years: 2024
lastupdated: "2024-07-26"

keywords:

subcollection: deployable-reference-architectures

authors:
  - name: "Darrell Schrag"

# The release that the reference architecture describes
version: 3.0.8

# Whether the reference architecture is published to Cloud Docs production.
# When set to false, the file is available only in staging. Default is false.
production: true

# Use if the reference architecture has deployable code.
# Value is the URL to land the user in the IBM Cloud catalog details page
# for the deployable architecture.
# See https://test.cloud.ibm.com/docs/get-coding?topic=get-coding-deploy-button
#deployment-url: https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-slz-ocp-95fccffc-ae3b-42df-b6d9-80be5914d852-global

#docs: https://cloud.ibm.com/docs/secure-infrastructure-vpc

image_source: https://https://github.com/IBM/roks-openshift-ai-da/blob/main/reference-architectures/RHOAI.svg

related_links:
  - title: "OpenShift on IBM Cloud - Basic variation"
    #url: "https://cloud.ibm.com/docs/deployable-reference-architectures?topic=deployable-reference-architectures-vsi-ra"
    description: "A deployable architecture that creates a new ROKS cluster with OpenShift AI installed."

use-case: AI
industry: Banking,FinancialSector

content-type: reference-architecture

---

{{site.data.keyword.attribute-definition-list}}

# OpenShift AI on IBM Cloud
{: #rhoai}
{: toc-content-type="reference-architecture"}
{: toc-industry="Banking,FinancialSector"}
{: toc-use-case="Cybersecurity"}
{: toc-version="3.0.8"}

OpenShift AI on IBM Cloud is a deployable architecture solution that quickly creates a simple OpenShift cluster with all of the OpenShift AI content installed.

## Architecture diagram
{: #rhoai-architecture-diagram}

![Architecture diagram of the OpenShift AI on IBM Cloud deployable architecture](RHOAI.svg "Architecture diagram of OpenShift AI on IBM Cloud deployable architecture"){: caption="Figure 1. Architecture diagram for OpenShift AI on IBM Cloud" caption-side="bottom"}{: external download="RHOAI.svg"}

<!--
TODO: Add the typical use case for the architecture.
The use case might include the motivation for the architecture composition,
business challenge, or target cloud environments.
-->

## Components
{: #rhoai-components}

### Architecture decisions
{: #rhoai-components-arch}

| Requirement | Component | Reasons for choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
| Provide the right VPC networking for OpenShift AI use | VPC | The VPC created underneath the cluster is very simple and fully publicly accessible. There is no attempt to lock down network access. | Use the full SLZ VPC architecture |
| Provide the right type of cluster for OpenShift AI use | ROKS cluster | Create a single zone cluster. HA is not as much a requirement for AI workloads so keeping all workers in single zone was chosen | Create a multi-zone cluster |
| Provide the most flexible worker pool structure | ROKS cluster worker pools | Create a small 2 node single zone worker pool with standard 4x16 VSIs. This gives the user a place to deploy applications or observability that keeps work off the GPU nodes. Create a second GPU worker pool. The GPU worker pool can be scaled to zero to save money on GPUs when not in use. | |
| Speed of setup over features  | ROKS cluster integrations | The goal of this DA is to get to use quickly. Therefore the created cluster is not integrated with observability or security services. | Use the SLZ ROKS cluster DA to create the cluster instead. |
{: caption="Table 1. Architecture decisions" caption-side="bottom"}


<!--
## Compliance
{: #ra-ocp-compliance}

TODO: Decide whether to include a compliance section, and if so, add that information

_Optional section._ Feedback from users implies that architects want only the high-level compliance items and links off to control details that team members can review. Include the list of control profiles or compliance audits that this architecture meets. For controls, provide "learn more" links to the control library that is published in the IBM Cloud Docs. For audits, provide information about the compliance item.
-->

## Next steps
{: #rhoai-next-steps}

Once you have outgrown this cluster architecture for your OpenShift AI use, craft the cluster you desire using other Deployable Architectures and then add the OpenShift AI add-on.