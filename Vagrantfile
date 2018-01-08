# -*- mode: ruby -*-
# vi: set ft=ruby :

###### Configuration variables
# Hostname of the machine
hostname = "ubuntu-lamp-xdebug"
# Local private network IP address
server_ip = "192.168.33.10"

Vagrant.configure("2") do |config|
  ###### Vagrant box configuration
  config.vm.box = "ubuntu/trusty64"
  # Set box version (default - latest version available)
  #config.vm.box_version = "1.0.0"
  # Always check for box updates (default option)
  #config.vm.box_check_update = false
  config.vm.hostname = hostname

  ###### SSH
  # Set SSH username - default 'vagrant'
  #config.ssh.username = "vagrant"
  # Set SSH username - default without password
  # If you use a password, Vagrant will automatically insert a keypair if insert_key is true
  #config.ssh.password = "vagrant"

  ###### Networking
  # Access guest machine address through host machine address in the private address space
  config.vm.network "private_network", ip: server_ip

  # Forward ports on host machine to a guest machine
  # MySQL
  config.vm.network "forwarded_port", guest: 3306, host: 3306

  # Sync folders
  config.vm.synced_folder "www/", "/var/www/html"

  ###### Provider-specific configuration
  config.vm.provider "virtualbox" do |vb|
    vb.name = hostname

    # Workaround for https://www.virtualbox.org/ticket/15705
    vb.customize ['modifyvm', :id, '--cableconnected1', 'on']
  end
  
  ###### Provisioning
  config.vm.provision "shell", path: "provision/bootstrap.sh"
end
