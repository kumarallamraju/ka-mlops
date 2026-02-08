#!/bin/bash

# Azure Machine Learning Setup Script
# This script sets up the Azure ML workspace, compute, data asset, and runs the training job

# Set your Azure subscription and resource group details
SUBSCRIPTION_ID="80cf225d-41c6-4df5-84e8-4ca9d781f731"
RESOURCE_GROUP="rg-aml-mlops"
LOCATION="westus3"
WORKSPACE_NAME="mlw-diabetes-training"
COMPUTE_NAME="aml-cluster"

# Login to Azure (if not already logged in)
echo "Logging in to Azure..."
az login

# Set the subscription
echo "Setting subscription..."
az account set --subscription $SUBSCRIPTION_ID

# Create resource group
echo "Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Azure Machine Learning workspace
echo "Creating Azure ML workspace..."
az ml workspace create --name $WORKSPACE_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# Create compute cluster
echo "Creating compute cluster..."
az ml compute create --name $COMPUTE_NAME \
  --type amlcompute \
  --size STANDARD_DS3_V2 \
  --min-instances 0 \
  --max-instances 2 \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $WORKSPACE_NAME

# Create registered data asset
echo "Creating registered data asset..."
az ml data create --name diabetes-dev-folder \
  --version 1 \
  --type uri_folder \
  --path ./experimentation/data \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $WORKSPACE_NAME

# Run the training job
echo "Submitting training job..."
az ml job create --file ./src/job.yml \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $WORKSPACE_NAME \
  --stream

echo "Setup complete!"
