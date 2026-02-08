# Branch Protection and Pull Request Workflow Guide

## ✅ What's Been Set Up

### 1. Pull Request Validation Workflow
Created `.github/workflows/03-pr-validation.yml` that triggers automatically when a PR is created to the `main` branch.

### 2. Feature Branch Created
- **Branch name**: `feature/update-hyperparameters`
- **Change made**: Updated regularization rate from 0.01 to 0.05 in `src/job.yml`
- **Status**: Pushed to GitHub

## 🔧 Next Steps

### Step 1: Create a Pull Request

**Option A: Using the GitHub link from terminal output**
Click this link (or copy from your terminal):
```
https://github.com/kumarallamraju/ka-mlops/pull/new/feature/update-hyperparameters
```

**Option B: Manual steps on GitHub**
1. Go to https://github.com/kumarallamraju/ka-mlops
2. You'll see a yellow banner saying "feature/update-hyperparameters had recent pushes"
3. Click **"Compare & pull request"**
4. Fill in the PR details:
   - **Title**: "Update regularization rate to 0.05"
   - **Description**: "Testing feature-based development workflow with hyperparameter update"
5. Click **"Create pull request"**

✅ **Expected Result**: The "Pull Request Validation" workflow should trigger automatically!

### Step 2: Set Up Branch Protection Rules

#### Navigate to Settings:
1. Go to your repo: https://github.com/kumarallamraju/ka-mlops
2. Click **"Settings"** tab (you need admin/owner access)
3. In the left sidebar, click **"Branches"** under "Code and automation"

#### Create Protection Rule:
1. Click **"Add branch protection rule"** button
2. Configure the following:

**Branch name pattern:**
```
main
```

**Protect matching branches - Enable these settings:**

✅ **Require a pull request before merging**
   - Check this box
   - ✅ **Require approvals**: Set to 1 (optional, but recommended)
   - ✅ **Dismiss stale pull request approvals when new commits are pushed** (optional)

✅ **Require status checks to pass before merging**
   - Check this box
   - Search and add: `validate` (this is the job name from our PR workflow)
   - ✅ **Require branches to be up to date before merging** (optional)

✅ **Require conversation resolution before merging** (optional)

✅ **Do not allow bypassing the above settings** (optional, but recommended)

**Note for Repository Administrators:**
- By default, branch protection rules do not apply to administrators
- If you want rules to apply to admins too, check: **"Do not allow bypassing the above settings"**
- Or uncheck: **"Allow specified actors to bypass required pull requests"**

3. Click **"Create"** or **"Save changes"**

### Step 3: Verify Branch Protection

Try to push directly to main (it should be blocked):
```bash
git checkout main
echo "test" >> test.txt
git add test.txt
git commit -m "test direct push"
git push
```

**Expected Result**: 
- If you're not an admin: Push will be rejected ❌
- If you're an admin: Push will succeed (unless you disabled bypass) ⚠️

### Step 4: Complete the PR Workflow

1. **View the PR**: Go to the Pull Requests tab on GitHub
2. **Check the workflow**: You should see the "Pull Request Validation" check running/completed
3. **Review the changes**: Check the Files changed tab
4. **Merge the PR**: Once the workflow passes, click "Merge pull request"
5. **Delete the branch**: After merging, delete the feature branch (optional)

## 📊 Success Criteria Checklist

To complete this challenge, you should be able to show:

- [ ] Branch protection rule for the `main` branch is active
- [ ] A successfully completed "Pull Request Validation" workflow
- [ ] The workflow was triggered by the pull request
- [ ] Direct pushes to main are blocked (or at least warned)

## 🎯 Verification Commands

### Check current branch:
```bash
git branch
```

### View branch protection on CLI (requires GitHub CLI):
```bash
gh api repos/kumarallamraju/ka-mlops/branches/main/protection
```

### List all workflows:
```bash
gh workflow list
```

### View PR status:
```bash
gh pr list
gh pr view <pr-number>
```

## 🔄 Future Workflow

From now on, the development process should be:

1. **Create a feature branch**: `git checkout -b feature/your-feature-name`
2. **Make changes**: Edit files as needed
3. **Commit changes**: `git add . && git commit -m "description"`
4. **Push branch**: `git push -u origin feature/your-feature-name`
5. **Create PR**: On GitHub, create a pull request to main
6. **Wait for checks**: PR validation workflow runs automatically
7. **Review & Merge**: After approval and passing checks, merge the PR
8. **Clean up**: Delete the feature branch

## 📝 Additional Workflows

You now have three workflows:
1. **02-manual-trigger-job.yml**: Triggers Azure ML job (push/PR/manual)
2. **03-pr-validation.yml**: Validates pull requests (PR only)
3. **04-code-checks.yml**: Runs linting checks (push/PR/manual)

All are integrated into your PR process!

## 🚀 Quick Links

- **Create PR**: https://github.com/kumarallamraju/ka-mlops/pull/new/feature/update-hyperparameters
- **Actions**: https://github.com/kumarallamraju/ka-mlops/actions
- **Branch Settings**: https://github.com/kumarallamraju/ka-mlops/settings/branches
- **Pull Requests**: https://github.com/kumarallamraju/ka-mlops/pulls
