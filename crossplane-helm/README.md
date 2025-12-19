# Crossplane Helm Deployment

Deploy and manage Helm charts using Crossplane's declarative approach. This enables GitOps workflows for Helm releases with full Kubernetes-native management.

## Prerequisites

- Kubernetes cluster (v1.25+)
- Crossplane installed (v1.14+)
- Helm Provider for Crossplane

## Quick Start

### 1. Install Crossplane

```bash
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane crossplane-stable/crossplane \
  --namespace crossplane-system \
  --create-namespace \
  --wait
```

### 2. Install Helm Provider

```bash
kubectl apply -f provider.yaml

# Wait for provider to be healthy
kubectl wait --for=condition=healthy provider/provider-helm --timeout=300s
```

### 3. Configure Provider

```bash
kubectl apply -f rbac.yaml
kubectl apply -f provider-config.yaml
```

### 4. Deploy Helm Release

```bash
kubectl apply -f helm-release.yaml

# Check status
kubectl get release nginx-ingress -o yaml
```

## Available Examples

| Example | Description | Namespace |
|---------|-------------|-----------|
| [nginx-ingress](./helm-release.yaml) | NGINX Ingress Controller | `ingress-nginx` |
| [cert-manager](./examples/cert-manager.yaml) | Certificate management | `cert-manager` |
| [external-dns](./examples/external-dns.yaml) | DNS record management | `external-dns` |
| [prometheus-stack](./examples/prometheus-stack.yaml) | Full monitoring stack | `monitoring` |
| [argocd](./examples/argocd.yaml) | GitOps continuous delivery | `argocd` |
| [metrics-server](./examples/metrics-server.yaml) | Resource metrics | `kube-system` |

### Deploy an Example

```bash
# Deploy cert-manager
kubectl apply -f examples/cert-manager.yaml

# Deploy monitoring stack
kubectl apply -f examples/prometheus-stack.yaml

# Deploy ArgoCD
kubectl apply -f examples/argocd.yaml
```

## Files

| File | Description |
|------|-------------|
| `provider.yaml` | Installs the Crossplane Helm Provider |
| `provider-config.yaml` | Configures the Helm Provider with cluster access |
| `rbac.yaml` | RBAC permissions for the Helm Provider |
| `helm-release.yaml` | Example NGINX Ingress release |
| `examples/` | Additional Helm release examples |

## Common Use Cases

### Deploy a Chart from a Private Repository

```yaml
apiVersion: helm.crossplane.io/v1beta1
kind: Release
metadata:
  name: my-private-chart
spec:
  forProvider:
    chart:
      name: my-chart
      repository: https://charts.example.com
      version: "1.0.0"
      pullSecretRef:
        name: helm-repo-secret
        namespace: crossplane-system
    namespace: my-namespace
  providerConfigRef:
    name: default
```

### Deploy with Values from ConfigMap

```yaml
apiVersion: helm.crossplane.io/v1beta1
kind: Release
metadata:
  name: my-release
spec:
  forProvider:
    chart:
      name: my-chart
      repository: https://charts.example.com
      version: "1.0.0"
    namespace: my-namespace
    valuesFrom:
      - configMapKeyRef:
          name: my-values-configmap
          key: values.yaml
          namespace: default
  providerConfigRef:
    name: default
```

### Deploy with Specific Set Values

```yaml
apiVersion: helm.crossplane.io/v1beta1
kind: Release
metadata:
  name: my-release
spec:
  forProvider:
    chart:
      name: my-chart
      repository: https://charts.example.com
      version: "1.0.0"
    namespace: my-namespace
    set:
      - name: image.tag
        value: "v1.2.3"
      - name: replicas
        value: "3"
  providerConfigRef:
    name: default
```

## Troubleshooting

### Check Release Status

```bash
# Get release status
kubectl get release <release-name> -o yaml

# Check events
kubectl describe release <release-name>

# Check provider logs
kubectl logs -n crossplane-system -l pkg.crossplane.io/provider=provider-helm
```

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| `Release not ready` | Chart installation in progress | Wait or check provider logs |
| `forbidden` errors | Missing RBAC permissions | Apply `rbac.yaml` |
| `chart not found` | Invalid repository or chart name | Verify chart exists in repository |
| `timeout` | Slow cluster or large chart | Increase timeout in release spec |

### Debug Mode

Enable debug logging for the Helm provider:

```yaml
apiVersion: helm.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: InjectedIdentity
  # Add debug flag
  debugMode: true
```

## Best Practices

1. **Version Pinning** - Always specify exact chart versions
2. **Resource Limits** - Set resource requests/limits for all deployments
3. **Namespaces** - Use dedicated namespaces for each release
4. **GitOps** - Store all Release manifests in Git
5. **Secrets** - Use external secrets management for sensitive values

## Related Resources

- [Crossplane Helm Provider](https://github.com/crossplane-contrib/provider-helm)
- [Helm Provider Documentation](https://marketplace.upbound.io/providers/crossplane-contrib/provider-helm)
- [Crossplane Documentation](https://docs.crossplane.io/)
