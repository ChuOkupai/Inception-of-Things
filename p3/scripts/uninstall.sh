#!/bin/bash

# Uninstall k3d
if command -v k3d &> /dev/null; then
    echo "Uninstalling k3d..."
    # Remove all k3d clusters if present
    k3d cluster list 2>/dev/null && k3d cluster delete --all
    # Remove k3d executable
    sudo rm -f $(which k3d)
    echo "k3d uninstalled successfully!"
else
    echo "k3d is not installed"
fi

# Uninstall kubectl
if command -v kubectl &> /dev/null; then
    echo "Uninstalling kubectl..."
    # Remove kubectl
    sudo rm -f $(which kubectl)
    echo "kubectl uninstalled successfully!"
else
    echo "kubectl is not installed"
fi

# Clean up configurations
echo "Cleaning up configurations..."
rm -rf ~/.kube

echo "Uninstallation complete!"
