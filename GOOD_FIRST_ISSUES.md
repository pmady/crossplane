# Good First Issues

Welcome to the Crossplane Compositions repository! This document contains a curated list of beginner-friendly issues to help you get started with contributing.

## How to Contribute

1. Pick an issue from the list below
2. Comment on the GitHub issue to let others know you're working on it
3. Fork the repository and create a branch
4. Submit a Pull Request when ready

---

## Available Issues

### 1. Add Azure AKS Composition

**Labels:** `good first issue`, `enhancement`, `azure`

**Description:**
Create a new composition for provisioning Azure AKS clusters similar to the existing EKS composition.

**Requirements:**
- Create `crossplane-aks/` directory with composition, definition, claim, and functions files
- Include VNet, subnets, and AKS cluster resources
- Use Crossplane 2.0 Pipeline mode with `function-patch-and-transform`
- Add documentation in README.md
- Add render tests

**Reference:** See `crossplane-eks/` for structure and patterns

**Estimated Effort:** Medium

---

### 2. Add GCP GKE Composition

**Labels:** `good first issue`, `enhancement`, `gcp`

**Description:**
Create a new composition for provisioning GCP GKE clusters.

**Requirements:**
- Create `crossplane-gke/` directory
- Include VPC, subnets, and GKE cluster resources
- Use Crossplane 2.0 Pipeline mode
- Add tests and documentation

**Reference:** See `crossplane-eks/` for structure

**Estimated Effort:** Medium

---

### 3. Add CONTRIBUTING.md

**Labels:** `good first issue`, `documentation`

**Description:**
Add a CONTRIBUTING.md file to help new contributors get started.

**Include:**
- How to set up local development environment
- Code style guidelines
- How to run tests locally
- PR submission process
- Issue reporting guidelines

**Estimated Effort:** Low

---

### 4. Add Multi-Region Support to EKS Composition

**Labels:** `good first issue`, `enhancement`

**Description:**
Enhance the EKS composition to support multi-region deployments.

**Requirements:**
- Add region parameter validation
- Support availability zone selection based on region
- Update documentation with multi-region examples

**Estimated Effort:** Medium

---

### 5. Improve crossplane-helm Documentation

**Labels:** `good first issue`, `documentation`

**Description:**
The `crossplane-helm/` directory needs better documentation.

**Add:**
- More Helm release examples (nginx-ingress, cert-manager, external-dns, etc.)
- Troubleshooting section
- Common use cases and patterns

**Estimated Effort:** Low

---

### 6. Add Pre-commit Hooks for YAML Validation

**Labels:** `good first issue`, `tooling`

**Description:**
Add pre-commit configuration to validate YAML files before commit.

**Requirements:**
- Add `.pre-commit-config.yaml`
- Include yamllint configuration
- Update README with setup instructions

**Estimated Effort:** Low

---

### 7. Add RDS Database Composition

**Labels:** `good first issue`, `enhancement`, `aws`

**Description:**
Create a composition for provisioning AWS RDS databases that can be used alongside EKS clusters.

**Requirements:**
- Create `crossplane-rds/` directory
- Support PostgreSQL and MySQL engines
- Include security groups and subnet groups
- Add parameter groups for common configurations

**Estimated Effort:** Medium

---

### 8. Add S3 Bucket Composition

**Labels:** `good first issue`, `enhancement`, `aws`

**Description:**
Create a simple composition for provisioning S3 buckets with common configurations.

**Requirements:**
- Create `crossplane-s3/` directory
- Support versioning, encryption, and lifecycle policies
- Add IAM policy for bucket access

**Estimated Effort:** Low

---

## Getting Help

- Open a [Discussion](https://github.com/pmady/crossplane/discussions) for questions
- Check existing [Pull Requests](https://github.com/pmady/crossplane/pulls) for examples
- Review the [Crossplane Documentation](https://docs.crossplane.io/) for reference

Happy Contributing!
