# Contributing to Crossplane Compositions

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this repository.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Environment](#development-environment)
- [Code Style Guidelines](#code-style-guidelines)
- [Running Tests](#running-tests)
- [Submitting Changes](#submitting-changes)
- [Issue Reporting](#issue-reporting)

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/crossplane.git
   cd crossplane
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/pmady/crossplane.git
   ```

## Development Environment

### Prerequisites

- **Kubernetes cluster** (Kind, Minikube, or cloud-based)
- **kubectl** v1.28+
- **Crossplane CLI** v2.0+
- **Helm** v3.x (optional, for Helm-based installations)

### Installing Crossplane CLI

```bash
# macOS
brew install crossplane/tap/crossplane

# Linux
curl -sL https://raw.githubusercontent.com/crossplane/crossplane/master/install.sh | sh
sudo mv crossplane /usr/local/bin/
```

### Setting Up a Local Cluster

```bash
# Create a Kind cluster
kind create cluster --name crossplane-dev

# Install Crossplane
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane crossplane-stable/crossplane \
  --namespace crossplane-system \
  --create-namespace

# Verify installation
kubectl get pods -n crossplane-system
```

### Installing Required Functions

```bash
kubectl apply -f crossplane-eks/functions.yaml
```

## Code Style Guidelines

### YAML Files

- Use **2 spaces** for indentation (no tabs)
- Include comments for complex configurations
- Follow Kubernetes naming conventions (lowercase, hyphens)
- Keep lines under 120 characters when possible

### Naming Conventions

| Resource Type | Convention | Example |
|---------------|------------|---------|
| Compositions | `<provider>-<resource>` | `aws-eks-cluster` |
| XRDs | `X<Resource>` | `XEKSCluster` |
| Claims | `<resource>` | `ekscluster` |

### File Structure

Each composition should follow this structure:

```text
crossplane-<name>/
├── README.md           # Documentation
├── definition.yaml     # XRD (CompositeResourceDefinition)
├── composition.yaml    # Composition with resources
├── claim.yaml          # Example claim
├── functions.yaml      # Required Crossplane functions
├── crossplane.yaml     # Package configuration
└── tests/              # Render tests
    ├── claim-test.yaml
    └── expected-output.yaml
```

## Running Tests

### YAML Validation

```bash
# Validate YAML syntax
yamllint crossplane-eks/

# Validate Kubernetes schema
kubectl apply --dry-run=client -f crossplane-eks/definition.yaml
kubectl apply --dry-run=client -f crossplane-eks/composition.yaml
```

### Render Tests

Render tests verify that compositions produce expected output:

```bash
# Run render tests
cd crossplane-eks/tests
./validate-render.sh

# Or manually
crossplane beta render claim-test.yaml ../composition.yaml ../functions.yaml
```

### Integration Tests

```bash
# Apply resources to a test cluster
kubectl apply -f crossplane-eks/definition.yaml
kubectl apply -f crossplane-eks/composition.yaml

# Create a test claim
kubectl apply -f crossplane-eks/claim.yaml

# Check status
kubectl get composite
kubectl get managed
```

## Submitting Changes

### Branch Naming

Use descriptive branch names:
- `feature/add-gke-composition`
- `fix/eks-subnet-cidr`
- `docs/update-readme`

### Commit Messages

Follow conventional commit format:

```text
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Adding or updating tests
- `refactor`: Code refactoring
- `chore`: Maintenance tasks

**Examples:**
```text
feat(eks): add multi-region support
fix(composition): correct IAM role ARN reference
docs(readme): add troubleshooting section
```

### Pull Request Process

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature
   ```

2. **Make your changes** and commit:
   ```bash
   git add .
   git commit -m "feat(scope): description"
   ```

3. **Push to your fork**:
   ```bash
   git push origin feature/your-feature
   ```

4. **Open a Pull Request** on GitHub

5. **PR Requirements**:
   - Clear description of changes
   - All tests passing
   - Documentation updated (if applicable)
   - No merge conflicts

### Code Review

- Address all review comments
- Keep discussions constructive
- Request re-review after making changes

## Issue Reporting

### Bug Reports

Include:
- **Description**: Clear description of the bug
- **Steps to Reproduce**: Minimal steps to reproduce
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Environment**: Crossplane version, Kubernetes version, cloud provider

### Feature Requests

Include:
- **Use Case**: Why is this feature needed?
- **Proposed Solution**: How should it work?
- **Alternatives Considered**: Other approaches you've thought about

### Good First Issues

Check [GOOD_FIRST_ISSUES.md](./GOOD_FIRST_ISSUES.md) for beginner-friendly issues.

## Questions?

- Open a [Discussion](https://github.com/pmady/crossplane/discussions)
- Check existing [Issues](https://github.com/pmady/crossplane/issues)
- Review [Crossplane Documentation](https://docs.crossplane.io/)

Thank you for contributing!
