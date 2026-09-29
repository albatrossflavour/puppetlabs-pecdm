# @summary Destroy a pecdm provisioned Puppet Enterprise cluster
#
# @param provider
#   Which cloud provider that infrastructure will be provisioned into
#
# @param cloud_region
#   Which region to provision infrastructure in, if not provided default will
#   be determined by provider
#
plan pecdm::subplans::destroy(
  Enum['google', 'aws', 'azure', 'proxmox']  $provider,
  Optional[String[1]]             $cloud_region = undef
) {
  out::message("Destroying Puppet Enterprise deployment on ${provider}")

  $tf = pecdm::terraform_dirs($provider)
  $tf_dir = $tf['code_dir']

  # Initialise ahead of a destroy. Always run init rather than
  # terraform::initialize, which skips any directory that already has a
  # .terraform and so misses submodules and providers added by a new module pin
  run_command("cd '${tf_dir}' && terraform init -input=false -no-color", 'localhost')

  # file::exists and file::read treat a relative path as a module path
  $vars_file = file::join(system::env('PWD'), $tf['vars_file'])
  $saved_tfvars = file::exists($vars_file) ? {
    true  => file::read($vars_file),
    false => undef,
  }

  if $provider == 'proxmox' and !$saved_tfvars and !$cloud_region {
    fail_plan('The Proxmox provider needs cloud_region set to a comma-separated list of Proxmox node names, for example cloud_region=pve1,pve2')
  }
  $_cloud_region = ($saved_tfvars or $cloud_region) ? {
    true    => $cloud_region,
    default => $provider ? { 'azure' => 'westus2', 'aws' => 'us-west-2', default => 'us-west1' },
  }
  $tfvars = pecdm::destroy_tfvars($provider, $_cloud_region, $saved_tfvars)

  pecdm::with_tempfile_containing('', $tfvars, '.tfvars') |$tfvars_file| {
    # Stands up our cloud infrastructure that we'll install PE onto, returning a
    # specific set of data via TF outputs that if replicated will make this plan
    # easily adaptable for use with multiple cloud providers
    run_plan('terraform::destroy',
      dir           => $tf_dir,
      state         => $tf['state'],
      var_file      => $tfvars_file
    )
  }

  out::message('Puppet Enterprise deployment successfully destroyed')
}
