#!/bin/bash

# Installer les paquets nécessaires pour Placement
echo "Installation de Placement API..."
sudo apt update
sudo apt install -y placement-api mariadb-client python3-pymysql

# Créer la base de données Placement
echo "Création de la base de données Placement dans MariaDB..."
sudo mysql -u root -p -e "
CREATE DATABASE placement;
GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'localhost' IDENTIFIED BY 'Raslen';
GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%' IDENTIFIED BY 'Raslen';
"

# Source des informations d'identification administratives
echo "Source des informations d'identification admin..."
source /home/raslen/admin-openrc

# Créer un utilisateur Placement dans Keystone
echo "Création de l'utilisateur Placement dans Keystone..."
openstack user create --domain default --password-prompt placement
openstack role add --project service --user placement admin

# Créer le service Placement dans le catalogue
echo "Création du service Placement dans le catalogue..."
openstack service create --name placement --description "Placement API" placement

# Créer les points de terminaison (endpoints) pour Placement
echo "Création des points de terminaison pour Placement..."
openstack endpoint create --region RegionOne placement public http://controller:8778
openstack endpoint create --region RegionOne placement internal http://controller:8778
openstack endpoint create --region RegionOne placement admin http://controller:8778

# Configurer Placement
echo "Configuration du fichier placement.conf..."
sudo bash -c 'cat <<EOF > /etc/placement/placement.conf
[placement_database]
connection = mysql+pymysql://placement:Raslen@controller/placement

[api]
auth_strategy = keystone

[keystone_authtoken]
auth_url = http://controller:5000/v3
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = placement
password = Raslen
EOF'

# Synchroniser la base de données Placement
echo "Synchronisation de la base de données Placement..."
sudo su -s /bin/sh -c "placement-manage db sync" placement

# Redémarrer Apache pour appliquer la configuration
echo "Redémarrage du service Apache..."
sudo service apache2 restart

# Vérifier l'installation de Placement
echo "Vérification de l'installation de Placement..."
placement-status upgrade check
