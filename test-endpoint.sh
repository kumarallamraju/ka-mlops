#!/bin/bash

# Quick Endpoint Testing Script
# Run this after your endpoint is deployed

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ENDPOINT_NAME="diabetes-endpoint"

echo -e "${YELLOW}=== Diabetes Model Endpoint Test ===${NC}\n"

# Check if endpoint exists
echo "Checking endpoint status..."
ENDPOINT_STATUS=$(az ml online-endpoint show -n $ENDPOINT_NAME --query "provisioning_state" -o tsv 2>/dev/null)

if [ -z "$ENDPOINT_STATUS" ]; then
    echo "❌ Endpoint not found. Please deploy the model first."
    exit 1
fi

echo -e "${GREEN}✓ Endpoint Status: $ENDPOINT_STATUS${NC}\n"

# Get endpoint details
echo "Getting endpoint URI and credentials..."
ENDPOINT_URI=$(az ml online-endpoint show -n $ENDPOINT_NAME --query scoring_uri -o tsv)
ENDPOINT_KEY=$(az ml online-endpoint get-credentials -n $ENDPOINT_NAME --query primaryKey -o tsv)

echo "Endpoint URI: $ENDPOINT_URI"
echo ""

# Test the endpoint
echo -e "${YELLOW}Testing endpoint with sample data...${NC}"
echo ""

RESPONSE=$(curl -s -X POST $ENDPOINT_URI \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ENDPOINT_KEY" \
  -d @src/test-data.json)

echo -e "${GREEN}Response:${NC}"
echo $RESPONSE | python3 -m json.tool 2>/dev/null || echo $RESPONSE
echo ""

# Interpret results
echo -e "${YELLOW}=== Prediction Interpretation ===${NC}"
echo "Sample 1 (9 pregnancies, 104 glucose, age 43): $(echo $RESPONSE | grep -o '\[.*\]' | cut -d',' -f1 | tr -d '[')"
echo "Sample 2 (6 pregnancies, 73 glucose, age 75): $(echo $RESPONSE | grep -o '\[.*\]' | cut -d',' -f2)"
echo "Sample 3 (4 pregnancies, 115 glucose, age 59): $(echo $RESPONSE | grep -o '\[.*\]' | cut -d',' -f3 | tr -d ']')"
echo ""
echo "0 = Not Diabetic, 1 = Diabetic"
echo ""
echo -e "${GREEN}✓ Test complete!${NC}"
