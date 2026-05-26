# OpenStack / RHOSO / DBaaS Knowledge Baseline

> **Purpose**: Foundational knowledge document for the OpenStack RHOSO DBaaS PoC.  
> **Scope**: PoC-relevant concepts only. No production concerns (HA, monitoring, backups).  
> **Audience**: Team with zero prior OpenStack/RHOSO/DBaaS knowledge.

---

## Table of Contents

1. [OpenStack Fundamentals](#1-openstack-fundamentals)
2. [RHOSO (Red Hat OpenStack Services on OpenShift)](#2-rhoso-red-hat-openstack-services-on-openshift)
3. [DBaaS on OpenStack](#3-dbaas-on-openstack)
4. [Key CLI Commands and Workflows](#4-key-cli-commands-and-workflows)
5. [Architecture Diagrams and Descriptions](#5-architecture-diagrams-and-descriptions)
6. [Deployment Workflow for DBaaS on RHOSO](#6-deployment-workflow-for-dbaas-on-rhoso)
7. [Glossary](#7-glossary)
8. [References](#8-references)

---

## 1. OpenStack Fundamentals

### 1.1 What is OpenStack?

OpenStack is an open-source cloud computing platform that provides Infrastructure-as-a-Service (IaaS). It was launched in 2010 as a joint project between NASA and Rackspace, and is now managed by the OpenInfra Foundation. OpenStack enables organizations to build and manage private and public clouds by abstracting compute, storage, and networking resources into a unified, API-driven platform.

OpenStack is implemented as a collection of interacting services (microservices) that control compute, storage, and networking resources. Each service focuses on doing one job well, while REST APIs tie everything together into a cohesive cloud platform.

### 1.2 Core Architecture

OpenStack follows a microservices architecture where each core functionality is handled by a dedicated service. The architecture consists of:

- **Control Plane**: Services that manage and orchestrate resources (APIs, schedulers, databases, message queues)
- **Data Plane**: The actual resources being managed (hypervisors, network forwarding, storage backends)
- **Message Bus**: AMQP-based message broker (typically RabbitMQ) for inter-service communication
- **Database**: Persistent state storage (typically MariaDB/MySQL)

All services authenticate through a common Identity service (Keystone). Individual services interact with each other through public APIs, except where privileged administrator commands are necessary.

### 1.3 Core Services

#### Keystone (Identity Service)

Keystone provides authentication, authorization, and service discovery for all OpenStack services. It is the gatekeeper of the cloud.

**Key functions**:
- Authenticates users and services and issues tokens
- Defines users, projects (tenants), roles, and domains
- Publishes the service catalog (where Nova, Neutron, Cinder endpoints live)
- Supports multiple authentication mechanisms: username/password, token-based, LDAP, SAML

**Key concepts**:
- **Token**: A time-limited credential issued after successful authentication
- **Project (Tenant)**: A logical grouping of resources (VMs, networks, volumes)
- **Role**: Defines permissions within a project (e.g., `member`, `admin`)
- **Service Catalog**: Registry of all OpenStack service endpoints

#### Nova (Compute Service)

Nova is the compute engine of OpenStack, responsible for provisioning and managing virtual machines (VMs), also called "instances."

**Key functions**:
- Manages the VM lifecycle: boot, stop, start, pause, suspend, resize, migrate, delete
- Schedules instances onto compute hosts based on resources and policies
- Supports multiple hypervisors: KVM (most common), Xen, ESXi, Hyper-V
- Integrates with Neutron for networking, Cinder for block storage, Glance for images

**Key concepts**:
- **Flavor**: A template defining VM specs (vCPUs, RAM, disk)
- **Availability Zone**: A logical partition of the compute fabric for fault isolation
- **Host Aggregate**: A grouping of compute hosts with shared properties

#### Neutron (Networking Service)

Neutron provides "network connectivity as a service" between OpenStack interfaces. It enables creation and management of virtual networks, routers, and security groups.

**Key functions**:
- Creates tenant networks, subnets, and routers
- Manages security groups (firewall rules) and floating IPs
- Supports advanced services: load balancers, VPN, firewalls
- Implements software-defined networking (SDN)

**Key concepts**:
- **Network**: A virtual Layer 2 broadcast domain
- **Subnet**: An IP address block and associated configuration (gateway, DNS)
- **Router**: A virtual Layer 3 router connecting subnets
- **Security Group**: A set of firewall rules applied to VM ports
- **Floating IP**: A public IP address that can be mapped to a VM for external access
- **Port**: A virtual network interface attached to a VM

#### Glance (Image Service)

Glance acts as a registry for virtual disk images. Users can add new images or take snapshots of existing servers for immediate storage.

**Key functions**:
- Stores and retrieves VM images (boot sources)
- Supports multiple image formats: QCOW2, RAW, VMDK, VHD, ISO
- Images can be stored in backends: local filesystem, Swift, Ceph RBD, S3
- Provides image metadata and discovery

**Key concepts**:
- **Image**: A template for creating VMs (contains OS and optionally applications)
- **Snapshot**: A point-in-time capture of a running VM's disk state

#### Cinder (Block Storage Service)

Cinder provides persistent block storage management for virtual hard drives. Block storage enables users to create and delete block devices, and to manage attachment to servers.

**Key functions**:
- Creates, deletes, and manages block storage volumes
- Attaches/detaches volumes to VMs (hot-plug supported)
- Supports volume snapshots and backups
- Supports multiple storage backends: LVM, Ceph RBD, NFS, NetApp, SolidFire

**Key concepts**:
- **Volume**: A persistent block device that can be attached to a VM
- **Snapshot**: A read-only copy of a volume at a point in time
- **Volume Type**: A category of volume with specific performance/capability characteristics

#### Swift (Object Storage Service)

Swift provides object storage for unstructured data. It is not required for a minimal deployment but is useful for storing backups, artifacts, and static content.

**Key functions**:
- Stores objects (files) in containers (buckets)
- Highly scalable and fault-tolerant
- Accessible via REST API

#### Heat (Orchestration Service)

Heat provides templates to create and manage cloud resources such as storage, networking, instances, or applications.

**Key functions**:
- Uses HOT (Heat Orchestration Template) or AWS CloudFormation templates
- Creates "stacks" — collections of resources managed as a single unit
- Supports auto-scaling and resource dependencies

### 1.4 OpenStack Deployment Models

OpenStack can be deployed in several ways:

1. **Manual Installation**: Install each service individually on bare metal or VMs. Complex and time-consuming.
2. **Packaged Distributions**: Use vendor distributions like Red Hat OpenStack Platform, Canonical Charmed OpenStack, or SUSE OpenStack Cloud.
3. **Containerized Deployment**: Deploy OpenStack services as containers on Kubernetes/OpenShift (RHOSO follows this model).
4. **DevStack**: A script-based deployment for development and testing. Not for production.
5. **OpenStack-Ansible**: Uses Ansible playbooks to deploy OpenStack services in LXC containers.

### 1.5 Relationship Between OpenStack and Kubernetes/OpenShift

OpenStack and Kubernetes are complementary technologies:

- **OpenStack** provides IaaS: VMs, networks, block storage, object storage
- **Kubernetes** provides container orchestration: scheduling, scaling, self-healing of containerized applications

**Integration patterns**:
- **OpenStack on Kubernetes**: Run OpenStack control plane services as containers on Kubernetes (this is what RHOSO does)
- **Kubernetes on OpenStack**: Use OpenStack as the cloud provider for Kubernetes (Nova provides VMs, Cinder provides persistent volumes, Neutron provides networking)
- **Cloud Provider OpenStack**: Kubernetes can use OpenStack APIs to provision LoadBalancers, persistent volumes, and node VMs

---

## 2. RHOSO (Red Hat OpenStack Services on OpenShift)

### 2.1 What is RHOSO?

Red Hat OpenStack Services on OpenShift (RHOSO) is Red Hat's modern approach to delivering OpenStack. It runs OpenStack control plane services as containerized workloads on Red Hat OpenShift Container Platform (RHOCP), while the data plane (compute nodes) runs on external Red Hat Enterprise Linux (RHEL) nodes.

**Key differences from traditional OpenStack**:
- Control plane is container-native, running as pods on OpenShift
- Uses Kubernetes Operators for lifecycle management
- Data plane nodes are managed via Ansible execution environments
- Aligns with Red Hat's platform infrastructure strategy
- Replaces the older TripleO (OpenStack on OpenStack) deployment method

### 2.2 Architecture

RHOSO has a two-plane architecture:

#### Control Plane

The RHOSO control plane is hosted and managed as a workload on an operational RHOCP cluster. It consists of:

- OpenStack controller services running as pods (Nova API, Neutron API, Keystone, Glance, Cinder, etc.)
- Each service is managed by its own Operator
- The `openstack-operator` is the top-level Operator that installs and manages all service Operators
- Services communicate via OpenShift networking and service mesh

**Key Operators**:
- `openstack-operator`: Top-level operator that deploys all other service operators
- `nova-operator`: Manages Nova compute controller services
- `neutron-operator`: Manages Neutron networking controller services
- `keystone-operator`: Manages Keystone identity services
- `glance-operator`: Manages Glance image services
- `cinder-operator`: Manages Cinder block storage services
- `mariadb-operator`: Manages the MariaDB database for OpenStack services
- `rabbitmq-operator`: Manages the RabbitMQ message bus

#### Data Plane

The RHOSO data plane consists of external RHEL nodes that host OpenStack workloads (VMs). These nodes are managed by the OpenStack Operator using Ansible.

**Key concepts**:
- **OpenStackDataPlaneNodeSet**: A CRD that defines a logical grouping of data plane nodes (e.g., compute nodes, networker nodes)
- **OpenStackDataPlaneDeployment**: A CRD that triggers Ansible execution to deploy and configure data plane nodes
- **EDPM (External Data Plane Management)**: The framework for managing RHEL data plane nodes

### 2.3 Deployment Workflow on OpenShift

The high-level RHOSO deployment workflow is:

1. **Prepare RHOCP cluster**: Ensure worker nodes are configured, networks are prepared
2. **Install OpenStack Operator**: Install `openstack-operator` from OperatorHub
3. **Create namespace**: Create a namespace for RHOSO (e.g., `openstack`)
4. **Configure networks**: Use NMState Operator to connect worker nodes to isolated networks; create `NetConfig` CR for data plane networks
5. **Create control plane**: Define and apply `OpenStackControlPlane` CR
6. **Create data plane**: Define `OpenStackDataPlaneNodeSet` CR(s) and `OpenStackDataPlaneDeployment` CR
7. **Verify deployment**: Check pods, run OpenStack CLI commands

### 2.4 Namespace and Pod Structure

RHOSO services run in a dedicated namespace (typically `openstack`).

**Key pods**:
- `openstackclient`: A pre-configured pod with OpenStack CLI tools and admin credentials
- Service pods: `nova-api`, `neutron-api`, `keystone-api`, `glance-api`, `cinder-api`, etc.
- Infrastructure pods: `mariadb`, `rabbitmq`, `memcached`
- Operator pods: `openstack-operator`, `nova-operator`, `neutron-operator`, etc.

### 2.5 CLI Tools and Commands Specific to RHOSO

RHOSO uses a combination of OpenShift (`oc`) and OpenStack (`openstack`) CLI tools.

**OpenShift CLI (`oc`)**:
```bash
# Access the OpenStack client pod
oc rsh -n openstack openstackclient

# List pods in the openstack namespace
oc get pods -n openstack

# View OpenStack control plane status
oc get openstackcontrolplane -n openstack

# View data plane node sets
oc get openstackdataplanenodeset -n openstack

# View data plane deployments
oc get openstackdataplanedeployment -n openstack

# Check Ansible execution logs
oc logs -l app=openstackansibleee -n openstack -f --max-log-requests 10
```

**OpenStack CLI (inside `openstackclient` pod)**:
```bash
# After running `oc rsh -n openstack openstackclient`:
openstack endpoint list
openstack compute service list
openstack network agent list
openstack hypervisor list
```

### 2.6 Topologies

RHOSO supports two control plane topologies:

1. **Compact topology** (default): RHOSO control plane and RHOCP control plane share the same physical nodes. Minimum hardware footprint.
2. **Dedicated nodes topology**: RHOCP control plane runs on one set of physical nodes, and the RHOSO control plane runs on another set. Better isolation and performance.

### 2.7 Prerequisites and Requirements

- Operational RHOCP cluster (master and worker nodes with x86_64 architecture)
- RHEL 9.4 or 9.6 nodes for the data plane
- Red Hat subscriptions for RHOCP and RHOSO
- Network isolation for control plane, internal API, storage, and external traffic
- Sufficient compute, memory, and storage resources

---

## 3. DBaaS on OpenStack

### 3.1 What is DBaaS?

Database as a Service (DBaaS) is a cloud computing service model that provides users with on-demand access to a database without requiring them to set up the underlying hardware and software, or handle ongoing database administration.

In the context of OpenStack, DBaaS allows users to provision and manage database instances through OpenStack APIs and CLI, just like they provision VMs through Nova.

### 3.2 OpenStack Trove

Trove is OpenStack's native DBaaS project. It provides scalable and reliable cloud database provisioning functionality for both relational and non-relational database engines.

**Supported databases** (varies by release):
- MySQL / MariaDB
- PostgreSQL
- Redis
- MongoDB
- Cassandra
- Couchbase
- DB2 (historical)

#### Trove Architecture

Trove consists of several components:

1. **trove-api**: Receives and routes API requests. Stateless, can be scaled horizontally.
2. **trove-taskmanager**: Orchestrates complex workflows (create instance, resize, backup, restore). Communicates with guest agents.
3. **trove-conductor**: Receives guest agent status updates and writes them to the database.
4. **trove-guestagent**: Runs inside the database VM. Communicates with the task manager and conductor. Manages the database lifecycle locally.

**Data flow**:
- User sends request to `trove-api`
- `trove-api` forwards to `trove-taskmanager`
- `trove-taskmanager` provisions a VM via Nova, attaches storage via Cinder, configures networking via Neutron
- `trove-guestagent` inside the VM configures the database engine, creates databases/users
- `trove-conductor` receives status updates from the guest agent

#### Trove CLI Commands and Workflows

**Prerequisites**: Trove must be installed and configured in the OpenStack environment.

```bash
# List available datastores (database types)
openstack datastore list
openstack datastore version list mysql

# Create a database flavor (if not already existing)
openstack flavor create db.small --ram 2048 --disk 20 --vcpus 2

# Create a database instance
openstack database instance create mydb \
    --flavor db.small \
    --size 20 \
    --nic net-id=<network-id> \
    --databases myapp \
    --users admin:secretpassword \
    --datastore mysql \
    --datastore-version 8.0

# List database instances
openstack database instance list

# Show database instance details
openstack database instance show <instance-id>

# Delete a database instance
openstack database instance delete <instance-id>

# Create a backup
openstack database backup create mydb-backup --instance <instance-id>

# List backups
openstack database backup list

# Restore from backup
openstack database instance create mydb-restored \
    --flavor db.small \
    --size 20 \
    --backup <backup-id> \
    --datastore mysql \
    --datastore-version 8.0

# Manage databases and users on an instance
openstack database db create <instance-id> newdb
openstack database user create <instance-id> newuser newpassword
openstack database user list <instance-id>
```

#### Trove Installation Overview

For a PoC, Trove can be installed via:

1. **DevStack**: Enable the Trove plugin in `local.conf`
2. **Manual installation**: Install `trove-api`, `trove-taskmanager`, `trove-conductor`, and `python-troveclient`
3. **OpenStack-Ansible**: Use the Trove role

**Key configuration steps**:
- Create Trove service user and endpoints in Keystone
- Configure `trove.conf` with database connections, messaging, and service credentials
- Configure `trove-guestagent.conf` for guest VM communication
- Register datastore versions and images in Glance
- Initialize the Trove database schema

### 3.3 Alternatives to Trove

While Trove is the native OpenStack DBaaS, there are alternatives:

#### Cloud-Native Database Operators

These run directly on Kubernetes/OpenShift and can be used alongside or instead of Trove:

- **CrunchyData PostgreSQL Operator**: Enterprise PostgreSQL on Kubernetes
- **Percona Operator for MySQL/PostgreSQL/MongoDB**: Open-source database operators
- **MariaDB Operator**: For MariaDB deployments
- **Redis Operator**: For Redis clusters
- **MongoDB Community Operator**: For MongoDB on Kubernetes

**Trade-offs**:
- **Trove**: Native OpenStack integration, unified API, tenant isolation via OpenStack projects
- **Cloud-Native Operators**: More modern, Kubernetes-native, better ecosystem support, but not integrated with OpenStack identity/networking

#### Custom Operators on RHOSO

Since RHOSO runs on OpenShift, you can deploy database operators in the same cluster or a dedicated namespace. However, for a PoC focused on OpenStack DBaaS, Trove is the most relevant path.

### 3.4 Database Lifecycle Operations

The typical DBaaS lifecycle includes:

1. **Provision**: Create a database instance with specified flavor, storage, network, and credentials
2. **Configure**: Set database parameters, create databases and users
3. **Access**: Connect to the database using the assigned IP address
4. **Scale**: Resize the instance (flavor or volume) as needed
5. **Backup**: Create point-in-time snapshots
6. **Restore**: Recover from a backup
7. **Decommission**: Delete the instance and release resources

### 3.5 Integration with OpenStack Services

DBaaS on OpenStack integrates with core services:

- **Keystone**: Authentication and authorization for DBaaS users
- **Nova**: Provisioning of VMs to host database instances
- **Neutron**: Network configuration for database instances (private and public access)
- **Cinder**: Persistent block storage for database data
- **Glance**: Storage of database guest images (OS + database engine pre-installed)
- **Swift** (optional): Object storage for backups

---

## 4. Key CLI Commands and Workflows

### 4.1 Authentication Setup

Before running OpenStack CLI commands, you must source credentials:

```bash
# Source the OpenStack RC file (provided by your cloud admin)
source ~/keystonerc_admin

# Or set environment variables manually
export OS_AUTH_URL=http://keystone:5000/v3
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=secret
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_IDENTITY_API_VERSION=3
```

### 4.2 Identity (Keystone)

```bash
# List users
openstack user list

# List projects
openstack project list

# List roles
openstack role list

# Show service catalog
openstack catalog list

# Show token info
openstack token issue
```

### 4.3 Compute (Nova)

```bash
# List flavors
openstack flavor list

# Create a flavor
openstack flavor create m1.small --ram 2048 --disk 20 --vcpus 1

# List images
openstack image list

# Boot an instance
openstack server create --image cirros --flavor m1.small --network private my-vm

# List instances
openstack server list

# Show instance details
openstack server show my-vm

# Stop / start / delete an instance
openstack server stop my-vm
openstack server start my-vm
openstack server delete my-vm

# List hypervisors
openstack hypervisor list

# Show compute services
openstack compute service list
```

### 4.4 Networking (Neutron)

```bash
# List networks
openstack network list

# Create a network
openstack network create my-network

# Create a subnet
openstack subnet create --network my-network --subnet-range 192.168.1.0/24 my-subnet

# List routers
openstack router list

# Create a router and connect subnet
openstack router create my-router
openstack router add subnet my-router my-subnet

# List security groups
openstack security group list

# Create security group rules
openstack security group rule create --protocol tcp --dst-port 22 --remote-ip 0.0.0.0/0 default

# Allocate and associate floating IP
openstack floating ip create public
openstack server add floating ip my-vm <floating-ip>
```

### 4.5 Block Storage (Cinder)

```bash
# List volumes
openstack volume list

# Create a volume
openstack volume create --size 10 my-volume

# Attach volume to instance
openstack server volume attach my-vm my-volume

# Detach volume
openstack server volume detach my-vm my-volume

# Delete volume
openstack volume delete my-volume
```

### 4.6 Image (Glance)

```bash
# List images
openstack image list

# Upload an image
openstack image create --file cirros-0.6.2-x86_64-disk.img --disk-format qcow2 --container-format bare cirros

# Show image details
openstack image show cirros

# Delete an image
openstack image delete cirros
```

### 4.7 RHOSO-Specific Workflows

```bash
# Access the OpenStack client pod in RHOSO
oc rsh -n openstack openstackclient

# Inside the pod, all openstack commands work as usual
openstack endpoint list
openstack server list
openstack network list

# Check control plane status from OpenShift
oc get openstackcontrolplane -n openstack
oc get pods -n openstack

# Check data plane status
oc get openstackdataplanenodeset -n openstack
oc get openstackdataplanedeployment -n openstack

# View Ansible logs for data plane deployment
oc logs -l app=openstackansibleee -n openstack -f --max-log-requests 10

# Verify compute nodes are registered
oc rsh -n openstack openstackclient
openstack hypervisor list
```

---

## 5. Architecture Diagrams and Descriptions

### 5.1 Traditional OpenStack Logical Architecture

```
+-------------------------------------------------------------+
|                        Users / Admins                        |
|         (Horizon Dashboard | CLI | SDK | REST API)          |
+-------------------------------------------------------------+
                              |
+-------------------------------------------------------------+
|                      Keystone (Identity)                     |
|              Authentication, Authorization, Catalog            |
+-------------------------------------------------------------+
                              |
        +-------------------+-------------------+
        |                   |                   |
+-------v-------+  +--------v--------+  +------v------+
| Nova (Compute)|  | Neutron (Network)|  |Cinder(Block)|
|  - API        |  |  - API           |  |  - API      |
|  - Scheduler  |  |  - L2/L3 Agents  |  |  - Volume   |
|  - Conductor  |  |  - DHCP Agent    |  |  - Scheduler|
|  - Compute    |  |  - Metadata Agent|  |             |
+-------+-------+  +--------+---------+  +------+------+
        |                   |                   |
        +-------------------+-------------------+
                              |
+-------------------------------------------------------------+
|              Message Queue (RabbitMQ) + Database (MariaDB)   |
+-------------------------------------------------------------+
                              |
        +-------------------+-------------------+
        |                   |                   |
+-------v-------+  +--------v--------+  +------v------+
|  Hypervisors  |  |  Network Nodes   |  | Storage     |
|  (KVM, etc.)  |  |  (OVS, OVN)      |  | Backends    |
+---------------+  +------------------+  +-------------+
```

### 5.2 RHOSO Architecture

```
+-------------------------------------------------------------+
|                    Red Hat OpenShift (RHOCP)                 |
|  +-------------------------------------------------------+  |
|  |              RHOSO Control Plane (Pods)                |  |
|  |  +----------+ +----------+ +----------+ +--------+ |  |
|  |  | Keystone | |  Nova    | | Neutron  | | Cinder | |  |
|  |  |  (pod)   | |  (pod)   | |  (pod)   | | (pod)  | |  |
|  |  +----------+ +----------+ +----------+ +--------+ |  |
|  |  +----------+ +----------+ +----------+ +--------+ |  |
|  |  |  Glance  | |  MariaDB | | RabbitMQ | |  Heat  | |  |
|  |  |  (pod)   | |  (pod)   | |  (pod)   | | (pod)  | |  |
|  |  +----------+ +----------+ +----------+ +--------+ |  |
|  |  +------------------------------------------------+ |  |
|  |  |        openstack-operator (top-level)          | |  |
|  |  +------------------------------------------------+ |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
                              |
                    Ansible (EE pod)
                              |
+-------------------------------------------------------------+
|                    RHOSO Data Plane (RHEL Nodes)             |
|  +------------------+ +------------------+ +-------------+ |
|  |  Compute Node 0  | |  Compute Node 1  | |  Networker  | |
|  |  (Nova Compute)  | |  (Nova Compute)  | |  (OVN, etc.)| |
|  +------------------+ +------------------+ +-------------+ |
+-------------------------------------------------------------+
```

### 5.3 Trove DBaaS Architecture

```
+-------------------------------------------------------------+
|                         User / Admin                         |
+-------------------------------------------------------------+
                              |
+-------------------------------------------------------------+
|  Trove API  -->  Trove Task Manager  -->  Trove Conductor   |
+-------------------------------------------------------------+
        |                |                    ^
        |                | (provisions VM)     | (status updates)
        v                v                    |
+-------------------------------------------------------------+
|  OpenStack Services: Nova + Neutron + Cinder + Glance        |
+-------------------------------------------------------------+
                              |
+-------------------------------------------------------------+
|              Database Instance VM (Trove Guest)              |
|  +-------------------------------------------------------+  |
|  |  OS + Database Engine (MySQL/PostgreSQL/etc.)         |  |
|  |  + Trove Guest Agent                                  |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
```

---

## 6. Deployment Workflow for DBaaS on RHOSO

This section outlines the conceptual workflow for deploying DBaaS on a RHOSO environment. This is a PoC-level workflow, not a production deployment guide.

### 6.1 Prerequisites

- Operational RHOCP cluster with RHOSO deployed
- Control plane and data plane are functional
- OpenStack CLI access via `openstackclient` pod
- Trove service installed and configured (or alternative DBaaS solution)

### 6.2 Step-by-Step Workflow

#### Step 1: Verify RHOSO Environment

```bash
# Check control plane pods
oc get pods -n openstack

# Access OpenStack CLI
oc rsh -n openstack openstackclient

# Verify core services
openstack endpoint list
openstack compute service list
openstack network agent list
```

#### Step 2: Prepare DBaaS Service

If using Trove:

```bash
# Verify Trove service is registered
openstack service list | grep database
openstack endpoint list | grep database

# List available datastores
openstack datastore list
openstack datastore version list mysql
```

If Trove is not installed, it must be deployed. For a PoC, this may involve:
- Installing Trove control plane services (API, Taskmanager, Conductor)
- Building and registering Trove guest images in Glance
- Configuring Trove to use the RHOSO Neutron network and Nova compute

#### Step 3: Create Database Instance

```bash
# Identify the network for database instances
openstack network list

# Identify or create a suitable flavor
openstack flavor list
# OR
openstack flavor create db.tiny --ram 1024 --disk 10 --vcpus 1

# Create the database instance
openstack database instance create poc-db \
    --flavor db.tiny \
    --size 10 \
    --nic net-id=<private-network-id> \
    --databases testdb \
    --users dbuser:dbpassword \
    --datastore mysql \
    --datastore-version 8.0

# Monitor instance creation
openstack database instance list
openstack database instance show poc-db
```

#### Step 4: Access and Verify Database

```bash
# Get the database instance IP
openstack database instance show poc-db

# Connect to the database (from a VM in the same network or with floating IP)
mysql -h <db-instance-ip> -u dbuser -pdbpassword -e "SHOW DATABASES;"

# Create a test table
mysql -h <db-instance-ip> -u dbuser -pdbpassword testdb -e "CREATE TABLE test (id INT); INSERT INTO test VALUES (1); SELECT * FROM test;"
```

#### Step 5: Cleanup (PoC)

```bash
# Delete the database instance
openstack database instance delete poc-db
```

### 6.3 Alternative: Cloud-Native DB Operator on RHOSO

If Trove is not available, an alternative PoC path is to deploy a database operator directly on the OpenShift cluster:

```bash
# Example: Deploy PostgreSQL using CloudNativePG operator
oc apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.22/releases/cnpg-1.22.0.yaml

# Create a PostgreSQL cluster
oc apply -f - <<EOF
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: poc-postgres
  namespace: openstack
spec:
  instances: 1
  storage:
    size: 10Gi
  postgresql:
    version: "16"
EOF

# Verify
oc get cluster -n openstack
oc get pods -n openstack -l app=poc-postgres
```

**Note**: This alternative does not use OpenStack APIs for database provisioning and is outside the scope of a pure OpenStack DBaaS PoC. It is documented here for awareness only.

---

## 7. Glossary

| Term | Definition |
|------|------------|
| **OpenStack** | Open-source cloud computing platform providing IaaS |
| **RHOSO** | Red Hat OpenStack Services on OpenShift |
| **RHOCP** | Red Hat OpenShift Container Platform |
| **IaaS** | Infrastructure as a Service |
| **DBaaS** | Database as a Service |
| **Nova** | OpenStack Compute service |
| **Neutron** | OpenStack Networking service |
| **Keystone** | OpenStack Identity service |
| **Glance** | OpenStack Image service |
| **Cinder** | OpenStack Block Storage service |
| **Swift** | OpenStack Object Storage service |
| **Heat** | OpenStack Orchestration service |
| **Trove** | OpenStack Database service (DBaaS) |
| **Operator** | Kubernetes pattern for automating deployment and management of applications |
| **CR / CRD** | Custom Resource / Custom Resource Definition (Kubernetes) |
| **Control Plane** | Services that manage and orchestrate cloud resources |
| **Data Plane** | Nodes that run actual workloads (VMs, containers) |
| **EDPM** | External Data Plane Management (RHOSO) |
| **Flavor** | A template defining VM specs (vCPUs, RAM, disk) |
| **Instance** | A virtual machine in OpenStack |
| **Project** | A logical grouping of resources in OpenStack (also called Tenant) |
| **Floating IP** | A public IP address mapped to a VM for external access |
| **Security Group** | A set of firewall rules applied to VM ports |
| **HOT** | Heat Orchestration Template |

---

## 8. References

- [OpenStack Documentation](https://docs.openstack.org/)
- [OpenStack Install Guide](https://docs.openstack.org/install-guide/)
- [Red Hat OpenStack Services on OpenShift 18.0 Documentation](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0/)
- [Trove Documentation](https://docs.openstack.org/trove/latest/)
- [OpenStack CLI Cheat Sheet](https://docs.openstack.org/newton/user-guide/cli-cheat-sheet.html)
- [Red Hat Developer - RHOSO Data Plane Deployment](https://developers.redhat.com/articles/2024/05/08/red-hat-openshift-101-openstack-admins-data-plane-deployment)
- [OpenStack Architecture Guide (Red Hat)](https://docs.redhat.com/en/documentation/red_hat_openstack_platform/10/html-single/architecture_guide/index)
- [OpenStack Microservice Architecture (Cloudification)](https://cloudification.io/cloud-blog/openstack-microservice-architecture-main-components/)

---

*Document generated for the OpenStack RHOSO DBaaS PoC. Focus: PoC-relevant knowledge. No production concerns.*
