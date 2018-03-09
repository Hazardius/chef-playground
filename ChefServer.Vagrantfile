# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define :chef_server do |v|
    # Every Vagrant development environment requires a box. You can search for
    # boxes at https://vagrantcloud.com/search.
    v.vm.box = "ubuntu/xenial64"

    v.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
    end
    v.vm.network "private_network", ip: "192.168.42.10"
    v.vm.host_name = "chefserver.vagrant.local"

    chef_server_package_name = "chef-server-core_12.16.2-1_amd64.deb"
    chef_server_package_url  = "https://packages.chef.io/files/stable/chef-server/12.16.2/ubuntu/16.04/#{chef_server_package_name}"

    v.vm.provision "shell", inline: <<-SHELL
      apt-get -y update
      apt-get -y install curl
      apt-get -y install vim
      if [ ! -d /drop ]; then
        mkdir /drop
      fi
      if [ ! -d /downloads ]; then
        mkdir /downloads
      fi
      if [ ! -f /downloads/chef-server-core_12.16.2_amd64.deb ]; then
        echo "Downloading the Chef server package..."
        wget -nv -P /downloads #{chef_server_package_url}
      fi

      if [ ! $(which chef-server-ctl) ]; then
        echo "Installing Chef server..."
        dpkg -i /downloads/#{chef_server_package_name}
        chef-server-ctl reconfigure

        echo "Waiting for services..."
        until (curl -D - http://localhost:8000/_status) | grep "200 OK"; do sleep 15s; done
        while (curl http://localhost:8000/_status) | grep "fail"; do sleep 15s; done

        echo "Creating initial user and organization..."
        chef-server-ctl user-create chefadmin Chef Admin admin@4thcoffee.com insecurepassword --filename /drop/chefadmin.pem
        chef-server-ctl org-create 4thcoffee "Fourth Coffee, Inc." --association_user chefadmin --filename 4thcoffee-validator.pem
      fi

      echo "Your Chef server is ready!"
    SHELL

    # Then we need to:
    # - input our public key into the ~/.ssh/authorized_keys
    # - scp vagrant@chefserver.vagrant.local:4thcoffee-validator.pem learn-chef/.chef/.
    # - scp vagrant@chefserver.vagrant.local:/drop/chefadmin.pem learn-chef/.chef/.
    # - cp templates/knife.rb learn-chef/.chef/.
    # - cd learn-chef/
    # - knife ssl fetch
    # - knife ssl check
    # - Add to /etc/hosts
    #   sudo vim /etc/hosts
    #   192.168.42.11   chefclient.vagrant.local        chefclient
  end

  config.vm.define :chef_client do |v|
    # Every Vagrant development environment requires a box. You can search for
    # boxes at https://vagrantcloud.com/search.
    v.vm.box = "bento/centos-7"

    v.vm.network "private_network", ip: "192.168.42.11"
    v.vm.host_name = "chefclient.vagrant.local"

    # - Add to /etc/hosts
    #   sudo vim /etc/hosts
    #   192.168.42.10   chefserver.vagrant.local        chefserver
    # - Bootstrap vm as a node:
    #   knife bootstrap 192.168.42.11 --ssh-port 22 --ssh-user vagrant --sudo --node-name node1-centos --run-list 'recipe[learn_chef_httpd]'
    # - Run chef-local to update:
    #   knife ssh 192.168.42.11 --ssh-port 22 'sudo chef-client' --ssh-user vagrant --manual-list
    # - Run chef-local to update after role was assigned doesn't work with this setup because of two IP addresses assigned to the client vm..
    # - Check status on node:
    #   knife status 'role:web' --run-list
  end

  # Upload changes to the chef server:
  #   knife cookbook upload learn_chef_httpd
  # Add new role(web) and give that role to node1-centos(chefclient)
  #   knife role from file roles/web.json
  #   knife role list
  #   knife role show web
  #   knife node run_list set node1-centos "role[web]"
  #   knife node show node1-centos --run-list
end
