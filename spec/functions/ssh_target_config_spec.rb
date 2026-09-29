require 'spec_helper'

describe 'pecdm::ssh_target_config' do
  base_ssh = {
    'user'           => 'ec2-user',
    'host-key-check' => false,
    'run-as'         => 'root',
  }

  it 'leaves key selection to the SSH config when no key is given' do
    is_expected.to run.with_params('ec2-user', false, nil, nil)
                      .and_return('config' => { 'ssh' => base_ssh })
  end

  it 'derives the private key from the public key path' do
    is_expected.to run.with_params('ec2-user', false, '~/.ssh/igor.pub', nil)
                      .and_return('config' => { 'ssh' => base_ssh.merge('private-key' => '~/.ssh/igor') })
  end

  it 'prefers an explicit private key over the derived one' do
    is_expected.to run.with_params('ec2-user', false, '~/.ssh/igor.pub', '~/.ssh/other')
                      .and_return('config' => { 'ssh' => base_ssh.merge('private-key' => '~/.ssh/other') })
  end

  it 'does not guess a private key when the public key has no .pub suffix' do
    is_expected.to run.with_params('ec2-user', false, '/keys/igor-public', nil)
                      .and_return('config' => { 'ssh' => base_ssh })
  end

  it 'adds native SSH settings when asked' do
    is_expected.to run.with_params('ec2-user', true, '~/.ssh/igor.pub', nil)
                      .and_return('config' => { 'ssh' => base_ssh.merge(
                        'private-key' => '~/.ssh/igor',
                        'native-ssh'  => true,
                        'ssh-command' => 'ssh',
                      ) })
  end
end
