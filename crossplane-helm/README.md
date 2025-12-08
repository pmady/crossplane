# Crossplane Helm Deployment

This repository demonstrates how to deploy Helm charts using Crossplane.

## Prerequisites

- Kubernetes cluster
- Crossplane installed
- Helm Provider for Crossplane

## Setup

### 1. Install Crossplane

```bash
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane crossplane-stable/crossplane --namespace crossplane-system --create-namespace
```

### 2. Install Helm Provider

Apply the Helm provider configuration:

```bash
kubectl apply -f provider.yaml
```

### 3. Configure Provider

Apply the provider configuration:

```bash
kubectl apply -f provider-config.yaml
```

### 4. Deploy Helm Release

Apply the Helm release:

```bash
kubectl apply -f helm-release.yaml
```

## Files

- `provider.yaml` - Installs the Crossplane Helm Provider
- `provider-config.yaml` - Configures the Helm Provider
- `helm-release.yaml` - Example Helm Release resource

## Usage

Modify `helm-release.yaml` to deploy your desired Helm chart.
