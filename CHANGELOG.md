# Changelog

All notable changes to this project will be documented in this file.

## Release 0.3.0

**Features**

- Proxmox VE provider (`provider=proxmox`), using the new [terraform-proxmox-pe_arch](https://github.com/albatrossflavour/terraform-proxmox-pe_arch) module. VMs use DHCP and pecdm connects to the address the guest agent reports. `cloud_region` is required and lists the Proxmox nodes to use
- Proxmox deployments wait until every node resolves every other node to its real address before installing PE (`dns_wait_timeout`, default 1800 seconds, 0 to skip)
- Default PE version is now 2025.11.3 for provision, deploy and upgrade (was 2019.8.10 and 2021.7.2)
- Supports Bolt 4 and 5, via peadm 3.38.3 ([#117](https://github.com/puppetlabs/puppetlabs-pecdm/issues/117))

**Changes**

- The provider Terraform modules now come from the albatrossflavour forks, upgraded to current providers: google 8.4.0 (from 3.68.0), aws 6.66.0 (from 5.20.1) and azurerm 5.7.0 (from 2.64.0), with hiera5 0.5.4 and random 3.9.1. See each module's CHANGELOG for the breaking changes handled and what is unverified without a cloud deploy
- All dependencies are pinned in `bolt-project.yaml` and installed with `bolt module install`. The hand-written Puppetfile is gone, along with three modules pecdm never used (`bolt_shim`, which is deprecated, `apply_helpers` and `WhatsARanjit-node_manager`)
- Provider Terraform modules install into `.modules/<provider>_pe_arch`. Terraform runs there with state passed explicitly, and state stays in `.terraform/<provider>_pe_arch`, so existing clusters keep their state and a module reinstall can't delete it
- `pecdm::upgrade` provider detection no longer fails for providers that have never been deployed
- AWS module pinned at `83abe81`, so a newer AMI no longer replaces running nodes. `75f0fca` added outputs describing the deployment's network, DNS zones and key pair, for layers built beside it. `1e454f7` added `operator_ports` (set it through `extra_terraform_vars`) to choose which ports `firewall_allow` can reach. Before that, `63ce19e` brought role-named certnames and split-horizon Route 53 DNS when `domain_name` is set (pass it, and optionally `public_zone_id`, through `extra_terraform_vars`), a security group that opens only operator ports to `firewall_allow`, encrypted `gp3` root volumes and IMDSv2. See the module's CHANGELOG

**Bugfixes**

- `--verbose` no longer prints secrets. The `peadm::install` parameters (console password, `r10k_private_key_content`, `license_key_content` from `extra_peadm_params`) and the tfvars (`windows_password`) go through the new `pecdm::redact` first
- SSH to nodes no longer forces a TTY. A TTY merges stderr into stdout, and peadm 3.38 reads stderr to tell whether PE predates CA database storage, so installs failed with "Could not confirm ... predates the CA database storage feature"
- `console_password` is checked against PE 2025's default complexity rules (12+ characters, upper and lower case, a number and a special character) before anything is built. PE only enforces them at the very end of the install
- Bolt now connects to nodes with the private key matching `ssh_pub_key_file` (the same path without `.pub`), or `ssh_private_key_file` if given. It previously set no key, so net-ssh took whatever `~/.ssh/config` said: a catch-all `IdentityFile` with `IdentitiesOnly yes` left it offering a key the nodes had never seen. `pecdm::upgrade` takes `ssh_private_key_file` too
- AWS nodes are named from the module's `internalDNS` tag, as on Azure, rather than `private_dns`. The tag is `private_dns` unless `domain_name` is set, so only domain deployments change: they now get their `<role>.<domain_name>` certnames, where before the tag was ignored. The saved inventory named AWS agents by `public_dns` and now uses the tag too. The closing console message shows the provider's `console` output, a name for domain deployments
- Provision and destroy run `terraform init` every time. They used `terraform::initialize`, which skips any directory that already has a `.terraform`, so after a module pin that added a submodule the apply failed with "Module not installed"
- The `inventory.yaml` written after provisioning now carries the SSH user and private key provisioning connected with. It had neither, so every later `bolt` run against it tried the operator's local username and failed to authenticate
- `pecdm::destroy` now plans with the variables the cluster was built with, which provision saves to `.terraform/<provider>_pe_arch/pecdm.tfvars` (directory mode 0700). It used placeholders, so on AWS it failed reading the default `~/.ssh/id_rsa.pub`, and a missing `cloud_region` fell back to `us-west-2` whatever region the cluster was in. A `cloud_region` that contradicts the saved one is refused. Clusters built before this change still get the placeholders
- `extra_terraform_vars` only handled flat values: a nested map failed to render, lists relied on a quote-swapping regex, and booleans were written as strings. Every value is now written as a JSON literal, which HCL accepts at any depth
- Windows images on Azure were written to the Linux `instance_image` key, so every VM got the Windows image. A string `windows_instance_image` also rendered empty
- README destroy examples pass `cloud_region` ([#85](https://github.com/puppetlabs/puppetlabs-pecdm/issues/85), [#118](https://github.com/puppetlabs/puppetlabs-pecdm/pull/118))

## Release 0.1.0

**Features**

**Bugfixes**

**Known Issues**
