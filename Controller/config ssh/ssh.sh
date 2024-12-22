#!/bin/bash

# Source les credentials d'OpenStack (assurez-vous de modifier le fichier avec vos informations)
echo "Sourcing OpenStack credentials..."
source demo-openrc

# Vérifie si le fichier de clé publique existe déjà
KEY_NAME="mykey"
KEY_FILE_PATH="$HOME/.ssh/id_rsa"
PUBLIC_KEY_PATH="$KEY_FILE_PATH.pub"

# Génère une nouvelle paire de clés si elle n'existe pas déjà
if [ ! -f "$KEY_FILE_PATH" ]; then
    echo "Generating new SSH key pair..."
    ssh-keygen -q -N "" -f "$KEY_FILE_PATH"
else
    echo "SSH key pair already exists at $KEY_FILE_PATH"
fi

# Crée la clé dans OpenStack
echo "Creating key pair in OpenStack..."
openstack keypair create --public-key "$PUBLIC_KEY_PATH" "$KEY_NAME"

# Vérifie que la clé a été correctement ajoutée
echo "Listing key pairs in OpenStack..."
openstack keypair list

echo "SSH key pair creation and addition to OpenStack is complete."
