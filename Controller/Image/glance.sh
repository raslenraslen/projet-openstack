# ----------------------------
# Installation et Configuration de Glance
# ----------------------------

# Étape 1 : Préparer la Base de Données

# Connectez-vous à MySQL/MariaDB
mysql -u root -p

# Créez la base de données Glance
CREATE DATABASE glance;

# Donnez les privilèges nécessaires
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'Raslen';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'Raslen';

# Quittez MySQL
EXIT;

# Étape 2 : Créer un Utilisateur et un Service pour Glance dans OpenStack

# Sourcez les variables d'environnement administratives
source admin-openrc

# Créez l'utilisateur Glance
openstack user create --domain default --password-prompt glance

# Ajoutez le rôle admin à l'utilisateur Glance
openstack role add --project service --user glance admin

# Créez l'entité de service Glance
openstack service create --name glance --description "OpenStack Image" image

# Créez les points de terminaison de l'API Glance
openstack endpoint create --region RegionOne image public http://192.168.45.128:9292
openstack endpoint create --region RegionOne image internal http://192.168.45.128:9292
openstack endpoint create --region RegionOne image admin http://192.168.45.128:9292

# Étape 3 : Installer les Paquets Glance
sudo apt update
sudo apt install glance

# Étape 4 : Configurer Glance

# Éditez le fichier de configuration de Glance (`glance-api.conf`)
sudo nano /etc/glance/glance-api.conf

# Modifiez les sections suivantes dans le fichier `glance-api.conf` :
# ---------------------------------------------
# [database] Section
[database]
connection = mysql+pymysql://glance:Raslen@192.168.45.128/glance

# ---------------------------------------------
# [keystone_authtoken] Section
[keystone_authtoken]
auth_url = http://192.168.45.128:5000/v3
memcached_servers = 192.168.45.128:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = Raslen

# ---------------------------------------------
# [glance_store] Section
[glance_store]
default_backend = fs
filesystem_store_datadir = /var/lib/glance/images/

# ---------------------------------------------
# [DEFAULT] Section (facultatif)
[DEFAULT]
log_file = /var/log/glance/glance-api.log
debug = True

# Étape 5 : Synchroniser la Base de Données de Glance
sudo su -s /bin/sh -c "glance-manage db_sync" glance

# Étape 6 : Redémarrer les Services Glance
sudo service glance-api restart
sudo service glance-registry restart

# Étape 7 : Télécharger et Créer une Image de Test (CirrOS)
# Téléchargez l'image CirrOS
wget http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img

# Téléversez l'image dans Glance
glance image-create --name "cirros" --file cirros-0.4.0-x86_64-disk.img --disk-format qcow2 --container-format bare --visibility=public

# Vérifiez si l'image a été correctement téléversée
openstack image list
