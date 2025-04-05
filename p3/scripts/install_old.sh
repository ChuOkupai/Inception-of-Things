#!/bin/bash
set -e

echo "===== Starting K3d and ArgoCD installation ====="

# Check if Docker is installed, if not install it
if ! command -v docker &> /dev/null; then
    echo "Docker not found, installing..."
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    echo "Docker installed successfully!"
else
    echo "Docker already installed"
fi

# Install kubectl if not already installed
if ! command -v kubectl &> /dev/null; then
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    echo "kubectl installed successfully!"
else
    echo "kubectl already installed"
fi

# Check if k3d is already installed
if ! command -v k3d &> /dev/null; then
    echo "Installing k3d..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
else
    echo "k3d already installed"
fi

echo "k3d version: $(k3d --version)"

# Check if cluster already exists, if so delete it to start fresh
if k3d cluster list | grep -q "LesDemeuresS"; then
    echo "Cluster LesDemeuresS already exists, deleting it for a fresh start..."
    k3d cluster delete LesDemeuresS
fi

echo "Creating k3d cluster..."
k3d cluster create LesDemeuresS --port "8888:80@loadbalancer" --port "8080:80@loadbalancer"
echo "Cluster created successfully!"

# Configure DNS for better connectivity
echo "Configuring DNS..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-custom
  namespace: kube-system
  labels:
    k8s-app: kube-dns
data:
  Corefile: |
    .:53 {
        errors
        health
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          fallthrough in-addr.arpa ip6.arpa
        }
        hosts {
          fallthrough
        }
        forward . 8.8.8.8 8.8.4.4
        cache 30
        loop
        reload
        loadbalance
    }
EOF

kubectl rollout restart deployment coredns -n kube-system
echo "Waiting for CoreDNS to restart..."
kubectl rollout status deployment coredns -n kube-system

# Create namespaces
echo "Creating namespaces..."
kubectl create namespace argocd
kubectl create namespace dev

# Install ArgoCD complete version
echo "Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD server deployment to be available
echo "Waiting for ArgoCD server deployment to be created..."
sleep 20

echo "Checking if ArgoCD server deployment exists..."
kubectl get deployment argocd-server -n argocd || echo "Deployment not found yet, will wait..."

# Give more time for resources to be created
echo "Waiting for ArgoCD resources to be created (this may take several minutes)..."
sleep 30

# Install ArgoCD CLI if needed
if ! command -v argocd &> /dev/null; then
    echo "Installing ArgoCD CLI..."
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64
    echo "ArgoCD CLI installed"
else
    echo "ArgoCD CLI already installed"
fi

# Kill any existing port-forwarding
echo "Stopping any existing port forwarding..."
pkill -f "kubectl port-forward" || echo "No port forwarding to kill"

# Change ArgoCD server service type to LoadBalancer
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Start port forwarding for ArgoCD UI
echo "Starting port forwarding for ArgoCD UI..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &
echo "ArgoCD port forwarding started!"

# Apply application configuration
echo "Applying application configuration..."
kubectl apply -f confs/application.yaml

echo "Waiting for application to be created..."
sleep 20

# Apply service configuration
echo "Applying service configuration..."
kubectl apply -f confs/service.yaml

# Start port forwarding for the application
echo "Starting port forwarding for the application..."
kubectl port-forward svc/wil-service -n dev 8888:80 > /dev/null 2>&1 &
echo "Application port forwarding started!"

# Check for ArgoCD password
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

echo "===== Installation completed! ====="
echo "ArgoCD UI: https://localhost:8080 (username: admin, password: $ARGOCD_PWD)"
echo "Application: http://localhost:8888"
echo ""
echo "IMPORTANT: If ArgoCD is not available immediately, wait a few minutes for all pods to start."
echo "Check status with: kubectl get pods -n argocd"
echo ""
echo "To see when ArgoCD server is ready, run:"
echo "  kubectl get deployment argocd-server -n argocd"
echo ""
echo "Checking application availability..."
curl -s http://localhost:8888 || echo "Application not yet available, it may take some time to deploy"
