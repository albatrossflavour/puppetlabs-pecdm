# Puppet Enterprise (pe) Cloud Deployment Module (cdm)

Puppet Enterprise Cloud Deployment Module is a fusion of [puppetlabs/peadm](https://github.com/puppetlabs/puppetlabs-peadm) and Terraform.

This project was referred to as **autope** prior to October 15, 2021.

**Table of Contents**

1. [Description](#description)
2. [Setup - The basics of getting started with pecdm](#setup)
    * [What pecdm affects](#what-pecdm-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with pecdm](#beginning-with-pecdm)
3. [Usage - Configuration options and additional functionality](#usage)
    * [Adding user specific deployment requirements](#adding-user-specific-deployment-requirements)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

The pecdm Bolt project demonstrates how you can link together automation tools to take advantage of their strengths, e.g. Terraform for infrastructure provisioning and Puppet for infrastructure configuration. We take [puppetlabs/peadm](https://github.com/puppetlabs/puppetlabs-peadm) and a Terraform module ([GCP](https://github.com/puppetlabs/terraform-google-pe_arch), [AWS](https://github.com/puppetlabs/terraform-aws-pe_arch), [Azure](https://github.com/puppetlabs/terraform-azure-pe_arch)) to facilitate rapid and repeatable deployments of Puppet Enterprise built upon the Standard, Large or Extra Large architecture w/ optional fail over replica.

## Expectations and support

The pecdm Bolt project is developed by Puppet's Solutions Architecture team, intended as an internal tool to make the deployment of disposable stacks of Puppet Enterprise easy to deploy for the reproduction of customer issues, internal development, and demonstrations. Independent use is not recommended for production environments but with a comprehensive understanding of how Puppet Enterprise, Puppet Bolt, and Terraform work, plus high levels of comfort with the modification and maintenance of Terraform code and the infrastructure requirements of a full Puppet Enterprise deployment it could be referenced as an example for building your own automated solution.

The pecdm Bolt project is an internal tool, and is **NOT** supported through Puppet Enterprise's standard or premium support.puppet.com service.

If you are a Puppet Enterprise customer and come upon this project and wish to provide feedback, submit a feature request, or bugfix then please do so through the [Issues](https://github.com/puppetlabs/puppetlabs-pecdm/issues) and [Pull Request](https://github.com/puppetlabs/puppetlabs-pecdm/pulls) components of the GitHub project.

The project is under active development and yet to release an initial version. There is no guarantee yet on a stable interface from commit to commit and those commits may include breaking changes.

## Setup

### What pecdm affects

Types of things you'll be paying your cloud provider for

* Instances of various sizes
* Load balancers
* Networks

### Setup Requirements

#### Deploying upon GCP
* [GCP Cloud SDK Intalled](https://cloud.google.com/sdk/docs/quickstarts)
* [GCP Application Default Credentials](https://cloud.google.com/sdk/gcloud/reference/auth/application-default/)

#### Deploying upon AWS
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
* [Environment variables or Shared Credentials file Authentication Method](https://www.terraform.io/docs/providers/aws/index.html#authentication)
* [If using MFA, a script to set environment variables](scripts/aws_bastion_mfa_export.sh)

#### Deploying upon Azure
* [Install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
* [AZ Login](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure)

#### Deploying upon Proxmox VE

* A VM template to clone with qemu-guest-agent and cloud-init, for example from [goodmountain](https://github.com/albatrossflavour/goodmountain). Pass its name as `instance_image`
* DHCP on the VMs' network that registers each VM's name in DNS, so the PE nodes can resolve each other
* An API token exported as `PROXMOX_VE_ENDPOINT` and `PROXMOX_VE_API_TOKEN` (and `PROXMOX_VE_INSECURE=true` for a self-signed certificate)
* `cloud_region` set to a comma-separated list of the Proxmox nodes to place VMs on

#### Common Requirements
* [Bolt Installed](https://puppet.com/docs/bolt/latest/bolt_installing.html)
* [Git Installed](https://git-scm.com/downloads)
* [Terraform Installed](https://developer.hashicorp.com/terraform/install). OpenTofu works if a `terraform` command resolves to `tofu`, because `puppetlabs-terraform` runs `terraform` by name

### Beginning with pecdm

1. Clone this repository: `git clone https://github.com/puppetlabs/puppetlabs-pecdm.git && cd puppetlabs-pecdm`
2. Install module dependencies: `bolt module install`. Every dependency, including the provider Terraform modules, is pinned in `bolt-project.yaml`. The Terraform modules install into `.modules/<provider>_pe_arch`. Cluster state is kept separately in `.terraform/<provider>_pe_arch`, so reinstalling modules never touches it
3. Run plan: `bolt plan run pecdm::provision project=example ssh_user=john.doe firewall_allow='[ "0.0.0.0/0" ]'`
4. Wait. This is best executed from a bastion host or alternatively, a fast connection with strong upload bandwidth

## Usage

**Parameter requirements**

* `lb_ip_mode`: Default is **private**, which will result in load balancer creation that is only accessible from within the VPC where PE is provisioned. To access the load balancer your agents will need to reside within the same VPC as PE or have its VPC peered so private IPs can be routed between PE and the agent's VPC. If you set this parameter to **public** on AWS then the ELB creation will associate a public IP, potentially accessible from the internet. On GCP, setting parameter to **public** will result in PE deployment failure due to GCP not providing DNS entires for internet facing load balancers.

**Windows Native SSH workaround**

Due to bolt being [unable to authenticate with ed25519 keys over SSH transport on Windows](https://puppet.com/docs/bolt/latest/bolt_known_issues.html#unable-to-authenticate-with-ed25519-keys-over-ssh-transport-on-windows) you must utilize the [Native ssh transport](https://puppet.com/docs/bolt/latest/experimental_features.html#native-ssh-transport) when running pecdm from a Windows workstation. This is done automatically on provisioning if your current project directory lacks an inventory.yaml. If you choose to maintain your own inventory.yaml file than add the below configuration example.

```
ssh:
  native-ssh: true
  ssh-command: 'ssh' 
```

### Adding user specific deployment requirements

There are an infinite number of requirements and options for provisioning and deployment to the cloud that each individual has, it is impossible for pecdm or peadm to support them all and they are often not applicable from one user to another so inappropriate to be added to pecdm. To adapt to this need we develop both modules in a way that makes it possible to compose their individual subcomponents into your own specific implementation.

An example repository which illustrates this composability can be found at [ody/example-pe_provisioner](https://github.com/ody/example-pe_provisioner/tree/main/plans). This Bolt Project models a hypothetical Example organization which is provisioning PE on Google Cloud Platform and uses the individual subplans in pecdm sandwiched around some custom code and a [Terraform module](https://github.com/ody/terraform-example-pe_dns) that will create DNS records for each provisioned component in Cloud DNS using a user owned domain.  

**Example: params.json**

The command line will likely serve most uses of **pecdm** but if you wish to pass a longer list of IP blocks that are authorized to access your PE stack than creating a **params.json** file is going to be a good idea, instead of trying to type out a multi value array on the command line. The value that will ultimately be set for the GCP firewall will always include the internal network address space to ensure everything works no matter what is passed in by the user.

```
{
    "project"        : "example",
    "ssh_user"       : "john.doe",
    "version"        : "2019.0.4",
    "provider"       : "google',
    "firewall_allow" : [ "71.236.165.233/32", "131.252.0.0/16", 140.211.0.0/16 ]

}
```

How to execute plan with **params.json**: `bolt plan run pecdm::provision --params @params.json`

### Deploying examples

#### Deploy standard architecture on AWS with the developer role using a MFA enabled user

This can also be used to deploy PE's large architecture without a fail over replica on AWS

```
source scripts/aws_bastion_mfa_export.sh -p development

bolt plan run pecdm provider=aws architecture=standard
```

Please note that for bolt to authenticate to the AWS-provisioned VMs you need to enable ssh agent like so:

```bash
$ eval `ssh-agent`
$ ssh-add
```

For more information about setting environment variables, please take a look at the detailed instructions on the [scripts/README](scripts/README.md) file

#### Deploy large architecture on Proxmox VE

Storage, bridge and VLAN are Proxmox-specific, so they go through `extra_terraform_vars`. See the [provider module](https://github.com/albatrossflavour/terraform-proxmox-pe_arch) for every option.

```bash
bolt plan run pecdm::provision provider=proxmox architecture=large compiler_count=2 \
  cloud_region=pve1,pve2,pve3 instance_image=template-Rocky-9 ssh_pub_key_file=~/.ssh/id_ed25519.pub \
  extra_terraform_vars='{"datastore_id": "ceph", "bridge": "vmbr1", "vlan_id": 6, "full_clone": false}'
```

### Destroying examples

#### Destroy GCP stack

The number of options required are reduced when destroying a stack. Pass the same `cloud_region` used to provision it, or the destroy looks in the default region and fails ([#85](https://github.com/puppetlabs/puppetlabs-pecdm/issues/85))

`bolt plan run pecdm::destroy provider=google cloud_region=<region>`

#### Destroy AWS stack

The number of options required are reduced when destroying a stack. Pass the same `cloud_region` used to provision it, or the destroy looks in the default region and fails ([#85](https://github.com/puppetlabs/puppetlabs-pecdm/issues/85))

`bolt plan run pecdm::destroy provider=aws cloud_region=<region>`

#### Destroy Proxmox VE stack

`bolt plan run pecdm::destroy provider=proxmox cloud_region=<nodes>`

### Upgrading examples

**Upgrade is currently non-functional**

#### Upgrade a AWS stack

`bolt plan run pecdm::upgrade provider=aws ssh_user=centos version=2021.1.0`

## Limitations

Only supports what peadm supports and not all supporting Terraform modules have parity with each other.
