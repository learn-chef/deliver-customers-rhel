#
# Cookbook Name:: awesome_customers
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'awesome_customers::database' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    let(:secret_path) { '/etc/chef/encrypted_data_bag_secret' }
    let(:secret) { 'secret' }
    let(:admin_password_data_bag_item) do
      { password: 'fake_admin_password' }
    end
    let(:server_password_data_bag_item) do
      { password: 'fake_server_password' }
    end

    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(secret_path).and_return('true')

      allow(IO).to receive(:read).and_call_original
      allow(IO).to receive(:read).with(secret_path).and_return(secret)

      allow(Chef::EncryptedDataBagItem).to receive(:load).with('passwords', 'db_admin_password', secret).and_return(admin_password_data_bag_item)
      allow(Chef::EncryptedDataBagItem).to receive(:load).with('passwords', 'sql_server_root_password', secret).and_return(server_password_data_bag_item)

      stub_command("mysql -h 127.0.0.1 -u db_admin -p -D products -e 'describe customers;'").and_return(0)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
