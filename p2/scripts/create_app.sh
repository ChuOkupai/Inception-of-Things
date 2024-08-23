#!/bin/sh

usage() {
    echo "Usage: $0 <app name> [options]"
    echo "Options:"
    echo "  <app name>  Name of the app"
    echo "  --replicas=<n>  Number of replicas (default: 1)"
    echo "  --apply  Apply the configuration"
    exit 1
}

if [ $# -lt 1 ]; then
    usage
fi

APP_NAME=""
REPLICAS=1
APPLY=0

for arg in "$@"; do
    case $arg in
        --replicas=*)
            REPLICAS="${arg#*=}"
            shift
            ;;
        --apply)
            APPLY=1
            shift
            ;;
        *)
            if [ -z "$APP_NAME" ]; then
                APP_NAME=$arg
            else
                usage
            fi
            shift
            ;;
    esac
done

if [ -z "$APP_NAME" ]; then
    usage
fi

mkdir -p /vagrant/app
cp /vagrant/confs/app.template.yaml /vagrant/app/$APP_NAME.yaml
sed -i "s/APP_NAME/$APP_NAME/g" /vagrant/app/$APP_NAME.yaml
sed -i "s/REPLICAS/$REPLICAS/g" /vagrant/app/$APP_NAME.yaml

cat /vagrant/confs/network_host.template.yaml >> /vagrant/network/network.yaml
sed -i "s/APP_NAME/$APP_NAME/g" /vagrant/network/network.yaml


if [ $APPLY -eq 1 ]; then
	kubectl apply -f /vagrant/app/$APP_NAME.yaml
fi

echo "App $APP_NAME created with $REPLICAS replicas"
