#!/bin/sh

readonly DEFAULT_TOKEN_PATH='/var/lib/rancher/k3s/server/node-token'

wget -qO - https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --flannel-iface eth1
until [ -f $DEFAULT_TOKEN_PATH ]; do sleep 1; done
mkdir -p $(dirname $1)
cp $DEFAULT_TOKEN_PATH $1

echo "alias k='kubectl'" >> /etc/profile.d/aliases.sh
