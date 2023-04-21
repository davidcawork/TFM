#!/bin/bash

########################
# Install MiniNet-Wifi #
########################

echo "[+] Installing Mininet-Wifi..."

# Install needed dependencies.
sudo apt-get update && apt-get install -y git

# Clonamos el repositorio de Mininet
git clone https://github.com/intrig-unicamp/mininet-wifi

# Lanzamos el script de instalación (Openflow 1.3 - Ryu - Wireshark dissector)
sudo ./mininet-wifi/util/install.sh -3Wlfnv

# Test installation
sudo mn --wifi --test ping
