# Part 1: _K3s_ and _Vagrant_

This project sets up a lightweight Kubernetes cluster using _K3s_, orchestrated by _Vagrant_ and VirtualBox. The architecture consists of a single server node and a single worker node. The server node runs the _K3s_ server, while the worker node joins the cluster and runs workloads.

## Prerequisites

Before you begin, ensure you have the following installed on your machine:
- _Vagrant_
- _VirtualBox_

## Build process

To start the _Vagrant_ environment, navigate to the project directory and run the following command:

```sh
vagrant up
```

This command will:
- Create and configure the server and worker virtual machines.
- Provision the server with _K3s_.
- Provision the worker and join it to the _K3s_ cluster.

## Configuration Details
### 1. Server Node Configuration

The server node is configured using the `scripts/setup_server.sh` script. This script:
- Downloads and installs _K3s_.
- Configures _K3s_ to use the eth1 network interface for communication.
- Waits for the _K3s_ server to generate the node token.
- Copies the node token to a shared location where the credentials can be accessed by the worker node.
- Adds an alias for `kubectl` to the server's profile.

### 2. Worker Node Configuration

The worker node is configured using the `scripts/setup_worker.sh` script. This script:
- Downloads and installs _K3s_.
- Configures _K3s_ to join the server node using the server's IP address and the node token.
- Adds an alias for `kubectl` to the worker's profile.

## Usage

Once the environment is up and running, you can interact with the Kubernetes cluster using `kubectl`. The `kubectl` command is aliased to `k` on both the server and worker nodes. For example, to get the list of nodes in the cluster, _SSH_ into the server node and run:

```sh
vagrant ssh "${USER}S"
k get nodes -o wide
```

## Cleanup

To clean up the environment and remove the virtual machines, run:

```sh
vagrant destroy -f
```

This command will stop and delete all the virtual machines created by _Vagrant_.
