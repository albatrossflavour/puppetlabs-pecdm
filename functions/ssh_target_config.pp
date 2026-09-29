# Bolt target config for SSH access to provisioned Linux nodes.
#
# The private key is set explicitly so Bolt uses the key Terraform installed on
# the nodes. Without it, net-ssh falls back to the operator's ~/.ssh/config,
# where a catch-all IdentityFile with IdentitiesOnly can lock out every other
# key.
#
# @param ssh_user
#   User to connect as, escalating to root
# @param native_ssh
#   Use the ssh binary instead of Ruby's net-ssh library
# @param ssh_pub_key_file
#   Public key given to Terraform. When it ends in .pub, the private key is
#   assumed to sit beside it without the suffix
# @param ssh_private_key_file
#   Private key to use, overriding the one derived from ssh_pub_key_file
function pecdm::ssh_target_config(
  String[1]           $ssh_user,
  Boolean             $native_ssh,
  Optional[String[1]] $ssh_pub_key_file     = undef,
  Optional[String[1]] $ssh_private_key_file = undef,
) >> Hash {
  $private_key = $ssh_private_key_file ? {
    undef   => $ssh_pub_key_file ? {
      /\.pub$/ => $ssh_pub_key_file.regsubst(/\.pub$/, ''),
      default  => undef,
    },
    default => $ssh_private_key_file,
  }

  $ssh = {
    'user'           => $ssh_user,
    'host-key-check' => false,
    'run-as'         => 'root',
    # No TTY: it merges stderr into stdout, and peadm checks stderr (for
    # example to detect a PE version without CA database storage)
  } + ($private_key ? {
      undef   => {},
      default => { 'private-key' => $private_key },
  }) + ($native_ssh ? {
      true  => { 'native-ssh' => true, 'ssh-command' => 'ssh' },
      false => {},
  })

  $target_config = { 'config' => { 'ssh' => $ssh } }
  $target_config
}
