# Vagrant Box - Ubuntu-Lamp-Xdebug
Instead of LAMP, XAMPP, MAMP, etc. set up web server up and running in minutes, plus you are not limited to just one web root folder.

LAMP stack running on Ubuntu using PHP 7 and Xdebug. Keeping it lightweight with minimum dependencies installed.

#### Stack
* Ubuntu 14.04 64-bit
* Apache 2.4.7
* PHP 7.1.12
* Xdebug 2.5.5
* MySQL 5.5.58 (or MariaDB 10.1)

#### Prerequisite
* Vagrant <http://www.vagrantup.com>
* VirtualBox <http://www.virtualbox.org>

Instead of downloading project from github, you can just download vagrant box with current provisioning and create vagrant file by yourself.
Vagrant box is available at - [marko424/ubuntu-lamp-xdebug](https://app.vagrantup.com/marko424/boxes/ubuntu-lamp-xdebug)

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

#### MySQL
MySQL server is available at port 3306 as usual. Username: root Password: rootpass
