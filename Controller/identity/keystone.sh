#!/bin/bash

# 1. Installer MariaDB
echo "Installation de MariaDB..."
sudo apt update
sudo apt install -y mariadb-server python3-pymysql

# 2. Sécuriser MariaDB
echo "Sécurisation de MariaDB..."
sudo mysql_secure_installation <<EOF

n
y
y
y
y
EOF

# 3. Créer et configurer la base de données pour Keystone
echo "Création et configuration de la base de données Keystone..."
sudo mysql -e "CREATE DATABASE keystone;"
sudo mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'Raslen';"
sudo mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'Raslen';"
sudo mysql -e "FLUSH PRIVILEGES;"

# 4. Installer Keystone
echo "Installation de Keystone..."
sudo apt install -y keystone

# 5. Configurer le fichier de configuration de Keystone
echo "Configuration de Keystone..."
sudo sed -i 's|# connection = sqlite:////var/lib/keystone/keystone.db|connection = mysql+pymysql://keystone:Raslen@controller/keystone|' /etc/keystone/keystone.conf
sudo sed -i 's|# provider = fernet|provider = fernet|' /etc/keystone/keystone.conf

# 6. Initialiser la base de données de Keystone
echo "Initialisation de la base de données de Keystone..."
sudo keystone-manage db_sync

# 7. Initialiser les clés Fernet
echo "Initialisation des clés Fernet..."
sudo keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
sudo keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

# 8. Bootstrap le service Keystone
echo "Bootstrap du service Keystone..."
sudo keystone-manage bootstrap --bootstrap-password Raslen --bootstrap-admin-url http://controller:5000/v3/ \
--bootstrap-internal-url http://controller:5000/v3/ --bootstrap-public-url http://controller:5000/v3/ --bootstrap-region-id RegionOne

# 9. Configurer Apache pour Keystone
echo "Configuration d'Apache pour Keystone..."
sudo sed -i '/#ServerName www.example.com/c\ServerName controller' /etc/apache2/apache2.conf
sudo service apache2 restart

# 10. Créer les fichiers OpenRC pour l'authentification
echo "Création des fichiers OpenRC..."

# Fichier admin-openrc
cat <<EOF > ~/admin-openrc
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=Raslen
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF

# Fichier demo-openrc
cat <<EOF > ~/demo-openrc
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=myproject
export OS_USERNAME=myuser
export OS_PASSWORD=Raslen
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF

# 11. Vérifier l'authentification
echo "Vérification du jeton d'authentification..."

# Charger les variables d'environnement
source ~/admin-openrc

# Demander un jeton d'authentification
openstack token issue
