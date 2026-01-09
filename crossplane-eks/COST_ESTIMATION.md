# Cost Estimation for EKS Clusters

This guide explains how to use the cost estimation functionality for EKS clusters in Crossplane compositions.

## Overview

The cost estimation feature helps you understand the AWS costs before provisioning EKS clusters by providing detailed cost breakdowns for all cluster components.

## Supported Cost Components

| Component | Description | Pricing Model |
|-----------|-------------|---------------|
| **EC2 Instances** | Worker nodes compute cost | Per hour per instance |
| **EKS Control Plane** | Kubernetes control plane | Per hour per cluster |
| **NAT Gateway** | Outbound internet access | Per hour + data processing |
| **EBS Volumes** | Root volumes for nodes | Per GB-month |
| **Data Transfer** | Internet egress traffic | Per GB |

## Supported Regions

Cost estimation is available for the following AWS regions:

- **us-west-2** (Oregon)
- **us-east-1** (N. Virginia)  
- **eu-west-1** (Ireland)

## Using Cost Estimation

### 1. View Cost Estimates in Claims

When you create an EKS cluster claim, the cost estimate will be available in the status:

```bash
kubectl get cluster my-eks-cluster -o yaml
```

The status will include cost information:

```yaml
status:
  costEstimate:
    currency: USD
    monthly: 245.67
    yearly: 2948.04
    breakdown:
      ec2Instances:
        monthly: 180.48
        yearly: 2165.76
      eksControlPlane:
        monthly: 73.00
        yearly: 876.00
      natGateway:
        monthly: 32.85
        yearly: 394.20
      ebsVolumes:
        monthly: 24.00
        yearly: 288.00
      dataTransfer:
          monthly: 9.00
          yearly: 108.00
    lastUpdated: "2024-01-15T10:30:00Z"
```

### 2. Manual Cost Calculation

You can also calculate costs manually using the provided Python script:

```bash
cd crossplane-eks
python3 cost-calculator.py
```

Example output:

```
Cluster Cost Estimate (us-west-2):
  Instance Type: t3.medium
  Node Count: 3
  Monthly Total: $245.67
  Yearly Total: $2948.04

Cost Breakdown:
  ec2_instances: $180.48/month
  eks_control_plane: $73.00/month
  nat_gateway: $32.85/month
  ebs_volumes: $24.00/month
  data_transfer: $9.00/month
```

### 3. Custom Cost Calculation

Use the CostEstimator class in your own scripts:

```python
from cost_calculator import CostEstimator

estimator = CostEstimator()
config = {
    'region': 'us-west-2',
    'nodeInstanceType': 't3.medium',
    'desiredNodeCount': 3,
    'ebsVolumeSizeGb': 50
}

cost_estimate = estimator.calculate_total_cluster_cost(config)
print(f"Monthly cost: ${cost_estimate['total_cost']['monthly']:.2f}")
```

## Cost Factors

### Instance Types

Different EC2 instance types have different costs:

| Instance Type | Monthly Cost (us-west-2) | Use Case |
|---------------|-------------------------|----------|
| t3.micro | $7.59 | Small workloads |
| t3.small | $15.18 | Development |
| t3.medium | $30.36 | General purpose |
| t3.large | $60.72 | Production |
| m5.large | $70.08 | Memory optimized |
| c5.large | $62.10 | Compute optimized |

### Node Count Impact

Cost scales linearly with node count for EC2 instances and EBS volumes:

- **1 node** (t3.medium): ~$125/month
- **3 nodes** (t3.medium): ~$245/month  
- **5 nodes** (t3.medium): ~$365/month

### Regional Price Differences

Prices vary by region:

| Region | EKS Control Plane | t3.medium |
|--------|-------------------|-----------|
| us-west-2 | $73.00/month | $30.36/month |
| us-east-1 | $73.00/month | $30.36/month |
| eu-west-1 | $87.60/month | $32.70/month |

## Cost Optimization Tips

### 1. Choose Right Instance Types

- Use **t3** instances for burstable workloads
- Use **m5** for memory-intensive applications
- Use **c5** for compute-intensive workloads

### 2. Optimize Node Count

- Start with minimum nodes and scale as needed
- Use cluster autoscaler for dynamic scaling
- Consider spot instances for non-critical workloads

### 3. Regional Selection

- Choose regions with better pricing for your workload
- Consider data transfer costs for global applications
- Factor in compliance requirements

### 4. Storage Optimization

- Right-size EBS volumes (default 50GB)
- Use gp3 for better price/performance
- Implement storage cleanup policies

## Pricing Data Updates

The pricing data in `cost-estimation.yaml` is periodically updated. To update prices:

1. Get current AWS pricing from [AWS Pricing Calculator](https://calculator.aws/)
2. Update the pricing values in the YAML file
3. Test calculations with the cost calculator script

## Limitations

### Current Limitations

- Pricing data is static (not real-time from AWS API)
- Data transfer estimates are approximate
- Does not include all AWS services (e.g., Load Balancers, RDS)
- No support for Reserved Instances or Savings Plans

### Future Enhancements

- Real-time AWS Pricing API integration
- Support for Reserved Instance pricing
- Include additional AWS services
- Cost optimization recommendations
- Historical cost tracking

## Troubleshooting

### Common Issues

**Q: Cost estimates seem too high**
- Check if node count is appropriate
- Verify instance type selection
- Consider regional pricing differences

**Q: Missing pricing for instance type**
- Add instance type to `cost-estimation.yaml`
- Verify region code is correct
- Check YAML syntax

**Q: Cost breakdown doesn't add up**
- Verify all components are included
- Check for duplicate calculations
- Ensure monthly hours calculation (730 hours)

### Getting Help

- Check the [troubleshooting guide](../TROUBLESHOOTING.md)
- Review Crossplane documentation for composition issues
- Open an issue for pricing data updates
