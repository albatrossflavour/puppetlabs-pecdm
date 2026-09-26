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

**Bugfixes**

- `extra_terraform_vars` only handled flat values: a nested map failed to render, lists relied on a quote-swapping regex, and booleans were written as strings. Every value is now written as a JSON literal, which HCL accepts at any depth
- Windows images on Azure were written to the Linux `instance_image` key, so every VM got the Windows image. A string `windows_instance_image` also rendered empty
- README destroy examples pass `cloud_region` ([#85](https://github.com/puppetlabs/puppetlabs-pecdm/issues/85), [#118](https://github.com/puppetlabs/puppetlabs-pecdm/pull/118))

## Release 0.1.0

**Features**

**Bugfixes**

**Known Issues**
