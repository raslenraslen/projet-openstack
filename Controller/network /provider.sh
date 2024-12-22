#!/bin/bash

# Vérification des permissions (nécessite d'être root ou avoir accès à openstack CLI)
if [[ $EUID -ne 0 ]]; then
   echo "Ce script doit être exécuté en tant que root ou avec les permissions nécessaires." 
   exit 1
fi

# Variables pour votre réseau
NETWORK_NAME="provider"
SUBNET_NAME="provider-subnet"
SUBNET_RANGE="192.168.45.0/24"
ALLOCATION_POOL_START="192.168.45.129"
ALLOCATION_POOL_END="192.168.45.150"
GATEWAY="192.168.45.1"
DNS_NAMESERVER="8.8.8.8"

# Création du sous-réseau
echo "Création du sous-réseau $SUBNET_NAME sur le réseau $NETWORK_NAME..."
openstack subnet create --network $NETWORK_NAME \
--allocation-pool start=$ALLOCATION_POOL_START,end=$ALLOCATION_POOL_END \
--dns-nameserver $DNS_NAMESERVER --gateway $GATEWAY \
--subnet-range $SUBNET_RANGE $SUBNET_NAME

# Vérification du résultat
if [ $? -eq 0 ]; then
    echo "Sous-réseau $SUBNET_NAME créé avec succès !"
else
    echo "Erreur lors de la création du sous-réseau."
    exit 1
fi
