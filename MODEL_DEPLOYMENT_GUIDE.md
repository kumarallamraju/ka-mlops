# Model Deployment Guide

## Overview

This guide walks you through registering a trained model and deploying it to a real-time endpoint in Azure Machine Learning.

## Prerequisites

1. Azure CLI with ML extension installed
2. A completed training job with a trained model
3. Azure credentials configured in GitHub secrets (for automated deployment)

## Files Created

| File | Purpose |
|------|---------|
| `src/endpoint.yml` | Defines the managed online endpoint configuration |
| `src/deployment.yml` | Defines the model deployment configuration |
| `src/test-data.json` | Sample data for testing the endpoint |
| `.github/workflows/05-deploy-model.yml` | GitHub Actions workflow for automated deployment |
| `deploy-model.sh` | Manual deployment script |

## Step-by-Step Deployment

### Method 1: Register Model from Azure ML Studio (Recommended)

1. **Navigate to Azure ML Studio**
   - Go to https://ml.azure.com
   - Select your workspace

2. **Find Your Training Job**
   - Click on "Jobs" in the left sidebar
   - Find your completed training job (experiment: `diabetes-training-experiment`)
   - Click on the job name to open details

3. **Register the Model**
   - In the job details page, click on the "Outputs + logs" tab
   - Navigate to "artifacts" → "model"
   - Click the "Register model" button
   - Fill in the details:
     - **Name**: `diabetes-model`
     - **Version**: Will be auto-generated (or specify 1)
     - **Model type**: MLflow model
   - Click "Register"

4. **Verify Model Registration**
   - Go to "Models" in the left sidebar
   - You should see `diabetes-model` listed

### Method 2: Register Model via CLI

If you know your job name:

```bash
# Set defaults
az configure --defaults group=<resource-group> workspace=<workspace-name>

# Register model from job output
az ml model create \
  --name diabetes-model \
  --version 1 \
  --type mlflow_model \
  --path azureml://jobs/<job-name>/outputs/artifacts/paths/model
```

Replace `<job-name>` with your actual job name (e.g., `epic_bush_1234`).

### Method 3: Automated Deployment via GitHub Actions

#### Configure GitHub Secrets

First, add these secrets to your GitHub repository:

1. Go to: https://github.com/kumarallamraju/ka-mlops/settings/secrets/actions
2. Click "New repository secret"
3. Add the following secrets:

**AZURE_CREDENTIALS**
```json
{
  "clientId": "<service-principal-client-id>",
  "clientSecret": "<service-principal-secret>",
  "subscriptionId": "<subscription-id>",
  "tenantId": "<tenant-id>"
}
```

To create a service principal:
```bash
az ad sp create-for-rbac --name "github-actions-mlops" \
  --role contributor \
  --scopes /subscriptions/<subscription-id>/resourceGroups/<resource-group> \
  --sdk-auth
```

**RESOURCE_GROUP**
```
your-resource-group-name
```

**WORKSPACE_NAME**
```
your-workspace-name
```

#### Trigger the Workflow

**Option A: Manual Trigger**
1. Go to: https://github.com/kumarallamraju/ka-mlops/actions
2. Select "Deploy Model to Production" workflow
3. Click "Run workflow"
4. Select branch: main
5. Click "Run workflow"

**Option B: Automatic Trigger**
- Push changes to `src/endpoint.yml` or `src/deployment.yml`
- The workflow will trigger automatically

### Method 4: Manual Deployment Script

1. **Edit the script**:
   ```bash
   nano deploy-model.sh
   ```
   Update these variables:
   - `RESOURCE_GROUP`
   - `WORKSPACE_NAME`
   - `JOB_NAME`

2. **Make it executable**:
   ```bash
   chmod +x deploy-model.sh
   ```

3. **Run the script**:
   ```bash
   ./deploy-model.sh
   ```

## Testing the Deployed Endpoint

### Option 1: Using cURL (Command Line)

```bash
# Get endpoint URI and key
ENDPOINT_URI=$(az ml online-endpoint show -n diabetes-endpoint \
  --query scoring_uri -o tsv)
ENDPOINT_KEY=$(az ml online-endpoint get-credentials -n diabetes-endpoint \
  --query primaryKey -o tsv)

# Test with sample data
curl -X POST $ENDPOINT_URI \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ENDPOINT_KEY" \
  -d @src/test-data.json
```

