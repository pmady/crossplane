---
name: Bug Report
about: Report a bug or unexpected behavior
title: '[BUG] '
labels: bug
assignees: ''
---

## Description

A clear and concise description of the bug.

## Steps to Reproduce

1. Apply the following manifest:
```yaml
# paste your manifest here
```
2. Run command '...'
3. See error

## Expected Behavior

What you expected to happen.

## Actual Behavior

What actually happened.

## Environment

- **Crossplane Version**: 
- **Kubernetes Version**: 
- **Cloud Provider**: AWS / Azure / GCP
- **Provider Version**: 

## Logs

```
# Paste relevant logs here
kubectl logs -n crossplane-system -l pkg.crossplane.io/provider=<provider-name>
```

## Additional Context

Add any other context about the problem here.
