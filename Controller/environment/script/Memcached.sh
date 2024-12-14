#!/bin/bash

# Installer Memcached et le package Python correspondant
echo "Installation de Memcached et du package Python correspondant..."
sudo apt update
sudo apt install -y memcached python3-memcache  # Utilise python-memcache pour Ubuntu < 18.04

# Modifier le fichier de configuration pour lier Memcached à l'IP du Controller
echo "Modification du fichier de configuration de Memcached..."
sudo sed -i 's/-l 127.0.0.1/-l 192.168.45.128/' /etc/memcached.conf  # Remplacer par l'IP du Controller

# Redémarrer le service Memcached pour appliquer les changements
echo "Redémarrage du service Memcached..."
sudo service memcached restart

# Vérifier si Memcached fonctionne correctement
echo "Vérification du statut de Memcached..."
sudo systemctl status memcached --no-pager
