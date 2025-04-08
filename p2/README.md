# Part 2: K3s and three simple applications

This project uses K3s to deploy three web applications on a single virtual machine with Vagrant. The applications are accessible through host-based routing using Ingress.

## Overview

The setup creates a virtual machine with the following specifications:
- Hostname: `[YOUR_USERNAME]S`
- IP Address: 192.168.56.110
- K3s installed in server mode
- Three web applications deployed and accessible through different host names

## Prerequisites

Before you begin, ensure you have the following installed on your machine:
- Vagrant
- VirtualBox

## Build Process

To start the Vagrant environment, navigate to the project directory and run:

```sh
vagrant up
```

This command will:
- Create and configure the server virtual machine
- Install K3s on the server
- Deploy three web applications:
  - app1: 1 replica
  - app2: 3 replicas
  - app3: 1 replica (default application)
- Configure Ingress for host-based routing

## Application Access

Once the environment is running, you can access the applications using curl or a web browser:

```sh
# Access app1
curl -H "Host: app1.com" http://192.168.56.110

# Access app2
curl -H "Host: app2.com" http://192.168.56.110

# Access app3 (default)
curl http://192.168.56.110
```

## Configuration Details

### 1. Virtual Machine Setup

The VM is configured using Alpine Linux 3.20 with minimal resources:
- 1 CPU
- 1GB of RAM
- Private network interface with static IP 192.168.56.110

### 2. Application Deployment

Each application is deployed as a Kubernetes Deployment and Service, created from a template in the `confs` directory. The `scripts/create_app.sh` script handles:
- Creating the application configuration files
- Setting the number of replicas
- Adding the necessary host rules to the Ingress configuration

### 3. Ingress Configuration

The Ingress controller is automatically configured to route traffic based on the `Host` header:
- Requests with `Host: app1.com` go to app1
- Requests with `Host: app2.com` go to app2
- All other requests go to app3 (default)

## Cleanup

To clean up the environment and remove the virtual machine, run:

```sh
vagrant destroy -f
```

## File Structure

- `Vagrantfile`: Defines the virtual machine configuration
- `scripts/setup.sh`: Main provisioning script that sets up K3s and deploys apps
- `scripts/create_app.sh`: Helper script to create application configurations
- `confs/app.template.yaml`: Template for application deployments
- `confs/network.template.yaml`: Template for Ingress configuration
- `confs/network_host.template.yaml`: Template for host rules in Ingress
