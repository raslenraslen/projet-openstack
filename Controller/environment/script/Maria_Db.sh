#!/bin/bash

# Installer MariaDB et pymysql pour OpenStack
echo "Installation de MariaDB et pymysql..."
sudo apt update
sudo apt install mariadb-server python3-pymysql -y

# Configurer MariaDB pour OpenStack
echo "Configuration de MariaDB pour OpenStack..."
sudo bash -c 'cat > /etc/mysql/mariadb.conf.d/99-openstack.cnf <<EOF
[mysqld]
bind-address = 192.168.45.128  # Adresse IP du Controller
default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
EOF'

# Redémarrer MariaDB pour appliquer les modifications
echo "Redémarrage de MariaDB..."
sudo service mysql restart

# Sécuriser MariaDB
echo "Sécurisation de MariaDB..."
sudo mysql_secure_installation
