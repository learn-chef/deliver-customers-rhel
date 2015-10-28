default['delivery']['config']['delivery-truck']['publish']['chef_server'] = true

default['deliver-customers-rhel']['run_list'] = ['recipe[awesome_customers::default]']

%w(acceptance union rehearsal delivered).each do |stage|
  default['deliver-customers-rhel'][stage]['driver'] = 'aws'
end

%w(acceptance union rehearsal delivered).each do |stage|
  default['deliver-customers-rhel'][stage]['aws']['config'] = {
    region: 'us-west-2',
    profile: 'default',
    machine_options: {
      admin: nil,
      bootstrap_options: {
        instance_type: 't2.micro',
        security_group_ids: ['sg-cbacf8ae'],
        subnet_id: 'subnet-19ac017c',
        output_key_path: nil,
        output_key_format: nil
      },
      convergence_options: {
        ssl_verify_mode: :verify_none
      },
      image_id: 'ami-09f7d239',
      ssh_username: 'root',
      transport_address_location: :private_ip,
      validator: nil
    }
  }
end

default['deliver-customers-rhel']['acceptance']['ssh']['config'] = {
  machine_options: {
    transport_options: {
      ip_address: '52.27.142.7',
      username: 'root',
      ssh_options: {
        user: 'root'
      },
      options: {
        prefix: 'sudo '
      }
    }
  }
}

default['deliver-customers-rhel']['union']['ssh']['config'] = {
  machine_options: {
    transport_options: {
      ip_address: '52.89.111.13',
      username: 'root',
      ssh_options: {
        user: 'root'
      },
      options: {
        prefix: 'sudo '
      }
    }
  }
}

default['deliver-customers-rhel']['rehearsal']['ssh']['config'] = {
  machine_options: {
    transport_options: {
      ip_address: '52.88.245.86',
      username: 'root',
      ssh_options: {
        user: 'root'
      },
      options: {
        prefix: 'sudo '
      }
    }
  }
}

default['deliver-customers-rhel']['delivered']['ssh']['config'] = {
  machine_options: {
    transport_options: {
      ip_address: '54.69.73.21',
      username: 'root',
      ssh_options: {
        user: 'root'
      },
      options: {
        prefix: 'sudo '
      }
    }
  }
}
