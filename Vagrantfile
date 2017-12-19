# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/trusty64"

  # Always check for box updates (default option)
  #config.vm.box_check_update = false

  # The hostname the machine should have
  config.vm.hostname = "ubuntu-lamp-xdebug-dev"

  ###### SSH
  # Set SSH username - default 'vagrant'
  #config.ssh.username = "vagrant"
  # Set SSH username - default without password
  # If you use a password, Vagrant will automatically insert a keypair if insert_key is true
  #config.ssh.password = "vagrant"

  ###### Networking
  # Forward ports on host machine to a guest machine
  # MySQL
  config.vm.network "forwarded_port", guest: 3306, host: 3306

  # Access guest machine address through host machine address in the private address space
  config.vm.network "private_network", ip: "192.168.33.10"

  # Sync folders
  config.vm.synced_folder "www/", "/var/www/html"

  ###### Provisioning
  config.vm.provision "shell", path: "provision/bootstrap.sh"
end
