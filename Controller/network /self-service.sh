#!/bin/bash

# Variables
NETWORK_NAME="selfservice"
SUBNET_NAME="selfservice-subnet"
SUBNET_RANGE="192.168.45.0/24"
GATEWAY="192.168.45.1"
DNS_SERVER="8.8.8.8" # DNS public, tu peux utiliser un autre DNS si nécessaire

# Créer un réseau self-service
echo "Création du réseau self-service..."
openstack network create --provider-network-type vxlan --provider-physical-network provider --shared $NETWORK_NAME

# Créer un sous-réseau dans le réseau self-service
echo "Création du sous-réseau pour $NETWORK_NAME..."
openstack subnet create --network $NETWORK_NAME \
  --dns-nameserver $DNS_SERVER \
  --gateway $GATEWAY \
  --subnet-range $SUBNET_RANGE \
  $SUBNET_NAME

# Afficher les détails du réseau et du sous-réseau
echo "Détails du réseau $NETWORK_NAME :"
openstack network show $NETWORK_NAME

echo "Détails du sous-réseau $SUBNET_NAME :"
openstack subnet show $SUBNET_NAME
