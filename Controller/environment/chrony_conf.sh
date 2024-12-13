#!/bin/bash

# 1. Installer Chrony
echo "Installation de Chrony..."
sudo apt update
sudo apt install chrony -y

# 2. Configurer Chrony sur le Controller ou sur un autre nœud
echo "Configuration de Chrony..."

# Remplacer l'adresse du Controller ici (192.168.45.128)
sudo bash -c 'cat > /etc/chrony/chrony.conf <<EOF
# Serveur NTP à synchroniser avec le Controller
server 192.168.45.128 iburst  # Remplacer par l'IP du Controller

# Autoriser les autres nœuds à se synchroniser avec ce Controller
allow 192.168.45.0/24

# Utiliser les sources NTP depuis DHCP (si nécessaire)
sourcedir /run/chrony-dhcp

# Utiliser les fichiers de sources NTP depuis /etc/chrony/sources.d
sourcedir /etc/chrony/sources.d

# Fichier de clés pour l'authentification NTP
keyfile /etc/chrony/chrony.keys

# Fichier pour stocker les informations de dérive du temps
driftfile /var/lib/chrony/chrony.drift

# Sauvegarder les clés NTS et les cookies
ntsdumpdir /var/lib/chrony

# Dossier des logs
logdir /var/log/chrony

# Limiter les mauvaises estimations de l'horloge
maxupdateskew 100.0

# Synchronisation de l'horloge système avec le noyau
rtcsync

# Ajuster l'horloge système si la correction dépasse une seconde
makestep 1 3

# Obtenir le décalage TAI-UTC et les secondes intercalaires
leapsectz right/UTC
EOF'

# 3. Redémarrer le service Chrony pour appliquer les modifications
echo "Redémarrage de Chrony..."
sudo systemctl restart chrony

# 4. Activer Chrony pour démarrer automatiquement au démarrage du système
echo "Activation de Chrony au démarrage..."
sudo systemctl enable chrony

# 5. Vérifier la synchronisation NTP avec chronyc
echo "Vérification des sources de Chrony..."
chronyc sources
