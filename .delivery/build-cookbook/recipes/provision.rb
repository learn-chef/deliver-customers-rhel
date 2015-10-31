#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
include_recipe 'delivery-truck::provision'
include_recipe 'chef-sugar'

load_delivery_chef_config

# Decrypt the encryption key that decrypts the database passwords and save that file to disk.
database_passwords_key = encrypted_data_bag_item_for_environment('provisioning-data', 'database_passwords_key')
database_passwords_key_path = File.join(node['delivery']['workspace']['cache'], node['delivery']['change']['project'])
directory database_passwords_key_path
file File.join(database_passwords_key_path, 'database_passwords_key') do
  sensitive true
  content database_passwords_key['content']
  owner node['delivery_builder']['build_user']
  group node['delivery_builder']['build_user']
  mode '0664'
end

# Decrypt the SSH private key Chef provisioning uses to connect to the machine and save the key to disk.
ssh_key = encrypted_data_bag_item_for_environment('provisioning-data', 'ssh_key')
ssh_private_key_path = File.join(node['delivery']['workspace']['cache'], '.ssh')
directory ssh_private_key_path
file File.join(ssh_private_key_path, "#{ssh_key['name']}.pem")  do
  sensitive true
  content ssh_key['private_key']
  owner node['delivery_builder']['build_user']
  group node['delivery_builder']['build_user']
  mode '0600'
end

# Read common configuration options from node attributes.
project = node['delivery']['change']['project'] # for example, 'deliver-customers-rhel'
stage = node['delivery']['change']['stage'] # for example, 'acceptance' or 'union'

# Load AWS credentials.
include_recipe "#{cookbook_name}::_aws_creds"

# Load the AWS driver.
require 'chef/provisioning/aws_driver'
# Set the AWS driver as the current one.
with_driver 'aws'

# Specify information about our Chef server.
# Chef provisioning uses this information to bootstrap the machine.
with_chef_server Chef::Config[:chef_server_url],
  client_name: Chef::Config[:node_name],
  signing_key_filename: Chef::Config[:client_key],
  ssl_verify_mode: :verify_none,
  verify_api_cert: false

# Ensure that the machine exists, is bootstrapped, has the correct run-list, and is ready to run chef-client.
machine_name = "#{stage}-#{project}"
machine machine_name do
  action [:setup]
  chef_environment delivery_environment
  converge false
  files '/etc/chef/encrypted_data_bag_secret' => File.join(database_passwords_key_path, 'database_passwords_key')
  run_list node[project]['run_list']
  add_machine_options bootstrap_options: {
    key_name: ssh_key['name'],
    key_path: ssh_private_key_path,
  }
  add_machine_options node[project][stage]['aws']['config']['machine_options']
end
