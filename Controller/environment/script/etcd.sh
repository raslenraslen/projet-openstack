#!/bin/bash

# Installer Etcd
echo "Installation de Etcd..."
sudo apt update
sudo apt install -y etcd

# Modifier le fichier de configuration de Etcd
echo "Modification du fichier de configuration de Etcd..."
sudo sed -i 's/^ETCD_NAME=".*"/ETCD_NAME="controller"/' /etc/default/etcd
sudo sed -i 's/^ETCD_DATA_DIR=".*"/ETCD_DATA_DIR="\/var\/lib\/etcd"/' /etc/default/etcd
sudo sed -i 's/^ETCD_INITIAL_CLUSTER_STATE=".*"/ETCD_INITIAL_CLUSTER_STATE="new"/' /etc/default/etcd
sudo sed -i 's/^ETCD_INITIAL_CLUSTER_TOKEN=".*"/ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-01"/' /etc/default/etcd
sudo sed -i 's/^ETCD_INITIAL_CLUSTER=".*"/ETCD_INITIAL_CLUSTER="controller=http:\/\/192.168.45.128:2380"/' /etc/default/etcd
sudo sed -i 's/^ETCD_INITIAL_ADVERTISE_PEER_URLS=".*"/ETCD_INITIAL_ADVERTISE_PEER_URLS="http:\/\/192.168.45.128:2380"/' /etc/default/etcd
sudo sed -i 's/^ETCD_ADVERTISE_CLIENT_URLS=".*"/ETCD_ADVERTISE_CLIENT_URLS="http:\/\/192.168.45.128:2379"/' /etc/default/etcd
sudo sed -i 's/^ETCD_LISTEN_PEER_URLS=".*"/ETCD_LISTEN_PEER_URLS="http:\/\/0.0.0.0:2380"/' /etc/default/etcd
sudo sed -i 's/^ETCD_LISTEN_CLIENT_URLS=".*"/ETCD_LISTEN_CLIENT_URLS="http:\/\/192.168.45.128:2379"/' /etc/default/etcd

# Activer et redémarrer le service Etcd
echo "Activation et redémarrage de Etcd..."
sudo systemctl enable etcd
sudo systemctl restart etcd

# Vérifier que le service Etcd fonctionne correctement
echo "Vérification du statut de Etcd..."
sudo systemctl status etcd --no-pager
