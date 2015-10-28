#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
include_recipe 'delivery-truck::provision'
include_recipe 'chef-sugar::default'

Chef_Delivery::ClientHelper.enter_client_mode_as_delivery

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

# Read common configuration options from node attributes so that we can later access them more easily.
project = node['delivery']['change']['project'] # for example, 'deliver-customers-rhel'
stage = node['delivery']['change']['stage'] # for example, 'acceptance' or 'union'
driver = node[project][stage]['driver'] # for example, 'aws' or 'ssh'
region = node[project][stage][driver]['config']['region'] # for example, 'us-west-2'
profile = node[project][stage][driver]['config']['profile'] # for example, 'default'

# Perform driver-specific initialization, such as loading the appropriate library.
# For learning purposes, we'll do that directly in this recipe.
# In practice, you might abstract this into a helper library.
case driver
when 'aws'
  # Load the AWS driver.
  require "chef/provisioning/aws_driver"
  # Load AWS credentials.
  include_recipe "#{cookbook_name}::_aws_creds"
  # Set the AWS driver as the current one.
  with_driver "aws::#{region}::#{profile}"
  # Use the driver-specific method for specifying the SSH private key.
  with_machine_options(
    bootstrap_options: {
      key_name: ssh_key['name'],
      key_path: ssh_private_key_path,
    }
  )
when 'ssh'
  # chef-provisioning-ssh does not come with the Chef DK, so we need to install it manually.
  # For learning purposes, we'll install it if it's not already installed.
  # In practice, you might pin it to a specific version and upgrade it periodically.
  execute 'install the chef-provisioning-ssh gem' do
    cwd node['delivery_builder']['repo']
    command 'chef gem install chef-provisioning-ssh'
    not_if "chef gem list chef-provisioning-ssh | grep 'chef-provisioning-ssh'"
    user node['delivery_builder']['build_user']
  end
  # Load the SSH driver.
  require "chef/provisioning/ssh_driver"
  # Set the SSH driver as the current one.
  with_driver 'ssh'
  # Use the driver-specific method for specifying the SSH private key.
  with_machine_options(
    transport_options: {
      ssh_options: {
        keys: [File.join(ssh_private_key_path, "#{ssh_key['name']}.pem")]
      }
    }
  )
end

# Specify information about our Chef server.
# Chef provisioning uses this information to bootstrap the machine.
with_chef_server Chef::Config[:chef_server_url],
  client_name: Chef::Config[:node_name],
  signing_key_filename: Chef::Config[:client_key],
  ssl_verify_mode: :verify_none,
  verify_api_cert: false

# Ensure that the machine is bootstrapped, has the correct run-list, and is ready to run chef-client.
# If you're using the AWS driver, this will create the instance if the instance does not exist.
machine_name = "#{stage}-#{project}-#{driver}"
machine machine_name do
  action [:setup]
  chef_environment delivery_environment
  converge false
  files '/etc/chef/encrypted_data_bag_secret' => File.join(database_passwords_key_path, 'database_passwords_key')
  run_list node[project]['run_list']
  add_machine_options node[project][stage][driver]['config']['machine_options']
end
