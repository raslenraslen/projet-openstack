#!/bin/bash

# ----------------------------------------------------------------------------
# Variables
# ----------------------------------------------------------------------------
NOVA_DBPASS="Raslen"  # Remplacez par le mot de passe choisi pour la base de données Nova
RABBIT_PASS="Raslen"  # Remplacez par le mot de passe choisi pour RabbitMQ
NOVA_PASS="Raslen"    # Remplacez par le mot de passe choisi pour le service Nova
PLACEMENT_PASS="Raslen"  # Remplacez par le mot de passe choisi pour le service Placement
CONTROLLER_IP="192.168.45.128"  # Remplacez par l'adresse IP du contrôleur

# ----------------------------------------------------------------------------
# Étape 1 : Installation des paquets nécessaires
# ----------------------------------------------------------------------------
echo "Installation des paquets Nova..."
sudo apt update
sudo apt install -y nova-api nova-conductor nova-novncproxy nova-scheduler

# ----------------------------------------------------------------------------
# Étape 2 : Configuration de la base de données
# ----------------------------------------------------------------------------
echo "Création des bases de données Nova..."

# Connexion à MySQL/MariaDB pour créer les bases de données
mysql -u root -p -e "CREATE DATABASE nova_api;"
mysql -u root -p -e "CREATE DATABASE nova;"
mysql -u root -p -e "CREATE DATABASE nova_cell0;"

# Accorder les privilèges nécessaires à l'utilisateur 'nova'
mysql -u root -p -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_DBPASS';"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_DBPASS';"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_DBPASS';"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_DBPASS';"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_DBPASS';"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_DBPASS';"

# ----------------------------------------------------------------------------
# Étape 3 : Création des utilisateurs OpenStack
# ----------------------------------------------------------------------------
echo "Création des utilisateurs et rôles Nova dans OpenStack..."

# Sourcez les informations d'identification de l'administrateur
source admin-openrc

# Création de l'utilisateur Nova
openstack user create --domain default --password-prompt nova
# Ajouter le rôle admin à l'utilisateur Nova
openstack role add --project service --user nova admin

# Création du service Nova
openstack service create --name nova --description "OpenStack Compute" compute

# Création des points de terminaison pour Nova
openstack endpoint create --region RegionOne compute public http://$CONTROLLER_IP:8774/v2.1
openstack endpoint create --region RegionOne compute internal http://$CONTROLLER_IP:8774/v2.1
openstack endpoint create --region RegionOne compute admin http://$CONTROLLER_IP:8774/v2.1

# ----------------------------------------------------------------------------
# Étape 4 : Configuration du fichier nova.conf
# ----------------------------------------------------------------------------
echo "Configuration de Nova dans /etc/nova/nova.conf..."

# Sauvegarder le fichier original au cas où
sudo cp /etc/nova/nova.conf /etc/nova/nova.conf.bak

# Modifier le fichier /etc/nova/nova.conf
sudo tee -a /etc/nova/nova.conf > /dev/null <<EOL
[api_database]
connection = mysql+pymysql://nova:$NOVA_DBPASS@$CONTROLLER_IP/nova_api

[database]
connection = mysql+pymysql://nova:$NOVA_DBPASS@$CONTROLLER_IP/nova

[DEFAULT]
transport_url = rabbit://openstack:$RABBIT_PASS@$CONTROLLER_IP:5672/

[api]
auth_strategy = keystone

[keystone_authtoken]
www_authenticate_uri = http://$CONTROLLER_IP:5000/
auth_url = http://$CONTROLLER_IP:5000/
memcached_servers = $CONTROLLER_IP:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = nova
password = $NOVA_PASS

[service_user]
send_service_user_token = true
auth_url = https://$CONTROLLER_IP/identity
auth_strategy = keystone
auth_type = password
project_domain_name = Default
project_name = service
user_domain_name = Default
username = nova
password = $NOVA_PASS

[vnc]
enabled = true
server_listen = \$my_ip
server_proxyclient_address = \$my_ip

[glance]
api_servers = http://$CONTROLLER_IP:9292

[oslo_concurrency]
lock_path = /var/lib/nova/tmp

[placement]
region_name = RegionOne
project_domain_name = Default
project_name = service
auth_type = password
user_domain_name = Default
auth_url = http://$CONTROLLER_IP:5000/v3
username = placement
password = $PLACEMENT_PASS
EOL

# ----------------------------------------------------------------------------
# Étape 5 : Synchronisation de la base de données
# ----------------------------------------------------------------------------
echo "Synchronisation de la base de données Nova..."
sudo su -s /bin/sh -c "nova-manage api_db sync" nova

# Enregistrer la cellule 0
echo "Enregistrement de la cellule0..."
sudo su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova

# Création de la cellule1
echo "Création de la cellule1..."
sudo su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova

# Synchronisation de la base de données
echo "Synchronisation de la base de données Nova..."
sudo su -s /bin/sh -c "nova-manage db sync" nova

# ----------------------------------------------------------------------------
# Étape 6 : Redémarrer les services Nova
# ----------------------------------------------------------------------------
echo "Redémarrage des services Nova..."
sudo service nova-api restart
sudo service nova-scheduler restart
sudo service nova-conductor restart
sudo service nova-novncproxy restart

echo "Configuration de Nova terminée avec succès !"
