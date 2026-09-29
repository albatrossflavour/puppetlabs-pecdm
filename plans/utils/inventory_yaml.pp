# @summary Write to current working directory a provider specific inventory.yaml
#
# @param provider
#   Which cloud provider that infrastructure will be provisioned into
#
# @param ssh_ip_mode
#   The type of IPv4 address that will be used to gain SSH access to instances
#
# @param native_ssh
#   Set this to true if the plan should write an inventory which uses native SSH
#   instead of Ruby's net-ssh library
#
# @param ssh_config
#   The SSH settings provisioning connected with, so later Bolt runs use the
#   same user and key. Empty falls back to the old defaults, which set no user
#
plan pecdm::utils::inventory_yaml(
  Enum['google', 'aws', 'azure', 'proxmox'] $provider,
  Enum['private', 'public']      $ssh_ip_mode,
  Boolean                        $native_ssh = false,
  Hash                           $ssh_config = {},
) {
  $_ssh_config = $ssh_config.empty ? {
    true  => {
      'host-key-check' => false,
      'run-as'         => 'root',
    } + ($native_ssh ? {
        true  => { 'native-ssh' => true, 'ssh-command' => 'ssh' },
        false => {},
    }),
    false => $ssh_config,
  }

  out::message("Writing inventory.yaml for ${provider}")

  file::write('inventory.yaml', epp('pecdm/inventory_yaml.epp', {
        provider    => $provider,
        ssh_ip_mode => $ssh_ip_mode,
        ssh_config  => $_ssh_config,
  }))
}
