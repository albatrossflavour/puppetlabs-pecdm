require 'spec_helper'

describe 'pecdm::redact' do
  it 'hides values whose keys name a secret' do
    is_expected.to run.with_params(
      'console_password'         => 'hunter2hunter2!',
      'r10k_private_key_content' => "-----BEGIN OPENSSH PRIVATE KEY-----\n",
      'license_key_content'      => 'abc',
      'windows_password'         => 'x',
      'primary_host'             => 'primary-1.example.com',
    ).and_return(
      'console_password'         => '[redacted]',
      'r10k_private_key_content' => '[redacted]',
      'license_key_content'      => '[redacted]',
      'windows_password'         => '[redacted]',
      'primary_host'             => 'primary-1.example.com',
    )
  end

  it 'redacts inside nested hashes and arrays' do
    is_expected.to run.with_params(
      'hosts' => [{ 'name' => 'a', 'api_token' => 't' }],
      'known_hosts' => [{ 'name' => 'github.com', 'key' => 'AAAA' }],
    ).and_return(
      'hosts' => [{ 'name' => 'a', 'api_token' => '[redacted]' }],
      'known_hosts' => [{ 'name' => 'github.com', 'key' => 'AAAA' }],
    )
  end

  it 'redacts assignments in tfvars text' do
    is_expected.to run.with_params(%(project = "pecdm"\nwindows_password = "s3cret"\n))
                      .and_return(%(project = "pecdm"\nwindows_password = "[redacted]"\n))
  end
end
