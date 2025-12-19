# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| main    | :white_check_mark: |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability within this project, please follow these steps:

### Do NOT

- Open a public GitHub issue for security vulnerabilities
- Disclose the vulnerability publicly before it has been addressed

### Do

1. **Email the maintainers** or open a private security advisory on GitHub
2. **Provide details** including:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment**: We will acknowledge receipt within 48 hours
- **Assessment**: We will assess the vulnerability and determine its severity
- **Resolution**: We will work on a fix and coordinate disclosure
- **Credit**: We will credit you in the security advisory (unless you prefer anonymity)

## Security Best Practices

When using these Crossplane compositions:

### AWS Credentials

- Never commit AWS credentials to the repository
- Use IAM roles for service accounts (IRSA) when possible
- Follow the principle of least privilege

### Secrets Management

- Use Kubernetes Secrets or external secret managers
- Enable encryption at rest for etcd
- Rotate credentials regularly

### Network Security

- Use private subnets for workloads
- Configure security groups with minimal required access
- Enable VPC flow logs for auditing

### Crossplane Provider Configuration

```yaml
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: IRSA  # Recommended over Secret
```

## Dependencies

This project depends on:

- Crossplane and its providers
- Kubernetes
- Cloud provider APIs (AWS, Azure, GCP)

Please ensure you keep these dependencies updated to receive security patches.

## Contact

For security concerns, please contact the maintainers through GitHub.
