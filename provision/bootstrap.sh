#!/bin/bash

# Variables
php_version="7.1"
mysql_version="5.5"
mariadb_version="10.1"

db_password='rootpass'

php_config_file="/etc/php/${php_version}/apache2/php.ini"
xdebug_config_file="/etc/php/${php_version}/apache2/conf.d/20-xdebug.ini"
mysql_config_file="/etc/mysql/my.cnf"


# Main function called at the very bottom of the file
main() {
	updateConfig
	addLocales
	apacheConfig
	phpConfig
	#composerConfig
	#nodejsConfig
	mysqlConfig
	#mariaDBConfig
	restartServices
	cleanUp
}

updateConfig() {
	###### Download and Install the latest updates for the OS
	printf "\n\n\n\n[ #### Update all the dependencies #### ]\n\n"
    sudo apt-get update && sudo apt-get upgrade
}

addLocales() {
	###### Download and Install locales
	printf "\n\n\n\n[ #### Download and Install locales #### ]\n\n"
    # Check which locales are supported
    printf "\nSupported locales\n"
    locale -a
    # Add locales
    #sudo locale-gen sl_SI.UTF-8
    # Update command
    #sudo update-locale
    # Check which locales are supported
    printf "\nSupported locales\n"
    locale -a
}

apacheConfig() {
    ###### Apache
    printf "\n\n\n\n[ #### Install Apache #### ]\n\n"
    sudo apt-get install apache2 -y
    printf "\n"
    # Later PHP install fails if you don't remove Apache warning
    # To turn off warning add line to the end of a file "ServerName localhost"
    echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/fqdn.conf
    sudo a2enconf fqdn
    sudo service apache2 restart
    sudo apache2ctl configtest
    printf "\n"
    
    # Enable Apache mod_rewrite or prompt that the module is already in effect
    printf "\nEnable module rewrite\n"
    sudo a2enmod rewrite
    sudo service apache2 restart
    # Replace the third occurrence of string AllowOverride None with AllowOverride All
    printf "\nReplace string AllowOverride None with AllowOverride All\n"
    sudo sed -i ':a;N;$!ba;s/AllowOverride None/AllowOverride All/3' /etc/apache2/apache2.conf
    sudo service apache2 restart
    
    printf "\n"
    apache2 -v
}

phpConfig() {
    ###### PHP
    printf "\n\n\n\n[ #### Install PHP with extensions #### ]\n\n"
    sudo apt-add-repository ppa:ondrej/php -y
    sudo apt-get update
    # Only add modules that are not already included
    sudo apt-get install php7.1 php7.1-mysql php-xdebug -y

    # Update Xdebug settings
    printf "\nUpdate Xdebug settings\n"
    xdebugConfig
    printf "\n"
    cat ${xdebug_config_file}

    printf "\n[ #### Installed PHP modules (Ubuntu packages) #### ]\n"
    php -m

    printf "\n"
    php -v
}

composerConfig() {
    ###### Composer
    printf "\n\n\n\n[ #### Install Composer #### ]\n\n"
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer

    printf "\n"
    composer --version
}

nodejsConfig() {
    ###### Node.js & npm
    printf "\n\n\n\n[ #### Install Node.js & npm #### ]\n\n"
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    sudo apt-get install -y nodejs

    printf "\n"
    node -v
    printf "\n"
    npm -v
}

mysqlConfig() {
    ###### MySQL
    # No new empty lines allowed in the lower block
    printf "\n\n\n\n[ #### Install MySQL #### ]\n\n"
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password rootpass'
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password rootpass'
    sudo apt-get -y install mysql-server
    printf "\n"

    # Update mysql configs file.
    printf "\n\n\n\n[ #### Updating mysql configs in ${mysql_config_file}.#### ]\n\n"

    sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" ${mysql_config_file}
    printf "\nUpdated mysql bind address in ${mysql_config_file} to 0.0.0.0 to allow external connections\n"

    sudo sed -i "/.*skip-external-locking.*/s/^/#/g" ${mysql_config_file}
    printf "\nUpdated mysql skip-external-locking in ${mysql_config_file} to #skip-external-locking. If you run multiple servers that use the same database directory (not recommended), each server must have external locking enabled\n"

    # Assign mysql root user access on %
    sudo mysql -u root -p$db_password --execute "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$db_password' with GRANT OPTION; FLUSH PRIVILEGES;"
    printf "Assigned mysql user 'root' access on all hosts."

    # Restart mysql service
    sudo service mysql restart

    printf "\n"
    mysql --version
}

