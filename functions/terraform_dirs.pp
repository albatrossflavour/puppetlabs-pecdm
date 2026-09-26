# @summary Where a provider's Terraform code runs and where its state lives
#
# The provider module is installed by `bolt module install` into .modules, which
# Bolt is free to wipe and reinstall. State must survive that, so it stays in
# .terraform/<provider>_pe_arch, which is where pecdm has always kept it. The
# state path is relative to the code directory because the terraform tasks
# expand it against `dir`.
#
# @param provider
#   The cloud provider being deployed to
#
# @return [Hash] code_dir, state_dir and state (relative to code_dir)
function pecdm::terraform_dirs(String[1] $provider) >> Hash {
  {
    'code_dir'  => ".modules/${provider}_pe_arch",
    'state_dir' => ".terraform/${provider}_pe_arch",
    'state'     => "../../.terraform/${provider}_pe_arch/terraform.tfstate",
  }
}
