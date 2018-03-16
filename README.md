## Vagrant Box - Ubuntu-Lamp-Xdebug
LAMP stack running on Ubuntu using PHP 7 and Xdebug. Keeping it lightweight with minimum dependencies installed.

#### Stack
* Ubuntu 16.04 64-bit
* Apache 2.4.18
* PHP 7.2.3
* Xdebug 2.6.0
* MariaDB 10.2.13 (optional MySQL 5.5)
* Composer & npm (optional)

Available releases - https://github.com/markokosir/vagrant-ubuntu-lamp-xdebug/releases

#### Prerequisite
* Vagrant <http://www.vagrantup.com>
* VirtualBox <http://www.virtualbox.org>

Instead of downloading project from github, just download vagrant box with current provisioning and create vagrant file by yourself. Vagrant box - [marko424/ubuntu-lamp-xdebug](https://app.vagrantup.com/marko424/boxes/ubuntu-lamp-xdebug)

## Vagrant
### Vagrant box up and running
1. Clone or download project from github
2. Update vagrant/provisioning file to your needs
3. From the command-line:
```
$ cd ubuntu-lamp-xdebug
$ vagrant up
...
$ vagrant ssh
```

### Connecting
#### Apache
The Apache server is available on private network IP 192.168.33.10  
The web root is synced in the project directory at "www/".  
Enabled mod_rewrite.

#### PHP
Enabled and configured additional PHP extensions: xdebug, PDO, xml, mbstring, zip.

#### MariaDB
MariaDB server is available at port 3306 as usual. Username: root Password: rootpass  
Instead of MariaDB database install MySQL with uncommenting one line in provisioning file - bootstrap.sh:
```
...
# Main function called at the very bottom of the file
main() {
	updateConfig
	addLocales
	apacheConfig
	phpConfig
	#composerConfig
	#nodejsConfig
	#mysqlConfig
	mariaDBConfig
	restartServices
	cleanUp
}
...
```
