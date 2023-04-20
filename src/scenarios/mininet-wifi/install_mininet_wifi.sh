#!/bin/bash

########################
# Install MiniNet-Wifi #
########################

echo "[+] Installing Mininet-Wifi..."

# Install needed dependencies.
sudo apt-get update && apt-get install -y git

# Clonamos el repositorio de Mininet
git clone https://github.com/davidcawork/mininet.git

# Lanzamos el script de instalación (Openflow 1.3 - Ryu - Wireshark dissector)
sudo ./mininet/util/install.sh -3fmnyv

# Test installation
sudo mn --test ping