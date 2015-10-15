#
# Cookbook Name:: awesome_customers
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'awesome_customers::webserver' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    let(:secret_path) { '/etc/chef/encrypted_data_bag_secret' }
    let(:secret) { 'secret' }
    let(:user_password_data_bag_item) do
      { password: 'fake_password' }
    end

    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(secret_path).and_return('true')

      allow(IO).to receive(:read).and_call_original
      allow(IO).to receive(:read).with(secret_path).and_return(secret)

      allow(Chef::EncryptedDataBagItem).to receive(:load).with('passwords', 'db_admin_password', secret).and_return(user_password_data_bag_item)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it "creates httpd_service['customers']" do
      expect(chef_run).to create_httpd_service('customers')
        .with(
            mpm: 'prefork'
          )
    end

    it "creates httpd_config['customers']" do
      expect(chef_run).to create_httpd_config 'customers'
    end

    it "creates directory['/var/www/customers/public_html']" do
      expect(chef_run).to create_directory('/var/www/customers/public_html')
        .with(
          recursive: true
        )
    end

    it "creates template['/var/www/customers/public_html/index.php']" do
      expect(chef_run).to create_template('/var/www/customers/public_html/index.php')
        .with(
          mode: '0644',
          owner: 'web_admin',
          group: 'web_admin',
          variables: {
            database_password: user_password_data_bag_item['password']
          }
        )
    end

    it "installs httpd_module['php']" do
      expect(chef_run).to create_httpd_module('php')
    end

    it "installs package['php-mysql']" do
      expect(chef_run).to install_package('php-mysql')
    end
  end
end
