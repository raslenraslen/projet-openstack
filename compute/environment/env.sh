#!/bin/bash

# Variables
MANAGEMENT_INTERFACE="eth0"  # Remplacez par le nom réel de l'interface réseau de gestion
PROVIDER_INTERFACE="eth1"    # Remplacez par le nom réel de l'interface fournisseur
MANAGEMENT_IP="10.0.0.31"
NETWORK_MASK="255.255.255.0"
GATEWAY="10.0.0.1"
HOSTNAME="compute1"
HOSTS_FILE="/etc/hosts"

# 1. Configurer l'interface de gestion (management interface)
echo "Configuration de l'interface de gestion $MANAGEMENT_INTERFACE..."
cat <<EOL > /etc/network/interfaces.d/eth0.cfg
# Interface de gestion
auto $MANAGEMENT_INTERFACE
iface $MANAGEMENT_INTERFACE inet static
    address $MANAGEMENT_IP
    netmask $NETWORK_MASK
    gateway $GATEWAY
EOL

# 2. Configurer l'interface fournisseur (provider interface)
echo "Configuration de l'interface fournisseur $PROVIDER_INTERFACE..."
cat <<EOL > /etc/network/interfaces.d/$PROVIDER_INTERFACE.cfg
# Interface fournisseur
auto $PROVIDER_INTERFACE
iface $PROVIDER_INTERFACE inet manual
    up ip link set dev \$IFACE up
    down ip link set dev \$IFACE down
EOL

# 3. Configurer le nom d'hôte
echo "Configuration du nom d'hôte..."
hostnamectl set-hostname $HOSTNAME

# 4. Ajouter les entrées dans le fichier /etc/hosts
echo "Mise à jour de /etc/hosts..."
cat <<EOL >> $HOSTS_FILE
# controller
192.168.45.128  controller
# compute1
10.0.0.31 compute1
# block1
10.0.0.41 block1
# object1
10.0.0.51 object1
# object2
10.0.0.52 object2
EOL

# 5. Vérification de la connectivité
echo "Vérification de la connectivité réseau..."

# Vérifier la connectivité à l'internet depuis le contrôleur
echo "Test de la connectivité Internet depuis le contrôleur..."
ping -c 4 docs.openstack.org

# Vérifier la connectivité à l'interface de gestion du nœud de calcul depuis le contrôleur
echo "Test de la connectivité à compute1 depuis le contrôleur..."
ping -c 4 compute1

# Vérifier la connectivité à l'internet depuis le nœud de calcul
echo "Test de la connectivité Internet depuis le nœud de calcul..."
ping -c 4 openstack.org

# Vérifier la connectivité à l'interface de gestion du contrôleur depuis le nœud de calcul
echo "Test de la connectivité à controller depuis le nœud de calcul..."
ping -c 4 controller

# Redémarrer le système pour appliquer les changements
echo "Redémarrage du système pour appliquer les changements..."
reboot
