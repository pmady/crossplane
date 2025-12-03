#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${YELLOW}=== Crossplane Composition Render Test ===${NC}"

# Check if crossplane CLI is installed
if ! command -v crossplane &> /dev/null; then
    echo -e "${RED}Error: crossplane CLI is not installed${NC}"
    echo "Install it with: curl -sL https://raw.githubusercontent.com/crossplane/crossplane/master/install.sh | sh"
    exit 1
fi

# Run crossplane beta render
echo -e "\n${YELLOW}Running crossplane beta render...${NC}"
RENDER_OUTPUT=$(crossplane beta render \
    "${SCRIPT_DIR}/render/composite.yaml" \
    "${PROJECT_DIR}/composition.yaml" \
    "${SCRIPT_DIR}/render/functions.yaml" \
    2>&1) || {
    echo -e "${RED}Render failed:${NC}"
    echo "$RENDER_OUTPUT"
    exit 1
}

echo "$RENDER_OUTPUT" > "${SCRIPT_DIR}/render/output.yaml"
echo -e "${GREEN}Render output saved to tests/render/output.yaml${NC}"

# Validate expected resources exist
echo -e "\n${YELLOW}Validating rendered resources...${NC}"

EXPECTED_KINDS=(
    "VPC"
    "InternetGateway"
    "Subnet"
    "EIP"
    "NATGateway"
    "RouteTable"
    "Route"
    "RouteTableAssociation"
    "Role"
    "RolePolicyAttachment"
    "Cluster"
    "NodeGroup"
)

ERRORS=0

for kind in "${EXPECTED_KINDS[@]}"; do
    if echo "$RENDER_OUTPUT" | grep -q "kind: $kind"; then
        echo -e "  ${GREEN}✓${NC} Found $kind"
    else
        echo -e "  ${RED}✗${NC} Missing $kind"
        ERRORS=$((ERRORS + 1))
    fi
done

# Count specific resources
echo -e "\n${YELLOW}Resource counts:${NC}"
SUBNET_COUNT=$(echo "$RENDER_OUTPUT" | grep -c "kind: Subnet" || true)
ROLE_COUNT=$(echo "$RENDER_OUTPUT" | grep -c "kind: Role" || true)
RT_ASSOC_COUNT=$(echo "$RENDER_OUTPUT" | grep -c "kind: RouteTableAssociation" || true)

echo "  Subnets: $SUBNET_COUNT (expected: 4)"
echo "  Roles: $ROLE_COUNT (expected: 2)"
echo "  RouteTableAssociations: $RT_ASSOC_COUNT (expected: 4)"

if [ "$SUBNET_COUNT" -ne 4 ]; then
    echo -e "${RED}  ✗ Expected 4 subnets${NC}"
    ERRORS=$((ERRORS + 1))
fi

if [ "$ROLE_COUNT" -ne 2 ]; then
    echo -e "${RED}  ✗ Expected 2 roles${NC}"
    ERRORS=$((ERRORS + 1))
fi

if [ "$RT_ASSOC_COUNT" -ne 4 ]; then
    echo -e "${RED}  ✗ Expected 4 route table associations${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Validate specific field values
echo -e "\n${YELLOW}Validating field values...${NC}"

if echo "$RENDER_OUTPUT" | grep -q "region: us-west-2"; then
    echo -e "  ${GREEN}✓${NC} Region is correctly set"
else
    echo -e "  ${RED}✗${NC} Region not found or incorrect"
    ERRORS=$((ERRORS + 1))
fi

if echo "$RENDER_OUTPUT" | grep -q "cidrBlock: \"10.0.0.0/16\""; then
    echo -e "  ${GREEN}✓${NC} VPC CIDR is correctly set"
else
    echo -e "  ${RED}✗${NC} VPC CIDR not found or incorrect"
    ERRORS=$((ERRORS + 1))
fi

if echo "$RENDER_OUTPUT" | grep -q "version: \"1.28\""; then
    echo -e "  ${GREEN}✓${NC} Kubernetes version is correctly set"
else
    echo -e "  ${RED}✗${NC} Kubernetes version not found or incorrect"
    ERRORS=$((ERRORS + 1))
fi

if echo "$RENDER_OUTPUT" | grep -q "t3.medium"; then
    echo -e "  ${GREEN}✓${NC} Node instance type is correctly set"
else
    echo -e "  ${RED}✗${NC} Node instance type not found or incorrect"
    ERRORS=$((ERRORS + 1))
fi

# Final result
echo -e "\n${YELLOW}=== Test Results ===${NC}"
if [ "$ERRORS" -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}$ERRORS test(s) failed${NC}"
    exit 1
fi
