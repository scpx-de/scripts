#!/bin/bash

HOSTNAME=$(hostname)

# Erstelle den Ordner /etc/apt/keyrings, falls nicht vorhanden
[ -d "/etc/apt/keyrings" ] || mkdir -p /etc/apt/keyrings

# Lade den Salt GPG Schlüssel herunter
curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring-2023.gpg https://repo.saltproject.io/salt/py3/debian/11/amd64/SALT-PROJECT-GPG-PUBKEY-2023.gpg

# Füge die Salt APT Quelle hinzu
echo "deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg arch=amd64] https://repo.saltproject.io/salt/py3/debian/11/amd64/latest bullseye main" > /etc/apt/sources.list.d/salt.list

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

# SSH-Befehl, um die Pillar-Datei auf dem Salt-Master zu erstellen
ssh -o StrictHostKeyChecking=no root@10.1.0.101 "echo -e 'roles:\\n  - server' > /srv/pillar/hosts/$HOSTNAME.sls"

# Warte ein paar Sekunden
sleep 10  # 10 Sekunden warten

# Führe die Salt States aus
salt-call state.apply
