#!/bin/sh

wget -qO - https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --flannel-iface eth1
sleep 20 # TODO: Fix openapi error

echo "alias k='kubectl'" >> /etc/profile.d/aliases.sh

kubectl apply -f /vagrant/confs
