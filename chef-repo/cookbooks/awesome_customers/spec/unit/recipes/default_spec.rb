#
# Cookbook Name:: awesome_customers
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'awesome_customers::default' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      # The selinux cookbook raises this error.
      expect { chef_run }.to raise_error(RuntimeError, 'chefspec not supported!')
    end
  end
end
