#!/bin/bash

## ARGO CD

# Install K3d if you haven't already
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Create a K3d cluster
k3d cluster create LesDemeuresS --port "8888:80@loadbalancer" --port "8080:80@loadbalancer"

# Now create the namespaces and install Argo CD
kubectl create namespace argocd
kubectl create namespace dev
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD server to be ready
echo "Waiting for ArgoCD server to start (this might take a few minutes)..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
echo "ArgoCD server is ready!"

# Now do port-forwarding
echo "Starting port forwarding for ArgoCD UI..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 & > /dev/null 2>&1
echo "ArgoCD port forwarding started!"


## APPLICATION

# Get argo-cd Password
echo "Checking for ArgoCD admin password..."
kubectl -n argocd get secret argocd-initial-admin-secret -o name > /dev/null 2>&1
if [ $? -eq 0 ]; then
    ARGOCD_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    echo "ArgoCD password found: $ARGOCD_PWD"
else
    echo "ArgoCD admin secret not found, this could be because:"
    echo "1. The installation is not complete yet"
    echo "2. You're using a version of ArgoCD that doesn't create this secret"
    ARGOCD_PWD="<password not available yet>"
fi

# argocd login localhost:8080 --username admin --password "$ARGOCD_PWD" --insecure
# argocd app sync will-playground --server localhost:8080 --insecure

# Apply your application file
kubectl apply -f confs/app.yaml

# wait and port forwarding not working
echo "Waiting for application to be ready (this might take a few minutes)..."
kubectl wait --for=condition=available --timeout=300s svc/will-playground-service -n dev
echo "Application is ready!"

echo "Starting port forwarding for the application..."
kubectl port-forward svc/will-playground-service -n dev 8888:8888 & > /dev/null 2>&1
echo "Application port forwarding started!"


# argocd app sync wil-playground --server localhost:8080 --insecure


# 10. Print installation completion message
echo "===== Installation completed! ====="
echo "ArgoCD UI: https://localhost:8080 (username: admin, password: $ARGOCD_PWD)"
echo "Application: http://localhost:8888"
echo ""
# echo "IMPORTANT: If ArgoCD is not available immediately, wait a few minutes for all pods to start."
# echo "Check status with: kubectl get pods -n argocd"
# echo ""
# echo "To see when ArgoCD server is ready, run:"
# echo "  kubectl get deployment argocd-server -n argocd"
# echo ""
# echo "Checking application availability..."
# curl -s http://localhost:8888 || echo "Application not yet available, it may take some time to deploy"
