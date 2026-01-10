#!/usr/bin/env python3
"""
Example script demonstrating how to use the cost calculator
"""

import sys
import os

# Add parent directory to path to import cost_calculator
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from cost_calculator import CostEstimator

def main():
    """Run cost estimation examples."""
    estimator = CostEstimator()
    
    print("=" * 60)
    print("EKS Cluster Cost Estimation Examples")
    print("=" * 60)
    print()
    
    # Example 1: Small development cluster
    print("Example 1: Small Development Cluster")
    print("-" * 60)
    config1 = {
        'region': 'us-west-2',
        'nodeInstanceType': 't3.small',
        'desiredNodeCount': 2,
        'ebsVolumeSizeGb': 30
    }
    cost1 = estimator.calculate_total_cluster_cost(config1)
    print(f"Configuration: {config1['desiredNodeCount']}x {config1['nodeInstanceType']} in {config1['region']}")
    print(f"Monthly Cost: ${cost1['total_cost']['monthly']:.2f}")
    print(f"Yearly Cost: ${cost1['total_cost']['yearly']:.2f}")
    print()
    
    # Example 2: Production cluster
    print("Example 2: Production Cluster")
    print("-" * 60)
    config2 = {
        'region': 'us-west-2',
        'nodeInstanceType': 't3.medium',
        'desiredNodeCount': 5,
        'ebsVolumeSizeGb': 100
    }
    cost2 = estimator.calculate_total_cluster_cost(config2)
    print(f"Configuration: {config2['desiredNodeCount']}x {config2['nodeInstanceType']} in {config2['region']}")
    print(f"Monthly Cost: ${cost2['total_cost']['monthly']:.2f}")
    print(f"Yearly Cost: ${cost2['total_cost']['yearly']:.2f}")
    print()
    
    # Example 3: High-performance cluster
    print("Example 3: High-Performance Cluster")
    print("-" * 60)
    config3 = {
        'region': 'us-east-1',
        'nodeInstanceType': 'c5.2xlarge',
        'desiredNodeCount': 3,
        'ebsVolumeSizeGb': 200
    }
    cost3 = estimator.calculate_total_cluster_cost(config3)
    print(f"Configuration: {config3['desiredNodeCount']}x {config3['nodeInstanceType']} in {config3['region']}")
    print(f"Monthly Cost: ${cost3['total_cost']['monthly']:.2f}")
    print(f"Yearly Cost: ${cost3['total_cost']['yearly']:.2f}")
    print()
    
    # Example 4: EU region cluster
    print("Example 4: EU Region Cluster")
    print("-" * 60)
    config4 = {
        'region': 'eu-west-1',
        'nodeInstanceType': 't3.medium',
        'desiredNodeCount': 3,
        'ebsVolumeSizeGb': 50
    }
    cost4 = estimator.calculate_total_cluster_cost(config4)
    print(f"Configuration: {config4['desiredNodeCount']}x {config4['nodeInstanceType']} in {config4['region']}")
    print(f"Monthly Cost: ${cost4['total_cost']['monthly']:.2f}")
    print(f"Yearly Cost: ${cost4['total_cost']['yearly']:.2f}")
    print()
    
    # Cost comparison
    print("=" * 60)
    print("Cost Comparison Summary")
    print("=" * 60)
    examples = [
        ("Dev Cluster", cost1),
        ("Production", cost2),
        ("High-Perf", cost3),
        ("EU Region", cost4)
    ]
    
    for name, cost in examples:
        print(f"{name:15} ${cost['total_cost']['monthly']:8.2f}/month  ${cost['total_cost']['yearly']:10.2f}/year")
    
    print()
    print("Note: Costs are estimates based on on-demand pricing.")
    print("Actual costs may vary based on usage patterns and discounts.")

if __name__ == "__main__":
    main()