### Option 2: Using Python

```python
import requests
import json

# Get your endpoint URI and key from Azure ML Studio or CLI
endpoint_uri = "https://diabetes-endpoint.region.inference.ml.azure.com/score"
endpoint_key = "your-primary-key"

# Prepare test data
test_data = {
    "input_data": {
        "columns": [
            "Pregnancies", "PlasmaGlucose", "DiastolicBloodPressure",
            "TricepsThickness", "SerumInsulin", "BMI",
            "DiabetesPedigree", "Age"
        ],
        "data": [
            [9, 104, 51, 7, 24, 27.36983156, 1.350472047, 43],
            [6, 73, 61, 35, 24, 18.74367404, 1.074147566, 75],
            [4, 115, 50, 29, 243, 34.69215364, 0.741159926, 59]
        ]
    }
}

# Make prediction request
headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {endpoint_key}"
}

response = requests.post(endpoint_uri, headers=headers, json=test_data)
print("Status Code:", response.status_code)
print("Predictions:", response.json())
```

### Option 3: Using Azure ML Studio

1. Go to "Endpoints" in Azure ML Studio
2. Click on `diabetes-endpoint`
3. Go to the "Test" tab
4. Enter the test data in JSON format
5. Click "Test"

### Expected Response

The endpoint should return predictions like:
```json
[0, 1, 1]
```

Where:
- `0` = Not diabetic
- `1` = Diabetic

## Monitoring and Management

### View Endpoint Logs

```bash
# Get deployment logs
az ml online-deployment get-logs -n blue \
  --endpoint-name diabetes-endpoint
```

### Update Deployment

To deploy a new version of the model:

1. Update the model version in `src/deployment.yml`
2. Run the deployment command again:
   ```bash
   az ml online-deployment update -f src/deployment.yml
   ```

### Delete Endpoint (Cleanup)

```bash
az ml online-endpoint delete -n diabetes-endpoint --yes
```

## Troubleshooting

### Issue: Endpoint creation fails

**Solution**: Check if endpoint name is unique and valid:
```bash
az ml online-endpoint list
```

### Issue: Deployment fails

**Solution**: Check deployment logs:
```bash
az ml online-deployment get-logs -n blue --endpoint-name diabetes-endpoint
```

### Issue: Model not found

**Solution**: Verify model is registered:
```bash
az ml model list --name diabetes-model
```

### Issue: Authentication error

**Solution**: Verify Azure credentials:
```bash
az account show
az ml workspace show
```

## Configuration Files Explained

### endpoint.yml
```yaml
$schema: https://azuremlschemas.azureedge.net/latest/managedOnlineEndpoint.schema.json
name: diabetes-endpoint      # Unique endpoint name
auth_mode: key              # Use key-based authentication
```

### deployment.yml
```yaml
$schema: https://azuremlschemas.azureedge.net/latest/managedOnlineDeployment.schema.json
name: blue                          # Deployment name
endpoint_name: diabetes-endpoint    # Target endpoint
model: azureml:diabetes-model@latest  # Use latest model version
instance_type: Standard_DS2_v2      # VM size
instance_count: 1                   # Number of instances
```

## Cost Considerations

- **Endpoint**: Charges apply while endpoint is running
- **Instance Type**: Standard_DS2_v2 costs approximately $0.14/hour
- **Always delete endpoints** when not in use to avoid unnecessary charges

## Success Criteria

You've successfully completed this challenge when:

- ✅ Model is registered in Azure ML Studio (Models section)
- ✅ Endpoint is created and shows as "Healthy"
- ✅ Deployment is completed successfully
- ✅ Test predictions return expected results (0 or 1 for each sample)
- ✅ GitHub Actions workflow runs successfully (if using automated deployment)

## Next Steps

After successful deployment:
1. Integrate the endpoint with your web application
2. Set up monitoring and alerts
3. Implement A/B testing with multiple deployments
4. Create a staging environment for testing new models
5. Automate model retraining and deployment

## Quick Links

- **Azure ML Studio**: https://ml.azure.com
- **GitHub Actions**: https://github.com/kumarallamraju/ka-mlops/actions
- **Azure CLI ML Extension**: https://learn.microsoft.com/en-us/cli/azure/ml
