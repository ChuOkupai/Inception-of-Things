#!/bin/sh

wget -qO - https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --flannel-iface eth1

echo "alias k='kubectl'" >> /etc/profile.d/aliases.sh
