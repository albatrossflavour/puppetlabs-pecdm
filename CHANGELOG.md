# Changelog

All notable changes to this project will be documented in this file.

## Release 0.3.0

**Features**

- Default PE version is now 2025.11.3 for provision, deploy and upgrade (was 2019.8.10 and 2021.7.2)
- Supports Bolt 4 and 5, via peadm 3.38.3 ([#117](https://github.com/puppetlabs/puppetlabs-pecdm/issues/117))

**Changes**

- All dependencies are pinned in `bolt-project.yaml` and installed with `bolt module install`. The hand-written Puppetfile is gone, along with three modules pecdm never used (`bolt_shim`, which is deprecated, `apply_helpers` and `WhatsARanjit-node_manager`)
- Provider Terraform modules install into `.modules/<provider>_pe_arch`. Terraform runs there with state passed explicitly, and state stays in `.terraform/<provider>_pe_arch`, so existing clusters keep their state and a module reinstall can't delete it
- `pecdm::upgrade` provider detection no longer fails for providers that have never been deployed

**Bugfixes**

- README destroy examples pass `cloud_region` ([#85](https://github.com/puppetlabs/puppetlabs-pecdm/issues/85), [#118](https://github.com/puppetlabs/puppetlabs-pecdm/pull/118))

## Release 0.1.0

**Features**

**Bugfixes**

**Known Issues**
