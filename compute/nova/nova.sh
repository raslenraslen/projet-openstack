#!/bin/bash

# Variables à personnaliser
RABBIT_PASS="votre_rabbitmq_password"
NOVA_PASS="votre_nova_password"
PLACEMENT_PASS="votre_placement_password"
MANAGEMENT_INTERFACE_IP_ADDRESS="votre_ip_gestionnaire"  # Exemple : 10.0.0.31
CONTROLLER_IP="votre_ip_du_controller"  # Exemple : 192.168.45.1

# Installer le package nova-compute
echo "Installation du package nova-compute..."
sudo apt update
sudo apt install -y nova-compute

# Modifier /etc/nova/nova.conf
echo "Configuration de /etc/nova/nova.conf..."

sudo sed -i "/^\[DEFAULT\]/a transport_url = rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_IP}" /etc/nova/nova.conf
sudo sed -i "/^\[api\]/a auth_strategy = keystone" /etc/nova/nova.conf
sudo sed -i "/^\[keystone_authtoken\]/a www_authenticate_uri = http://${CONTROLLER_IP}:5000/" /etc/nova/nova.conf
sudo sed -i "/^\[keystone_authtoken\]/a auth_url = http://${CONTROLLER_IP}:5000/" /etc/nova/nova.conf
sudo sed -i "/^\[keystone_authtoken\]/a memcached_servers = ${CONTROLLER_IP}:11211" /etc/nova/nova.conf
sudo sed -i "/^\[keystone_authtoken\]/a auth_type = password" /etc/nova/nova.conf
sudo sed -i "/^\[keystone_authtoken\]/a project_domain_name = Default" /etc/nova/nova.conf
sudo sed -i "/^\[keystone_authtoken\]/a user_domain_name = Default" /etc/nova/nova.conf
sudo sed -i "/^\[keystone_authtoken\]/a project_name = service" /etc/nova/nova.conf
sudo sed -i "/^\[keystone_authtoken\]/a username = nova" /etc/nova/nova.conf
sudo sed -i "/^\[keystone_authtoken\]/a password = ${NOVA_PASS}" /etc/nova/nova.conf

# Configurer my_ip
echo "Configuration de my_ip dans /etc/nova/nova.conf..."
sudo sed -i "/^\[DEFAULT\]/a my_ip = ${MANAGEMENT_INTERFACE_IP_ADDRESS}" /etc/nova/nova.conf

# Configurer le VNC
echo "Configuration du VNC dans /etc/nova/nova.conf..."
sudo sed -i "/^\[vnc\]/a enabled = true" /etc/nova/nova.conf
sudo sed -i "/^\[vnc\]/a server_listen = 0.0.0.0" /etc/nova/nova.conf
sudo sed -i "/^\[vnc\]/a server_proxyclient_address = \$my_ip" /etc/nova/nova.conf
sudo sed -i "/^\[vnc\]/a novncproxy_base_url = http://${CONTROLLER_IP}:6080/vnc_auto.html" /etc/nova/nova.conf

# Configurer Glance
echo "Configuration de Glance dans /etc/nova/nova.conf..."
sudo sed -i "/^\[glance\]/a api_servers = http://${CONTROLLER_IP}:9292" /etc/nova/nova.conf

# Configurer Placement
echo "Configuration du Placement dans /etc/nova/nova.conf..."
sudo sed -i "/^\[placement\]/a region_name = RegionOne" /etc/nova/nova.conf
sudo sed -i "/^\[placement\]/a project_domain_name = Default" /etc/nova/nova.conf
sudo sed -i "/^\[placement\]/a project_name = service" /etc/nova/nova.conf
sudo sed -i "/^\[placement\]/a auth_type = password" /etc/nova/nova.conf
sudo sed -i "/^\[placement\]/a user_domain_name = Default" /etc/nova/nova.conf
sudo sed -i "/^\[placement\]/a auth_url = http://${CONTROLLER_IP}:5000/v3" /etc/nova/nova.conf
sudo sed -i "/^\[placement\]/a username = placement" /etc/nova/nova.conf
sudo sed -i "/^\[placement\]/a password = ${PLACEMENT_PASS}" /etc/nova/nova.conf

# Configurer libvirt si nécessaire
echo "Vérification du support de l'accélération matérielle..."
if egrep -c '(vmx|svm)' /proc/cpuinfo > /dev/null; then
    echo "Accélération matérielle détectée. Utilisation de KVM."
else
    echo "Aucune accélération matérielle. Utilisation de QEMU."
    sudo sed -i "/^\[libvirt\]/a virt_type = qemu" /etc/nova/nova-compute.conf
fi

# Redémarrer le service nova-compute
echo "Redémarrage du service nova-compute..."
sudo systemctl restart nova-compute

# Vérification de l'état du service
echo "Vérification du statut du service nova-compute..."
sudo systemctl status nova-compute

echo "Installation et configuration de nova-compute terminées."
