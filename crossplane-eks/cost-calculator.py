#!/usr/bin/env python3
"""
Cost Estimation Calculator for EKS Clusters
This module provides cost calculation functions for AWS EKS cluster components.
"""

import json
from typing import Dict, Any, Optional
import os

class CostEstimator:
    def __init__(self, pricing_file: str = "cost-estimation.json"):
        """Initialize cost estimator with pricing data."""
        # Get the directory where this script is located
        script_dir = os.path.dirname(os.path.abspath(__file__))
        pricing_path = os.path.join(script_dir, pricing_file)
        
        with open(pricing_path, 'r') as f:
            self.pricing = json.load(f)
    
    def calculate_ec2_cost(self, instance_type: str, node_count: int, region: str) -> Dict[str, float]:
        """Calculate EC2 instance costs."""
        try:
            hourly_cost = self.pricing['ec2_pricing'][region][instance_type]
            monthly_hours = self.pricing['default_assumptions']['monthly_hours']
            monthly_cost = hourly_cost * node_count * monthly_hours
            
            return {
                'hourly': hourly_cost * node_count,
                'monthly': monthly_cost,
                'yearly': monthly_cost * 12
            }
        except KeyError as e:
            return {'error': f'Pricing not found for {e}'}
    
    def calculate_eks_cost(self, region: str) -> Dict[str, float]:
        """Calculate EKS control plane costs."""
        try:
            hourly_cost = self.pricing['eks_pricing'][region]
            monthly_hours = self.pricing['default_assumptions']['monthly_hours']
            monthly_cost = hourly_cost * monthly_hours
            
            return {
                'hourly': hourly_cost,
                'monthly': monthly_cost,
                'yearly': monthly_cost * 12
            }
        except KeyError as e:
            return {'error': f'Pricing not found for {e}'}
    
    def calculate_nat_gateway_cost(self, region: str) -> Dict[str, float]:
        """Calculate NAT Gateway costs."""
        try:
            hourly_cost = self.pricing['nat_gateway_pricing'][region]['hourly']
            data_processing_cost = self.pricing['nat_gateway_pricing'][region]['data_processing_per_gb']
            monthly_hours = self.pricing['default_assumptions']['monthly_hours']
            data_gb = self.pricing['default_assumptions']['nat_gateway_data_gb_per_month']
            
            hourly_total = hourly_cost
            monthly_total = (hourly_cost * monthly_hours) + (data_processing_cost * data_gb)
            
            return {
                'hourly': hourly_total,
                'monthly': monthly_total,
                'yearly': monthly_total * 12,
                'data_processing_monthly': data_processing_cost * data_gb
            }
        except KeyError as e:
            return {'error': f'Pricing not found for {e}'}
    
    def calculate_ebs_cost(self, volume_size_gb: int, region: str, volume_type: str = 'gp3') -> Dict[str, float]:
        """Calculate EBS volume costs."""
        try:
            cost_per_gb_month = self.pricing['ebs_pricing'][region][volume_type]
            monthly_cost = cost_per_gb_month * volume_size_gb
            
            return {
                'monthly': monthly_cost,
                'yearly': monthly_cost * 12
            }
        except KeyError as e:
            return {'error': f'Pricing not found for {e}'}
    
    def calculate_data_transfer_cost(self, region: str, data_gb: Optional[int] = None) -> Dict[str, float]:
        """Calculate data transfer costs."""
        try:
            if data_gb is None:
                data_gb = self.pricing['default_assumptions']['data_transfer_gb_per_month']
            
            cost_per_gb = self.pricing['data_transfer_pricing'][region]['internet']
            monthly_cost = cost_per_gb * data_gb
            
            return {
                'monthly': monthly_cost,
                'yearly': monthly_cost * 12
            }
        except KeyError as e:
            return {'error': f'Pricing not found for {e}'}
    
    def calculate_total_cluster_cost(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Calculate total cluster cost breakdown."""
        region = config.get('region', 'us-west-2')
        instance_type = config.get('nodeInstanceType', 't3.medium')
        node_count = config.get('desiredNodeCount', 2)
        volume_size = config.get('ebsVolumeSizeGb', 50)
        
        # Calculate individual components
        ec2_cost = self.calculate_ec2_cost(instance_type, node_count, region)
        eks_cost = self.calculate_eks_cost(region)
        nat_cost = self.calculate_nat_gateway_cost(region)
        ebs_cost = self.calculate_ebs_cost(volume_size, region)
        data_cost = self.calculate_data_transfer_cost(region)
        
        # Check for errors
        errors = []
        for cost_type, cost_data in [('EC2', ec2_cost), ('EKS', eks_cost), ('NAT', nat_cost), ('EBS', ebs_cost), ('Data', data_cost)]:
            if 'error' in cost_data:
                errors.append(f"{cost_type}: {cost_data['error']}")
        
        if errors:
            return {'errors': errors}
        
        # Calculate totals
        total_monthly = (
            ec2_cost['monthly'] + 
            eks_cost['monthly'] + 
            nat_cost['monthly'] + 
            ebs_cost['monthly'] + 
            data_cost['monthly']
        )
        
        total_yearly = total_monthly * 12
        
        return {
            'region': region,
            'configuration': {
                'instance_type': instance_type,
                'node_count': node_count,
                'volume_size_gb': volume_size
            },
            'cost_breakdown': {
                'ec2_instances': ec2_cost,
                'eks_control_plane': eks_cost,
                'nat_gateway': nat_cost,
                'ebs_volumes': ebs_cost,
                'data_transfer': data_cost
            },
            'total_cost': {
                'monthly': round(total_monthly, 2),
                'yearly': round(total_yearly, 2)
            },
            'currency': 'USD'
        }

def main():
    """Example usage of cost estimator."""
    estimator = CostEstimator()
    
    # Example configuration
    config = {
        'region': 'us-west-2',
        'nodeInstanceType': 't3.medium',
        'desiredNodeCount': 3,
        'ebsVolumeSizeGb': 50
    }
    
    cost_estimate = estimator.calculate_total_cluster_cost(config)
    
    if 'errors' in cost_estimate:
        print("Cost calculation errors:")
        for error in cost_estimate['errors']:
            print(f"  - {error}")
    else:
        print(f"Cluster Cost Estimate ({cost_estimate['region']}):")
        print(f"  Instance Type: {cost_estimate['configuration']['instance_type']}")
        print(f"  Node Count: {cost_estimate['configuration']['node_count']}")
        print(f"  Monthly Total: ${cost_estimate['total_cost']['monthly']:.2f}")
        print(f"  Yearly Total: ${cost_estimate['total_cost']['yearly']:.2f}")
        print("\nCost Breakdown:")
        for component, cost in cost_estimate['cost_breakdown'].items():
            print(f"  {component}: ${cost['monthly']:.2f}/month")

if __name__ == "__main__":
    main()
