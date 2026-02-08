# Azure Machine Learning Setup Guide

This guide walks you through setting up Azure Machine Learning for the diabetes classification project.

## Prerequisites

1. Install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
2. Install Azure ML CLI v2 extension:
   ```bash
   az extension add -n ml
   ```

## Step-by-Step Instructions

### 1. Login to Azure

```bash
az login
```

### 2. Set Your Subscription

```bash
az account set --subscription <your-subscription-id>
```

To list available subscriptions:
```bash
az account list --output table
```

### 3. Create Resource Group (if needed)

```bash
az group create --name rg-aml-mlops --location eastus
```

### 4. Create Azure Machine Learning Workspace

```bash
az ml workspace create --name mlw-diabetes-training \
  --resource-group rg-aml-mlops \
  --location eastus
```

### 5. Create Compute Cluster

```bash
az ml compute create --name aml-cluster \
  --type amlcompute \
  --size STANDARD_DS3_V2 \
  --min-instances 0 \
  --max-instances 2 \
  --resource-group rg-aml-mlops \
  --workspace-name mlw-diabetes-training
```

**Note:** You can also create a compute instance instead:
```bash
az ml compute create --name ci-diabetes \
  --type computeinstance \
  --size STANDARD_DS3_V2 \
  --resource-group rg-aml-mlops \
  --workspace-name mlw-diabetes-training
```

### 6. Register Data Asset

From the root of the project, run:

```bash
az ml data create --name diabetes-dev-folder \
  --version 1 \
  --type uri_folder \
  --path ./experimentation/data \
  --resource-group rg-aml-mlops \
  --workspace-name mlw-diabetes-training
```

This registers the `experimentation/data` folder (containing diabetes-dev.csv) as a data asset.

### 7. Run the Training Job

```bash
az ml job create --file ./src/job.yml \
  --resource-group rg-aml-mlops \
  --workspace-name mlw-diabetes-training \
  --stream
```

The `--stream` flag shows live logs from the job execution.

## Verify the Job

After running the job, you can:

1. **View job status in Azure Portal:**
   - Navigate to your Azure ML workspace
   - Go to "Jobs" section
   - Find your job under the experiment "diabetes-training-experiment"

2. **View job status via CLI:**
   ```bash
   az ml job list --resource-group rg-aml-mlops \
     --workspace-name mlw-diabetes-training \
     --output table
   ```

3. **View specific job details:**
   ```bash
   az ml job show --name <job-name> \
     --resource-group rg-aml-mlops \
     --workspace-name mlw-diabetes-training
   ```

## What the Job Does

The job.yml file configures an Azure ML job that:
- Uses the code in the `model` folder (train.py)
- Takes the registered data asset `diabetes-dev-folder` as input
- Uses regularization rate of 0.01
- Runs on the compute cluster `aml-cluster`
- Logs all parameters, metrics, and model artifacts using MLflow autologging
- Tracks everything under the experiment "diabetes-training-experiment"

## Troubleshooting

### Issue: Compute not found
- Make sure the compute name in job.yml matches the compute you created
- If you created a compute instance instead of a cluster, update the compute name in job.yml

### Issue: Data asset not found
- Verify the data asset was created successfully:
  ```bash
  az ml data list --resource-group rg-aml-mlops \
    --workspace-name mlw-diabetes-training
  ```

### Issue: Environment issues
- The job uses a pre-built Azure ML environment
- If needed, you can create a custom environment with your requirements.txt

## Next Steps

After the job completes successfully:
1. Review the metrics and parameters logged by MLflow
2. Download the trained model from the job outputs
3. Deploy the model to an endpoint for inference
