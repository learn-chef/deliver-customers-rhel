default['awesome_customers']['user'] = 'web_admin'
default['awesome_customers']['group'] = 'web_admin'

default['awesome_customers']['document_root'] = '/var/www/customers/public_html'

default['awesome_customers']['enabled_firewall_rules'] = %w(firewall_http firewall_sshd)

default['awesome_customers']['passwords']['secret_path'] = '/etc/chef/encrypted_data_bag_secret'

default['awesome_customers']['database']['dbname'] = 'products'
default['awesome_customers']['database']['host'] = '127.0.0.1'
default['awesome_customers']['database']['username'] = 'root'

default['awesome_customers']['database']['app']['username'] = 'db_admin'

default['awesome_customers']['database']['seed_file'] ='/tmp/create-tables.sql'
