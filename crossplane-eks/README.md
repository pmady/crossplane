# Crossplane 2.0 AWS EKS Composition Example

This example demonstrates how to create an AWS EKS cluster with VPC, subnets, and all required networking components using **Crossplane 2.0** Compositions with Pipeline mode and XRDs.

## Components Created

This composition creates the following AWS resources:

### Networking

- **VPC** - Virtual Private Cloud with DNS support
- **Internet Gateway** - For public internet access
- **NAT Gateway** - For private subnet outbound access
- **Elastic IP** - For NAT Gateway
- **Public Subnets (2)** - In different availability zones
- **Private Subnets (2)** - In different availability zones
- **Route Tables** - Public and private route tables
- **Routes** - Internet Gateway route for public, NAT Gateway route for private
- **Route Table Associations** - Linking subnets to route tables

### IAM

- **EKS Cluster Role** - IAM role for EKS control plane
- **EKS Node Role** - IAM role for worker nodes
- **Policy Attachments** - Required AWS managed policies

### EKS

- **EKS Cluster** - Kubernetes control plane
- **EKS Node Group** - Managed worker nodes in private subnets

## Prerequisites

1. **Crossplane 2.0+** installed on your Kubernetes cluster

2. **Function Patch and Transform** installed:

   ```bash
   kubectl apply -f functions.yaml
   ```

3. **AWS Provider** installed and configured:

   ```bash
   kubectl apply -f - <<EOF
   apiVersion: pkg.crossplane.io/v1
   kind: Provider
   metadata:
     name: provider-aws-eks
   spec:
     package: xpkg.upbound.io/upbound/provider-aws-eks:v1.1.0
   EOF
   
   kubectl apply -f - <<EOF
   apiVersion: pkg.crossplane.io/v1
   kind: Provider
   metadata:
     name: provider-aws-ec2
   spec:
     package: xpkg.upbound.io/upbound/provider-aws-ec2:v1.1.0
   EOF
   
   kubectl apply -f - <<EOF
   apiVersion: pkg.crossplane.io/v1
   kind: Provider
   metadata:
     name: provider-aws-iam
   spec:
     package: xpkg.upbound.io/upbound/provider-aws-iam:v1.1.0
   EOF
   ```

4. **AWS ProviderConfig** with credentials:

   ```bash
   kubectl apply -f - <<EOF
   apiVersion: aws.upbound.io/v1beta1
   kind: ProviderConfig
   metadata:
     name: default
   spec:
     credentials:
       source: Secret
       secretRef:
         namespace: crossplane-system
         name: aws-secret
         key: creds
   EOF
   ```

## Installation

1. **Install the Function**:

   ```bash
   kubectl apply -f functions.yaml
   ```

2. **Apply the XRD (CompositeResourceDefinition)**:

   ```bash
   kubectl apply -f definition.yaml
   ```

3. **Apply the Composition**:

   ```bash
   kubectl apply -f composition.yaml
   ```

4. **Create an EKS cluster using the Claim**:

   ```bash
   kubectl apply -f claim.yaml
   ```

## Configuration Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `region` | AWS region | `us-west-2` |
| `vpcCidrBlock` | CIDR block for VPC | `10.0.0.0/16` |
| `publicSubnet1Cidr` | CIDR for public subnet 1 | `10.0.1.0/24` |
| `publicSubnet2Cidr` | CIDR for public subnet 2 | `10.0.2.0/24` |
| `privateSubnet1Cidr` | CIDR for private subnet 1 | `10.0.3.0/24` |
| `privateSubnet2Cidr` | CIDR for private subnet 2 | `10.0.4.0/24` |
| `k8sVersion` | Kubernetes version | `1.28` |
| `nodeInstanceType` | EC2 instance type for nodes | `t3.medium` |
| `desiredNodeCount` | Desired number of nodes | `2` |
| `minNodeCount` | Minimum number of nodes | `1` |
| `maxNodeCount` | Maximum number of nodes | `5` |

## Monitoring Progress

Check the status of your resources:

```bash
# Check the claim status
kubectl get ekscluster my-eks-cluster -o yaml

# Check all composed resources
kubectl get managed -l crossplane.io/claim-name=my-eks-cluster

# Check specific resource types
kubectl get vpc,subnet,internetgateway,natgateway,routetable
kubectl get cluster.eks,nodegroup.eks
kubectl get role.iam,rolepolicyattachment.iam
```

## Cleanup

To delete all resources:

```bash
kubectl delete -f claim.yaml
```

This will delete the claim and all composed resources (VPC, subnets, EKS cluster, etc.).

## Architecture Diagram

```text
┌─────────────────────────────────────────────────────────────────┐
│                            VPC                                   │
│                       (10.0.0.0/16)                             │
│                                                                  │
│  ┌─────────────────────────┐  ┌─────────────────────────┐      │
│  │   Public Subnet 1       │  │   Public Subnet 2       │      │
│  │   (10.0.1.0/24)         │  │   (10.0.2.0/24)         │      │
│  │   AZ: region-a          │  │   AZ: region-b          │      │
│  │                         │  │                         │      │
│  │   ┌─────────────────┐   │  │                         │      │
│  │   │  NAT Gateway    │   │  │                         │      │
│  │   └─────────────────┘   │  │                         │      │
│  └───────────┬─────────────┘  └─────────────────────────┘      │
│              │                                                   │
│              │ Internet Gateway                                  │
│              ▼                                                   │
│  ┌─────────────────────────┐  ┌─────────────────────────┐      │
│  │   Private Subnet 1      │  │   Private Subnet 2      │      │
│  │   (10.0.3.0/24)         │  │   (10.0.4.0/24)         │      │
│  │   AZ: region-a          │  │   AZ: region-b          │      │
│  │                         │  │                         │      │
│  │   ┌─────────────────┐   │  │   ┌─────────────────┐   │      │
│  │   │  EKS Nodes      │   │  │   │  EKS Nodes      │   │      │
│  │   └─────────────────┘   │  │   └─────────────────┘   │      │
│  └─────────────────────────┘  └─────────────────────────┘      │
│                                                                  │
│                    ┌─────────────────┐                          │
│                    │  EKS Control    │                          │
│                    │  Plane          │                          │
│                    └─────────────────┘                          │
└─────────────────────────────────────────────────────────────────┘
```

## Notes

- The EKS cluster is created with both public and private endpoint access
- Worker nodes are deployed in private subnets for security
- Public subnets are tagged for ELB usage (`kubernetes.io/role/elb`)
- Private subnets are tagged for internal ELB usage (`kubernetes.io/role/internal-elb`)
- NAT Gateway provides outbound internet access for nodes in private subnets
- Uses Crossplane 2.0 Pipeline mode with `function-patch-and-transform`
