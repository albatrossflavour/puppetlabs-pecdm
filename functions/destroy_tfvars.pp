# @summary The Terraform variables pecdm::destroy runs with
#
# Terraform evaluates the whole configuration on destroy, so the variables have
# to be ones it can plan with. The ones saved at provision time are the only
# reliable source: the region is the one the resources are really in, and every
# file the module reads (such as ssh_key) is one that existed at build time.
# Clusters built before pecdm saved them fall back to placeholders.
#
# @param provider
#   The cloud provider being destroyed
# @param cloud_region
#   Region asked for on the command line, if any
# @param saved_tfvars
#   Contents of the tfvars file saved at provision time, if there is one
#
# @return [String] tfvars file contents
function pecdm::destroy_tfvars(
  String[1]           $provider,
  Optional[String[1]] $cloud_region,
  Optional[String]    $saved_tfvars,
) >> String {
  $destroy_line = $provider ? {
    /^(google|proxmox)$/ => "destroy = true\n",
    default              => '',
  }

  if $saved_tfvars {
    $built_region = $saved_tfvars.match(/(?m)^region\s*=\s*"([^"]*)"/)
    if $cloud_region and $built_region and $built_region[1] != $cloud_region {
      fail("This cluster was built in ${built_region[1]}, not ${cloud_region}. Leave cloud_region unset to destroy it where it was built")
    }
    $tfvars = "${saved_tfvars}${destroy_line}"
  } else {
    $region_line = $cloud_region ? {
      undef   => '',
      default => "region = \"${cloud_region}\"\n",
    }
    $placeholders = @("TFVARS")
      project          = "oppenheimer"
      user             = "oppenheimer"
      windows_user     = "oppenheimer"
      windows_password = "oppenheimer"
      | TFVARS
    $tfvars = "${region_line}${destroy_line}${placeholders}"
  }
  $tfvars
}
