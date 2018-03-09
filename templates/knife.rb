current_dir = File.dirname(__FILE__)
log_level                 :info
log_location              STDOUT
node_name                 "chefadmin"
client_key                "#{current_dir}/chefadmin.pem"
chef_server_url           "https://chefserver.vagrant.local/organizations/4thcoffee"
cookbook_path             ["#{current_dir}/../cookbooks"]
