#!/bin/sh

wget -qO - https://get.k3s.io | K3S_URL="https://$2:6443" K3S_TOKEN_FILE="$1" sh -s - --flannel-iface eth1

echo "alias k='kubectl'" >> /etc/profile.d/aliases.sh
