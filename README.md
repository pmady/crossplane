# Crossplane Compositions

A collection of **Crossplane 2.0** compositions for provisioning cloud infrastructure using Kubernetes-native APIs.

[![Crossplane CI](https://github.com/pmady/crossplane/actions/workflows/crossplane-ci.yaml/badge.svg)](https://github.com/pmady/crossplane/actions/workflows/crossplane-ci.yaml)

## Available Compositions

| Composition | Description | Cloud Provider |
|-------------|-------------|----------------|
| [crossplane-eks](./crossplane-eks/) | Complete EKS cluster with VPC, subnets, and networking | AWS |
| [crossplane-s3](./crossplane-s3/) | S3 bucket with versioning, encryption, and lifecycle policies | AWS |

## Features

- **Crossplane 2.0** - Uses Pipeline mode with `function-patch-and-transform`
- **Production-ready** - Includes VPC, public/private subnets, NAT Gateway, and proper IAM roles
- **Configurable** - Parameterized for easy customization
- **EKS Add-ons Management** - Supports VPC CNI, CoreDNS, kube-proxy, and EBS CSI driver
- **CI/CD Ready** - GitHub Actions workflow for testing and package publishing

## Quick Start

### Prerequisites

- Kubernetes cluster with Crossplane 2.0+ installed
- AWS credentials configured

### Installation

```bash
# Install the function
kubectl apply -f crossplane-eks/functions.yaml

# Apply XRD and Composition
kubectl apply -f crossplane-eks/definition.yaml
kubectl apply -f crossplane-eks/composition.yaml

# Create an EKS cluster
kubectl apply -f crossplane-eks/claim.yaml
```

### EKS Add-ons Configuration

The EKS composition supports managing the following add-ons:

| Add-on | Description | Default Version |
|--------|-------------|-----------------|
| **VPC CNI** | Container networking interface for pod networking | `v1.12.6-eksbuild.1` |
| **CoreDNS** | DNS discovery service for Kubernetes | `v1.10.1-eksbuild.6` |
| **kube-proxy** | Network proxy for maintaining network rules | `v1.28.1-eksbuild.1` |
| **EBS CSI Driver** | Container Storage Interface for EBS volumes | `v1.26.1-eksbuild.1` |

#### Add-on Configuration Example

```yaml
apiVersion: aws.example.com/v1alpha1
kind: EKSCluster
metadata:
  name: my-eks-cluster
spec:
  parameters:
    region: us-west-2
    # ... other cluster parameters
    addons:
      vpcCni:
        enabled: true
        version: "v1.12.6-eksbuild.1"
        configuration:
          warmPodTarget: 2
          warmIpTarget: 2
      coreDns:
        enabled: true
        version: "v1.10.1-eksbuild.6"
        configuration:
          computeType: "EC2"
      kubeProxy:
        enabled: true
        version: "v1.28.1-eksbuild.1"
        configuration:
          mode: "iptables"
          iptables:
            masqueradeAll: false
      ebsCsiDriver:
        enabled: true
        version: "v1.26.1-eksbuild.1"
        configuration:
          mountOptions: "nfsvers=4.1"
```

#### Add-on Features

- **Configurable Versions** - Specify exact add-on versions
- **Custom Configuration** - Pass configuration values to add-ons
- **IAM Integration** - Automatic IAM role creation for add-ons that need it
- **Service Account IRSA** - IAM roles for service accounts (VPC CNI, EBS CSI)
- **Conflict Resolution** - Automatic conflict resolution for add-on updates

## Project Structure

```text
.
├── .github/workflows/       # CI/CD pipelines
│   └── crossplane-ci.yaml   # Build, test, and publish workflow
├── crossplane-eks/          # EKS composition
│   ├── definition.yaml      # XRD (CompositeResourceDefinition)
│   ├── composition.yaml     # Composition with all resources
│   ├── claim.yaml           # Example claim
│   ├── functions.yaml       # Required Crossplane functions
│   ├── crossplane.yaml      # Package configuration
│   └── tests/               # Render tests
└── README.md
```

## Testing

### Local Testing

```bash
# Validate YAML schema
./crossplane-eks/tests/validate-schema.sh

# Run render tests
./crossplane-eks/tests/validate-render.sh
```

### CI/CD Pipeline

The GitHub Actions workflow automatically:

1. Validates YAML syntax and schema
2. Runs `crossplane beta render` tests
3. Builds the Crossplane package (`.xpkg`)
4. Pushes to GitHub Container Registry (on main branch)
5. Runs integration tests on Kind cluster (on PRs)

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

## Troubleshooting

Having issues? Check our [Troubleshooting Guide](./TROUBLESHOOTING.md) for common problems and solutions.

### Pre-commit Hooks

This repository uses pre-commit hooks for code quality:

```bash
# Install pre-commit
pip install pre-commit

# Set up hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

## Roadmap

- [x] Add S3 bucket composition
- [ ] Add Azure AKS composition
- [ ] Add GCP GKE composition
- [ ] Add multi-region support
- [ ] Add Helm chart deployment composition

## License

Apache 2.0
