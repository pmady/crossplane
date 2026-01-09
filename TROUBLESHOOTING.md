# Troubleshooting Guide

This guide helps you troubleshoot common issues when using Crossplane compositions in this repository.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Provider Configuration Problems](#provider-configuration-problems)
- [Resource Creation Failures](#resource-creation-failures)
- [Debugging Tips and Commands](#debugging-tips-and-commands)
- [FAQ](#faq)

## Installation Issues

### Crossplane Not Installed

**Problem**: `error: the server doesn't have a resource type "composite"`

**Solution**: Install Crossplane 2.0+ first:

```bash
# Install Crossplane using Helm
helm repo add crossplane https://charts.crossplane.io/stable
helm repo update
helm install crossplane --namespace crossplane-system --create-namespace crossplane/crossplane

# Verify installation
kubectl get pods -n crossplane-system
```

### Function Not Available

**Problem**: `error: function "patch-and-transform" not found`

**Solution**: Install the required function:

```bash
# Install patch-and-transform function
kubectl apply -f crossplane-eks/functions.yaml

# Wait for function to be ready
kubectl wait --for=condition=Ready function/patch-and-transform --timeout=300s
```

### XRD Not Applied

**Problem**: `error: the server doesn't have a resource type "compositeeks"`

**Solution**: Apply the CompositeResourceDefinition:

```bash
# Apply XRD
kubectl apply -f crossplane-eks/definition.yaml

# Verify XRD is established
kubectl get xrd
kubectl wait --for=condition=Established xrd/compositeeks.compute.crossplane.io --timeout=300s
```

## Provider Configuration Problems

### AWS Provider Not Configured

**Problem**: `error: unable to find AWS credentials`

**Solution**: Configure AWS provider with proper credentials:

```bash
# Create AWS provider config
cat <<EOF | kubectl apply -f -
apiVersion: aws.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: aws-provider
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: aws-creds
      key: credentials
EOF

# Create secret with AWS credentials
kubectl create secret generic aws-creds \
  --namespace crossplane-system \
  --from-literal=credentials="$(cat ~/.aws/credentials)"
```

### Provider Not Ready

**Problem**: Composition stays in `Pending` state

**Solution**: Check provider health:

```bash
# Check provider status
kubectl get provider
kubectl get providerconfig

# Check provider pods
kubectl get pods -n crossplane-system

# View provider logs
kubectl logs -n crossplane-system -l app=provider-aws
```

### Insufficient Permissions

**Problem**: `AccessDenied: user is not authorized to perform: eks:CreateCluster`

**Solution**: Update AWS IAM permissions:

```bash
# Required permissions for EKS
eks:CreateCluster
eks:DescribeCluster
eks:DeleteCluster
ec2:CreateVpc
ec2:CreateSubnet
ec2:CreateSecurityGroup
iam:CreateRole
iam:AttachRolePolicy
```

## Resource Creation Failures

### Composition Render Errors

**Problem**: `composition render failed: patch failed at path`

**Solution**: Debug composition rendering:

```bash
# Test composition locally
crossplane beta render claim.yaml composition.yaml definition.yaml

# Check composition syntax
kubectl get composition crossplane-eks -o yaml

# View composition events
kubectl describe composition crossplane-eks
```

### Resource Timeout

**Problem**: `composition timed out waiting for condition`

**Solution**: Increase timeout or check resource status:

```bash
# Check managed resources
kubectl get managed

# Check specific resource status
kubectl describe managed ekscluster.crossplane.io/example-cluster

# View resource events
kubectl get events --field-selector involvedObject.name=example-cluster
```

### Validation Errors

**Problem**: `validation failed: spec.clusterName is required`

**Solution**: Ensure all required parameters are provided:

```bash
# Check claim parameters
kubectl get compositeeks example-cluster -o yaml

# Validate against XRD schema
kubectl get xrd compositeeks.compute.crossplane.io -o yaml
```

## Debugging Tips and Commands

### General Debugging

```bash
# Check all Crossplane resources
kubectl get xr,composition,managed,providerconfig

# Check resource conditions
kubectl get xr -o wide

# View detailed resource information
kubectl describe compositeeks example-cluster
kubectl describe managed ekscluster.crossplane.io/example-cluster
```

### Log Inspection

```bash
# Crossplane controller logs
kubectl logs -n crossplane-system -l app=crossplane

# Provider-specific logs
kubectl logs -n crossplane-system -l app=provider-aws

# Function logs
kubectl logs -n crossplane-system -l app=function-patch-and-transform
```

### Event Monitoring

```bash
# Watch events in real-time
kubectl get events --watch

# Filter events by resource
kubectl get events --field-selector involvedObject.kind=Composite

# Get events for specific resource
kubectl get events --field-selector involvedObject.name=example-cluster
```

### Resource Status

```bash
# Check resource readiness
kubectl wait --for=condition=Ready compositeeks/example-cluster --timeout=1800s

# Check managed resource status
kubectl get managed -o custom-columns=NAME:.metadata.name,TYPE:.kind,SYNCED:.status.conditions[?(@.type=="Synced")].status,READY:.status.conditions[?(@.type=="Ready")].status
```

## FAQ

### Q: How do I know if Crossplane is working correctly?

**A**: Run these checks:
```bash
kubectl get pods -n crossplane-system  # All pods should be Running
kubectl get provider                   # Provider should be Healthy
kubectl get xrd                        # XRDs should be Established
```

### Q: Why is my composition stuck in `Pending` state?

**A**: Common causes:
1. Provider not configured or unhealthy
2. Missing AWS credentials
3. Insufficient IAM permissions
4. Network connectivity issues

### Q: How do I clean up failed resources?

**A**: Delete resources in order:
```bash
kubectl delete compositeeks example-cluster
kubectl delete managed ekscluster.crossplane.io/example-cluster
kubectl delete managed vpc.crossplane.io/example-vpc
```

### Q: Can I test compositions without creating real resources?

**A**: Yes, use the render command:
```bash
crossplane beta render claim.yaml composition.yaml definition.yaml
```

### Q: Where can I find more detailed logs?

**A**: Enable debug logging:
```bash
# Edit crossplane deployment
kubectl edit deployment crossplane -n crossplane-system

# Add to args:
# - --debug
```

### Q: How do I update an existing composition?

**A**: Apply the updated composition:
```bash
kubectl apply -f crossplane-eks/composition.yaml
# Existing resources will be updated automatically
```

### Q: What should I do if I hit AWS API rate limits?

**A**: Implement these strategies:
1. Use different AWS account regions
2. Add delays between resource creation
3. Request AWS service limit increases
4. Use AWS CloudFormation instead of direct API calls

## Getting Help

If you're still experiencing issues:

1. Check the [Crossplane documentation](https://crossplane.io/docs/)
2. Search [GitHub issues](https://github.com/crossplane/crossplane/issues)
3. Join the [Crossplane Slack community](https://crossplane.io/slack/)
4. Create an issue in this repository with:
   - Your composition files
   - Error messages
   - `kubectl describe` output
   - Relevant logs

## Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `no matches for kind "CompositeResourceDefinition"` | Crossplane not installed | Install Crossplane 2.0+ |
| `provider config not found` | Provider not configured | Create ProviderConfig |
| `AccessDenied` | Insufficient AWS permissions | Update IAM role |
| `InvalidParameterValue` | Invalid parameters | Check claim parameters |
| `ResourceLimitExceeded` | AWS service limits | Request limit increase |
