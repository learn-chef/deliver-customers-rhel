#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
include_recipe 'delivery-truck::provision'
include_recipe 'chef-sugar::default'

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

# Read common configuration options from node attributes.
project = node['delivery']['change']['project'] # for example, 'deliver-customers-rhel'
stage = node['delivery']['change']['stage'] # for example, 'acceptance' or 'union'

# Load AWS credentials.
include_recipe "#{cookbook_name}::_aws_creds"
