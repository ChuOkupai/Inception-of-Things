#!/bin/bash
# We don't want to exit on errors since we're cleaning up and some components might already be gone
set +e

echo "===== K3d and ArgoCD Uninstallation ====="

# Function to print a section header
print_header() {
    echo ""
    echo "===== $1 ====="
    echo ""
}

# List all Kubernetes resources
print_header "Current Kubernetes Resources"

# Check if kubectl is available
if command -v kubectl &> /dev/null; then
    echo "Listing all namespaces:"
    kubectl get namespaces || echo "Failed to get namespaces"

    echo ""
    echo "Listing all services across all namespaces:"
    kubectl get svc --all-namespaces || echo "Failed to get services"

    echo ""
    echo "Listing all deployments across all namespaces:"
    kubectl get deployments --all-namespaces || echo "Failed to get deployments"

    echo ""
    echo "Listing all pods across all namespaces:"
    kubectl get pods --all-namespaces || echo "Failed to get pods"
else
    echo "kubectl not found. Skipping Kubernetes resource listing."
fi

# List all Docker containers and images
print_header "Current Docker Resources"

if command -v docker &> /dev/null; then
    echo "Listing all Docker containers:"
    docker ps -a || echo "Failed to list Docker containers"

    echo ""
    echo "Listing all Docker images:"
    docker images || echo "Failed to list Docker images"
else
    echo "Docker not found. Skipping Docker resource listing."
fi

echo ""
echo "Listing port forwarding processes:"
lsof -i -P -n | grep kubectl || echo "No port forwarding processes found or lsof not available"

# Ask for confirmation before shutdown
print_header "Confirmation"
read -p "Do you want to proceed with shutting down everything? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Shutdown aborted."
    exit 0
fi

# Start the shutdown process
print_header "Starting Shutdown Process"

# Kill port forwarding processes
echo "Stopping port forwarding processes..."
pkill -f "kubectl port-forward" || echo "No port forwarding processes found"

# Delete application resources if kubectl is available
if command -v kubectl &> /dev/null; then
    # Delete ArgoCD application
    echo "Deleting ArgoCD application..."
    kubectl delete application -n argocd wil-argo-app --ignore-not-found=true

    # Wait for application deletion to complete
    echo "Waiting for ArgoCD application to be deleted..."
    sleep 5

    # Delete services first
    echo "Deleting wil-service in dev namespace..."
    kubectl delete service wil-service -n dev --ignore-not-found=true

    # Delete deployments
    echo "Deleting wil-app deployment in dev namespace..."
    kubectl delete deployment wil-app -n dev --ignore-not-found=true

    # Delete ConfigMap in kube-system namespace
    echo "Deleting coredns-custom ConfigMap in kube-system namespace..."
    kubectl delete configmap coredns-custom -n kube-system --ignore-not-found=true

    # Delete dev namespace
    echo "Deleting dev namespace..."
    kubectl delete namespace dev --ignore-not-found=true

    # Delete ArgoCD namespace
    echo "Deleting ArgoCD namespace..."
    kubectl delete namespace argocd --ignore-not-found=true

    # Wait for namespaces to be deleted
    echo "Waiting for namespaces to be deleted..."
    kubectl wait --for=delete namespace/dev --timeout=60s 2>/dev/null || true
    kubectl wait --for=delete namespace/argocd --timeout=60s 2>/dev/null || true
else
    echo "kubectl not found. Skipping Kubernetes resource deletion."
fi

# Check if k3d is available and delete the cluster
if command -v k3d &> /dev/null; then
    # Delete the K3d cluster
    echo "Deleting K3d cluster 'LesDemeuresS'..."
    k3d cluster delete LesDemeuresS || echo "K3d cluster 'LesDemeuresS' not found or already deleted"
else
    echo "k3d not found. Skipping cluster deletion."
fi

# Check if Docker is available and clean up Docker resources
if command -v docker &> /dev/null; then
    # Remove project-specific Docker images
    echo "Removing project-specific Docker images..."
    docker images | grep "wil42/playground" | awk '{print $1":"$2}' | xargs -r docker rmi 2>/dev/null || echo "No wil42/playground images found"

    # Option to remove ArgoCD-related images
    read -p "Do you want to remove ArgoCD-related Docker images? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing ArgoCD-related Docker images..."
        docker images | grep -E "quay.io/argoproj|argocd" | awk '{print $1":"$2}' | xargs -r docker rmi 2>/dev/null || echo "No ArgoCD images found"
    fi

    # Clean up dangling images
    echo "Cleaning up dangling images..."
    docker image prune -f
else
    echo "Docker not found. Skipping Docker cleanup."
fi

# We're keeping all CLI tools installed (kubectl, argocd) for future reinstallations
echo "CLI tools (kubectl, argocd) will remain installed for future use."

# Verify everything is cleaned up
print_header "Verification"

# Verify Kubernetes resources are cleaned up
if command -v kubectl &> /dev/null; then
    echo "Checking for remaining Kubernetes resources..."
    kubectl get all --all-namespaces || echo "Failed to get Kubernetes resources"
fi

# Verify Docker resources are cleaned up
if command -v docker &> /dev/null; then
    echo ""
    echo "Checking for remaining Docker containers..."
    docker ps -a | grep -E "k3d-|argocd" || echo "No k3d or ArgoCD containers found"
fi

echo ""
echo "Checking for remaining port forwarding processes..."
lsof -i -P -n | grep kubectl || echo "No port forwarding processes found or lsof not available"

print_header "Shutdown Completed"
echo "The system has been shut down and cleaned up."
echo "If you see any resources still present, you may need to manually remove them."