mariaDBConfig() {
    ###### MariaDB
    printf "\n\n\n\n[ #### Install MariaDB #### ]\n\n"
    # Import repo key
    sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db

    # Add repo for MariaDB
    sudo add-apt-repository "deb [arch=amd64,i386] http://mirrors.accretive-networks.net/mariadb/repo/$mariadb_version/ubuntu trusty main"

    # Update
    sudo apt-get update

    # Install MariaDB without password prompt
    # Set username to 'root'
    sudo debconf-set-selections <<< "maria-db-$mariadb_version mysql-server/root_password password $db_password"
    sudo debconf-set-selections <<< "maria-db-$mariadb_version mysql-server/root_password_again password $db_password"

    # Install MariaDB
    # -qq implies -y --force-yes
    sudo apt-get install -qq mariadb-server

    # Make MariaDB accessible from outside world without SSH tunnel
    # enable remote access
    # setting the mysql bind-address to allow connections from everywhere
    # Update mysql configs file.
    printf "\n\n\n\n[ #### Updating mysql configs in ${mysql_config_file} #### ]\n\n"
    sed -i "s/bind-address.*/bind-address = 0.0.0.0/" ${mysql_config_file}
    printf "\nUpdated mysql bind address in ${mysql_config_file} to 0.0.0.0 to allow external connections\n"

    sudo sed -i "/.*skip-external-locking.*/s/^/#/g" ${mysql_config_file}
    printf "\nUpdated mysql skip-external-locking in ${mysql_config_file} to #skip-external-locking. If you run multiple servers that use the same database directory (not recommended), each server must have external locking enabled\n"

    # Assign mysql root user access on %
    sudo mysql -u root -p$db_password --execute "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$db_password' with GRANT OPTION; FLUSH PRIVILEGES;"
    printf "Assigned mysql user 'root' access on all hosts."
    sleep 5
    # Restart mysql service
    sudo service mysql restart

    printf "\n"
    mysql --version
}

restartServices() {
    ###### Restart services
    printf "\n\n\n\n[ #### Restart services #### ]\n\n"
    sudo service apache2 restart
    sudo service mysql restart
}

cleanUp() {
    ###### Disk space optimization
    # Clear out the local repository of retrieved package files (remove everything but the lock file
    # from /var/cache/apt/archives/ and /var/cache/apt/archives/partial/)
    sudo apt-get clean
    # Zero out drive (write zeroes to all empty space on the volume, which will allow better
    # compression of the physical file containing the virtual disk)
    sudo dd if=/dev/zero of=/EMPTY bs=1M
    sudo rm -f /EMPTY
    # Clear Bash History
    cat /dev/null > ~/.bash_history && history -c && exit
}

xdebugConfig () {
declare -a xdebugConfigArray=("
xdebug.remote_enable=1
;;Type: boolean, Default value: 0
;;This switch controls whether Xdebug should try to contact a debug client which is listening on the host and port as set with the settings
;;xdebug.remote_host and xdebug.remote_port. If a connection can not be established the script will just continue as if this setting was 0.
"

"
;;xdebug.remote_host=127.0.0.1
;;Type: string, Default value: localhost
;;Selects the host where the debug client is running, you can either use a host name or an IP address. This setting is ignored if
;;xdebug.remote_connect_back is enabled.
"

"
xdebug.remote_connect_back=1
;;Type: boolean, Default value: 0, Introduced in Xdebug 2.1
;;If enabled, the xdebug.remote_host setting is ignored and Xdebug will try to connect to the client that made the HTTP request. It checks the
;;\$_SERVER['REMOTE_ADDR'] variable to find out which IP address to use. Please note that there is no filter available, and anybody who can connect to
;;the webserver will then be able to start a debugging session, even if their address does not match xdebug.remote_host.
"

"
;;xdebug.remote_port=9000
;;Type: integer, Default value: 9000
;;The port to which Xdebug tries to connect on the remote host. Port 9000 is the default for both the client and the bundled debugclient. As many
;;clients use this port number, it is best to leave this setting unchanged.
"

"
;;xdebug.remote_handler=dbgp
;;Type: string, Default value: dbgp
;;Can be either 'php3' which selects the old PHP 3 style debugger output, 'gdb' which enables the GDB like debugger interface or 'dbgp' - the
;;debugger protocol. The DBGp protocol is more widely supported by clients. See more information in the introduction for Remote Debugging.
;;Note: Xdebug 2.1 and later only support 'dbgp' as protocol.
"

"
;;xdebug.remote_mode=req
;;Type: string, Default value: req
;;Selects when a debug connection is initiated. This setting can have two different values:
;;req Xdebug will try to connect to the debug client as soon as the script starts.
;;jit Xdebug will only try to connect to the debug client as soon as an error condition occurs.
"

"
xdebug.idekey=vagrant
;;Type: string, Default value: *complex*
;;Controls which IDE Key Xdebug should pass on to the DBGp debugger handler. The default is based on environment settings. First the environment
;;setting DBGP_IDEKEY is consulted, then USER and as last USERNAME. The default is set to the first environment variable that is found. If none could
;;be found the setting has as default ''. If this setting is set, it always overrides the environment variables.
"

"
xdebug.remote_autostart=true
;;Type: boolean, Default value: 0
;;Normally you need to use a specific HTTP GET/POST variable to start remote debugging (see Remote Debugging). When this setting is set to 1, Xdebug
;;will always attempt to start a remote debugging session and try to connect to a client, even if the GET/POST/COOKIE variable was not present.
"

"
;;xdebug.remote_log=/tmp/xdebug.log
;;Type: string, Default value:
;;If set to a value, it is used as filename to a file to which all remote debugger communications are logged. The file is always opened in
;;append-;;mode, and will therefore not be overwritten by default. There is no concurrency protection available.
"
)

## loop through xdebugConfigArray
for i in "${xdebugConfigArray[@]}"
do
   echo "$i" >> ${xdebug_config_file}
done
}

main
