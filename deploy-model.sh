#!/bin/bash

# Model Registration and Deployment Script
# This script registers a model from a training job and deploys it to a real-time endpoint

# Set your Azure subscription and resource group details
RESOURCE_GROUP="<your-resource-group>"
WORKSPACE_NAME="<your-workspace-name>"
MODEL_NAME="diabetes-model"
JOB_NAME="<your-completed-job-name>"

# Login to Azure (if not already logged in)
echo "Logging in to Azure..."
az login

# Set Azure ML defaults
echo "Setting Azure ML defaults..."
az configure --defaults group=$RESOURCE_GROUP workspace=$WORKSPACE_NAME

# Register model from job output
echo "Registering model from job output..."
az ml model create \
  --name $MODEL_NAME \
  --version 1 \
  --type mlflow_model \
  --path azureml://jobs/$JOB_NAME/outputs/artifacts/paths/model

# Alternative: Register model from local path if you've downloaded it
# az ml model create --name $MODEL_NAME --version 1 --type mlflow_model --path ./model

# List models to verify registration
echo "Listing registered models..."
az ml model list --name $MODEL_NAME

# Create endpoint
echo "Creating endpoint..."
az ml online-endpoint create -f src/endpoint.yml

# Deploy model to endpoint
echo "Deploying model..."
az ml online-deployment create -f src/deployment.yml --all-traffic

# Get endpoint details
echo "Getting endpoint details..."
az ml online-endpoint show -n diabetes-endpoint

# Get endpoint URI and key
echo "Getting endpoint URI and key..."
ENDPOINT_URI=$(az ml online-endpoint show -n diabetes-endpoint --query scoring_uri -o tsv)
ENDPOINT_KEY=$(az ml online-endpoint get-credentials -n diabetes-endpoint --query primaryKey -o tsv)

echo ""
echo "==================================="
echo "Endpoint URI: $ENDPOINT_URI"
echo "Endpoint Key: $ENDPOINT_KEY"
echo "==================================="
echo ""

# Test endpoint
echo "Testing endpoint with sample data..."
curl -X POST $ENDPOINT_URI \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ENDPOINT_KEY" \
  -d @src/test-data.json

echo ""
echo "Deployment complete!"
