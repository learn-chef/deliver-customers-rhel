#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
include_recipe 'delivery-truck::publish'

with_server_config do
  execute 'create passwords data bag' do
    cwd node['delivery']['workspace']['repo']
    command "knife data bag create passwords --config #{delivery_knife_rb}"
    not_if "knife data bag list --config #{delivery_knife_rb} | grep '^passwords$'"
  end
  %w(db_admin_password sql_server_root_password).each do |data_bag_item|
    execute "create #{data_bag_item} data bag item" do
      cwd node['delivery']['workspace']['repo']
      command "knife data bag from file passwords #{data_bag_item}.json --config #{delivery_knife_rb}"
    end
  end
end
