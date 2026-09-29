require 'spec_helper'

describe 'pecdm::destroy_tfvars' do
  saved = <<~TFVARS
    project         = "pecdm"
    user            = "ec2-user"
    ssh_key         = "~/.ssh/igor.pub"
    region          = "ap-southeast-2"
  TFVARS

  it 'reuses the variables the build was made with' do
    is_expected.to run.with_params('aws', nil, saved).and_return(saved)
  end

  it 'accepts a cloud_region that matches the build' do
    is_expected.to run.with_params('aws', 'ap-southeast-2', saved).and_return(saved)
  end

  it 'refuses a cloud_region that differs from the build' do
    is_expected.to run.with_params('aws', 'us-west-2', saved)
                      .and_raise_error(%r{built in ap-southeast-2, not us-west-2})
  end

  it 'adds destroy = true for providers that need it' do
    is_expected.to run.with_params('google', nil, saved).and_return("#{saved}destroy = true\n")
  end

  it 'falls back to placeholder variables when nothing was saved' do
    is_expected.to run.with_params('aws', 'us-west-2', nil)
                      .and_return(%r{\Aregion += "us-west-2"\n(?!destroy).*project += "oppenheimer"}m)
  end

  it 'falls back with destroy = true for providers that need it' do
    is_expected.to run.with_params('proxmox', 'pve1', nil).and_return(%r{destroy += true})
  end
end
