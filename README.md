# Crossplane Compositions

A collection of **Crossplane 2.0** compositions for provisioning cloud infrastructure using Kubernetes-native APIs.

[![Crossplane CI](https://github.com/pmady/crossplane/actions/workflows/crossplane-ci.yaml/badge.svg)](https://github.com/pmady/crossplane/actions/workflows/crossplane-ci.yaml)

## Available Compositions

| Composition | Description | Cloud Provider |
|-------------|-------------|----------------|
| [crossplane-eks](./crossplane-eks/) | Complete EKS cluster with VPC, subnets, and networking | AWS |

## Features

- **Crossplane 2.0** - Uses Pipeline mode with `function-patch-and-transform`
- **Production-ready** - Includes VPC, public/private subnets, NAT Gateway, and proper IAM roles
- **Configurable** - Parameterized for easy customization
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

Contributions are welcome! Please feel free to submit issues or pull requests.

## Roadmap

- [ ] Add Azure AKS composition
- [ ] Add GCP GKE composition
- [ ] Add multi-region support
- [ ] Add Helm chart deployment composition

## License

Apache 2.0
