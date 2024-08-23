#!/bin/sh

echo "alias k='kubectl'" >> /etc/profile.d/aliases.sh
wget -qO - https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --flannel-iface eth1
sleep 20 # TODO: Fix openapi error


mkdir -p /vagrant/network
cp /vagrant/confs/network.template.yaml /vagrant/network/network.yaml

/vagrant/scripts/create_app.sh app1
/vagrant/scripts/create_app.sh app2 --replicas=3
/vagrant/scripts/create_app.sh app3

kubectl apply -f /vagrant/app
kubectl apply -f /vagrant/network
