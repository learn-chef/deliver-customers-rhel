#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
include_recipe 'delivery-truck::deploy'
include_recipe 'chef-sugar'

load_delivery_chef_config

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

# Create a search query that matches the current environment.
search_query = "chef_environment:#{delivery_environment}"

# Run the query.
nodes = delivery_chef_server_search(:node, search_query)

# Replace each result with just the node's name.
nodes.map!(&:name)

# Run chef-client on each machine in the current environment.
nodes.each do |name|
  machine name do
    action [:converge_only]
    chef_environment delivery_environment
    converge true
    run_list node[project]['run_list']
    add_machine_options bootstrap_options: {
      key_name: ssh_key['name'],
      key_path: ssh_private_key_path,
    }
    add_machine_options node[project][stage]['aws']['config']['machine_options']
  end
end
