#!/bin/bash

HOSTNAME=$(hostname)

# Erstelle den Ordner /etc/apt/keyrings, falls nicht vorhanden
[ -d "/etc/apt/keyrings" ] || mkdir -p /etc/apt/keyrings

# Lade den Salt GPG Schlüssel herunter
curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp
# Create apt repo target configuration
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | sudo tee /etc/apt/sources.list.d/salt.sources

# Aktualisiere das APT Repository
apt-get update

# Installiere den Salt Minion
apt-get install -y salt-minion

# Setze die Salt Master-IP
[ -d "/etc/salt/minion.d" ] || mkdir -p /etc/salt/minion.d
echo "master: 10.1.0.101" > /etc/salt/minion.d/master.conf

# Starte und aktiviere den Salt Minion Dienst
systemctl restart salt-minion
systemctl enable salt-minion

# Führe die Salt States aus
salt-call state.apply
