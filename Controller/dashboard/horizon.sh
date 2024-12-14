#!/bin/bash

# Mettre à jour et installer les dépendances nécessaires
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3-pip python3-dev libapache2-mod-wsgi-py3 python3-memcached memcached

# Installer Django et pymemcache si non installés
sudo pip3 install django pymemcache

# Configuration de Horizon
HORIZON_CONF="/etc/openstack-dashboard/local_settings.py"

# Modifier le fichier de configuration de Horizon
sudo tee -a $HORIZON_CONF <<EOL

# --- Horizon Configuration ---
import os
from django.utils.translation import gettext_lazy as _
from horizon.utils import secret_key

DEBUG = True

# Paramétrer les adresses
OPENSTACK_HOST = "192.168.45.128"
OPENSTACK_KEYSTONE_URL = "http://192.168.45.128:5000/v3"
OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True
OPENSTACK_API_VERSIONS = {
    "identity": 3,
    "image": 2,
    "volume": 3,
}
OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "Default"
OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"

# Paramètres de session et cache
CACHES = {
    'default': {
         'BACKEND': 'django.core.cache.backends.memcached.PyMemcacheCache', 
         'LOCATION': '192.168.45.128:11211',  # Assurez-vous que Memcached écoute sur cette adresse
    }
}
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'

# Paramètres d'email
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# Thème et autres configurations
DEFAULT_THEME = 'ubuntu'
WEBROOT = '/horizon/'
ALLOWED_HOSTS = ['*']

# Compression
COMPRESS_OFFLINE = True

# Configuration du timezone
TIME_ZONE = "CET"

# --- Logging Configuration ---
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'console': {
            'format': '%(levelname)s %(name)s %(message)s'
        },
    },
    'handlers': {
        'console': {
            'level': 'DEBUG' if DEBUG else 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'console',
        },
    },
    'loggers': {
        'horizon': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'django': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
    },
}

# --- Security Group Rules ---
SECURITY_GROUP_RULES = {
    'all_tcp': {
        'name': _('All TCP'),
        'ip_protocol': 'tcp',
        'from_port': '1',
        'to_port': '65535',
    },
    'all_udp': {
        'name': _('All UDP'),
        'ip_protocol': 'udp',
        'from_port': '1',
        'to_port': '65535',
    },
    'all_icmp': {
        'name': _('All ICMP'),
        'ip_protocol': 'icmp',
        'from_port': '-1',
        'to_port': '-1',
    },
    'ssh': {
        'name': 'SSH',
        'ip_protocol': 'tcp',
        'from_port': '22',
        'to_port': '22',
    },
    # Ajoutez d'autres règles selon vos besoins
}

# --- Final ---
SECRET_KEY = secret_key.generate_or_read_from_file('/var/lib/openstack-dashboard/secret_key')
EOL

# Redémarrer Apache pour prendre en compte la configuration
sudo systemctl restart apache2

# Vérification de l'état du service Apache
sudo systemctl status apache2

echo "La configuration de Horizon est terminée et Apache a été redémarré."
