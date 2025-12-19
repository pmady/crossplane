# Crossplane S3 Bucket Composition

A Crossplane 2.0 composition for provisioning AWS S3 buckets with common configurations including versioning, encryption, public access blocking, and lifecycle policies.

## Features

- **Versioning** - Enable/disable object versioning
- **Server-Side Encryption** - AES256 or AWS KMS encryption
- **Public Access Block** - Block all public access by default
- **Lifecycle Policies** - Automatic transition to Glacier storage

## Prerequisites

- Kubernetes cluster with Crossplane 2.0+ installed
- AWS Provider configured with appropriate credentials
- `function-patch-and-transform` function installed

## Installation

```bash
# Install the function (if not already installed)
kubectl apply -f functions.yaml

# Apply XRD and Composition
kubectl apply -f definition.yaml
kubectl apply -f composition.yaml
```

## Usage

### Basic S3 Bucket

```yaml
apiVersion: aws.example.com/v1alpha1
kind: S3Bucket
metadata:
  name: my-app-bucket
  namespace: default
spec:
  parameters:
    region: us-west-2
    versioning: true
    encryption: AES256
    publicAccessBlock: true
```

### S3 Bucket with Lifecycle Policy

```yaml
apiVersion: aws.example.com/v1alpha1
kind: S3Bucket
metadata:
  name: archive-bucket
  namespace: default
spec:
  parameters:
    region: us-east-1
    versioning: true
    encryption: aws:kms
    publicAccessBlock: true
    lifecycleEnabled: true
    lifecycleDays: 30
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `region` | string | `us-west-2` | AWS region for the bucket |
| `versioning` | boolean | `true` | Enable object versioning |
| `encryption` | string | `AES256` | Encryption algorithm (`AES256` or `aws:kms`) |
| `publicAccessBlock` | boolean | `true` | Block all public access |
| `lifecycleEnabled` | boolean | `false` | Enable lifecycle rules |
| `lifecycleDays` | integer | `90` | Days before transitioning to Glacier |
| `expirationDays` | integer | `0` | Days before expiring objects (0 to disable) |

## Status Fields

After the bucket is created, the following status fields are populated:

| Field | Description |
|-------|-------------|
| `bucketArn` | ARN of the S3 bucket |
| `bucketName` | Name of the S3 bucket |
| `bucketRegion` | Region where the bucket was created |

## Security Considerations

- **Public Access Block** is enabled by default - all public access is blocked
- **Server-Side Encryption** is enabled by default with AES256
- **Versioning** is enabled by default to protect against accidental deletion
- Consider using `aws:kms` encryption for additional control over encryption keys

## Testing

```bash
# Validate YAML syntax
kubectl apply --dry-run=client -f definition.yaml
kubectl apply --dry-run=client -f composition.yaml

# Create a test bucket
kubectl apply -f claim.yaml

# Check status
kubectl get s3bucket my-app-bucket -o yaml
kubectl get bucket -l crossplane.io/claim-name=my-app-bucket
```

## Cleanup

```bash
# Delete the bucket claim (this will delete the S3 bucket)
kubectl delete -f claim.yaml

# Remove composition and XRD
kubectl delete -f composition.yaml
kubectl delete -f definition.yaml
```

## Related Resources

- [Crossplane Documentation](https://docs.crossplane.io/)
- [AWS S3 Provider](https://marketplace.upbound.io/providers/upbound/provider-aws-s3)
- [Function Patch and Transform](https://github.com/crossplane-contrib/function-patch-and-transform)
