#
# Cookbook Name:: build-cookbook
# Recipe:: _aws_creds
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
with_server_config do
  # Read common configuration options from node attributes so that we can later access them more easily.
  project = node['delivery']['change']['project'] # for example, 'deliver-customers-rhel'
  stage = node['delivery']['change']['stage'] # for example, 'acceptance' or 'union'
  driver = node[project][stage]['driver'] # for example, 'aws' or 'ssh'
  region = node[project][stage][driver]['config']['region'] # for example, 'us-west-2'
  profile = node[project][stage][driver]['config']['profile'] # for example, 'default'

  # Decrypt the AWS credentials from the data bag.
  aws_creds = encrypted_data_bag_item_for_environment('provisioning-data', 'aws_creds')

  # Create a string to hold the contents of the credentials file.
  aws_config_contents = <<-EOF
  [#{profile}]
  region = #{region}
  aws_access_key_id = #{aws_creds['access_key_id']}
  aws_secret_access_key = #{aws_creds['secret_access_key']}
  EOF

  # Compute the path to the credentials file.
  aws_config_filename = File.join(node['delivery']['workspace']['cache'], node['delivery']['change']['project'], 'aws_config')

  # Write the AWS credentials to disk.
  # Alternatively, you can use the template resource.
  file aws_config_filename do
    sensitive true
    content aws_config_contents
  end

  # Set the AWS_CONFIG_FILE environment variable.
  # Chef provisioning reads this environment variable to access the AWS credentials file.
  ENV['AWS_CONFIG_FILE'] = aws_config_filename
end
