default['deliver-customers-rhel']['run_list'] = ['recipe[awesome_customers::default]']

%w(acceptance union rehearsal delivered).each do |stage|
  default['deliver-customers-rhel'][stage]['aws']['config'] = {
    machine_options: {
      bootstrap_options: {
        instance_type: 't2.micro',
        security_group_ids: ['sg-cbacf8ae'],
        subnet_id: 'subnet-19ac017c'
      },
      convergence_options: {
        ssl_verify_mode: :verify_none
      },
      image_id: 'ami-09f7d239',
      ssh_username: 'root',
      transport_address_location: :private_ip
    }
  }
end
