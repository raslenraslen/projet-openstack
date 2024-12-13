#!/bin/bash

# Configuration de l'interface de gestion
echo "Configuration de l'interface de gestion..."
sudo bash -c 'cat > /etc/network/interfaces <<EOF
# Interface de gestion
auto ens33
iface ens33 inet static
    address 192.168.45.128
    netmask 255.255.255.0
    gateway 192.168.45.1
EOF'

# Configuration de l'interface fournisseur (sans IP)
echo "Configuration de l'interface fournisseur..."
sudo bash -c 'cat > /etc/network/interfaces.d/ens37.cfg <<EOF
# Interface fournisseur
auto ens37
iface ens37 inet manual
    up ip link set dev $IFACE up
    down ip link set dev $IFACE down
EOF'

# Redémarrer les interfaces réseau pour appliquer les changements
echo "Redémarrage des interfaces réseau..."
sudo systemctl restart networking
