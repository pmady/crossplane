#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${YELLOW}=== YAML Schema Validation ===${NC}"

# Check if yq is installed
if ! command -v yq &> /dev/null; then
    echo -e "${RED}Error: yq is not installed${NC}"
    echo "Install it with: brew install yq (macOS) or snap install yq (Linux)"
    exit 1
fi

ERRORS=0

# Validate YAML syntax
echo -e "\n${YELLOW}Validating YAML syntax...${NC}"

for file in "${PROJECT_DIR}"/*.yaml; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        if yq eval '.' "$file" > /dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} $filename"
        else
            echo -e "  ${RED}✗${NC} $filename - Invalid YAML"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

# Validate required fields in definition.yaml
echo -e "\n${YELLOW}Validating XRD definition...${NC}"

XRD_FILE="${PROJECT_DIR}/definition.yaml"
if [ -f "$XRD_FILE" ]; then
    # Check apiVersion
    API_VERSION=$(yq eval '.apiVersion' "$XRD_FILE")
    if [ "$API_VERSION" = "apiextensions.crossplane.io/v2" ]; then
        echo -e "  ${GREEN}✓${NC} XRD apiVersion is v2"
    else
        echo -e "  ${RED}✗${NC} XRD apiVersion should be apiextensions.crossplane.io/v2"
        ERRORS=$((ERRORS + 1))
    fi

    # Check kind
    KIND=$(yq eval '.kind' "$XRD_FILE")
    if [ "$KIND" = "CompositeResourceDefinition" ]; then
        echo -e "  ${GREEN}✓${NC} Kind is CompositeResourceDefinition"
    else
        echo -e "  ${RED}✗${NC} Kind should be CompositeResourceDefinition"
        ERRORS=$((ERRORS + 1))
    fi

    # Check spec.group
    GROUP=$(yq eval '.spec.group' "$XRD_FILE")
    if [ -n "$GROUP" ] && [ "$GROUP" != "null" ]; then
        echo -e "  ${GREEN}✓${NC} spec.group is defined: $GROUP"
    else
        echo -e "  ${RED}✗${NC} spec.group is missing"
        ERRORS=$((ERRORS + 1))
    fi

    # Check spec.names.kind
    NAMES_KIND=$(yq eval '.spec.names.kind' "$XRD_FILE")
    if [ -n "$NAMES_KIND" ] && [ "$NAMES_KIND" != "null" ]; then
        echo -e "  ${GREEN}✓${NC} spec.names.kind is defined: $NAMES_KIND"
    else
        echo -e "  ${RED}✗${NC} spec.names.kind is missing"
        ERRORS=$((ERRORS + 1))
    fi
fi

# Validate required fields in composition.yaml
echo -e "\n${YELLOW}Validating Composition...${NC}"

COMP_FILE="${PROJECT_DIR}/composition.yaml"
if [ -f "$COMP_FILE" ]; then
    # Check apiVersion
    API_VERSION=$(yq eval '.apiVersion' "$COMP_FILE")
    if [ "$API_VERSION" = "apiextensions.crossplane.io/v2" ]; then
        echo -e "  ${GREEN}✓${NC} Composition apiVersion is v2"
    else
        echo -e "  ${RED}✗${NC} Composition apiVersion should be apiextensions.crossplane.io/v2"
        ERRORS=$((ERRORS + 1))
    fi

    # Check mode
    MODE=$(yq eval '.spec.mode' "$COMP_FILE")
    if [ "$MODE" = "Pipeline" ]; then
        echo -e "  ${GREEN}✓${NC} Composition mode is Pipeline"
    else
        echo -e "  ${RED}✗${NC} Composition mode should be Pipeline for v2"
        ERRORS=$((ERRORS + 1))
    fi

    # Check pipeline exists
    PIPELINE=$(yq eval '.spec.pipeline' "$COMP_FILE")
    if [ -n "$PIPELINE" ] && [ "$PIPELINE" != "null" ]; then
        echo -e "  ${GREEN}✓${NC} spec.pipeline is defined"
    else
        echo -e "  ${RED}✗${NC} spec.pipeline is missing"
        ERRORS=$((ERRORS + 1))
    fi

    # Check compositeTypeRef
    COMPOSITE_REF=$(yq eval '.spec.compositeTypeRef.kind' "$COMP_FILE")
    if [ -n "$COMPOSITE_REF" ] && [ "$COMPOSITE_REF" != "null" ]; then
        echo -e "  ${GREEN}✓${NC} compositeTypeRef.kind is defined: $COMPOSITE_REF"
    else
        echo -e "  ${RED}✗${NC} compositeTypeRef.kind is missing"
        ERRORS=$((ERRORS + 1))
    fi

    # Count resources in pipeline
    RESOURCE_COUNT=$(yq eval '.spec.pipeline[0].input.resources | length' "$COMP_FILE")
    echo -e "  ${GREEN}✓${NC} Pipeline contains $RESOURCE_COUNT resources"
fi

# Final result
echo -e "\n${YELLOW}=== Validation Results ===${NC}"
if [ "$ERRORS" -eq 0 ]; then
    echo -e "${GREEN}All validations passed!${NC}"
    exit 0
else
    echo -e "${RED}$ERRORS validation(s) failed${NC}"
    exit 1
fi
