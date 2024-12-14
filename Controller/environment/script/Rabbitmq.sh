#!/bin/bash

# Installer RabbitMQ
echo "Installation de RabbitMQ..."
sudo apt update
sudo apt install rabbitmq-server -y

# Créer l'utilisateur OpenStack dans RabbitMQ
echo "Création de l'utilisateur OpenStack dans RabbitMQ..."
sudo rabbitmqctl add_user openstack Raslen

# Définir les permissions pour l'utilisateur OpenStack
echo "Définition des permissions pour l'utilisateur OpenStack..."
sudo rabbitmqctl set_permissions openstack ".*" ".*" ".*"

# Vérifier si RabbitMQ est bien en cours d'exécution
echo "Vérification du statut de RabbitMQ..."
sudo systemctl status rabbitmq-server --no-pager
