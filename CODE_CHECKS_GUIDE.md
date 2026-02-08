# Code Checks and PR Validation Guide

## ✅ What's Been Done

### 1. Fixed All Linting Issues
- ✅ Fixed missing whitespace after commas
- ✅ Fixed lines too long (> 79 characters)
- ✅ Fixed blank lines with trailing whitespace
- ✅ Fixed blank line spacing between functions
- ✅ All code now passes flake8 linting with zero errors

### 2. Verified Unit Tests Pass
- ✅ All 3 unit tests pass successfully
  - `test_csvs_no_files`
  - `test_csvs_no_files_invalid_path`
  - `test_csvs_creates_dataframe`

### 3. Updated PR Validation Workflow
Updated `.github/workflows/03-pr-validation.yml` with two jobs:

**Job 1: Linting**
- Checks out code
- Sets up Python 3.8
- Installs flake8
- Runs linting on `src/model/`

**Job 2: Unit tests**
- Checks out code
- Sets up Python 3.8
- Installs dependencies from requirements.txt
- Runs pytest on `tests/`

### 4. Created Test Feature Branch
- Branch: `feature/test-code-checks`
- Change: Updated regularization rate to 0.02
- Status: Pushed and ready for PR

### 5. Updated requirements.txt
- Added `flake8==7.1.1` for linting

## 🚀 Next Steps

### Step 1: Create the Pull Request

**Click this link to create the PR:**
👉 https://github.com/kumarallamraju/ka-mlops/pull/new/feature/test-code-checks

Or:
1. Go to https://github.com/kumarallamraju/ka-mlops
2. Click the yellow "Compare & pull request" button
3. Fill in PR details:
   - **Title**: "Update regularization rate to 0.02"
   - **Description**: "Testing PR validation with linting and unit tests"
4. Click "Create pull request"

**Expected Result:**
- ✅ Two status checks will appear:
  - `Linting` - Running flake8 checks
  - `Unit tests` - Running pytest tests
- Both should complete successfully with green checkmarks!

### Step 2: Update Branch Protection Rule

Add the code checks as required status checks:

1. Go to: https://github.com/kumarallamraju/ka-mlops/settings/branches
2. Find your existing branch protection rule for `main` (or create one if it doesn't exist)
3. Click **"Edit"** on the rule
4. Enable: **"Require status checks to pass before merging"**
5. In the search box, add these status checks:
   - `Linting`
   - `Unit tests`
6. Check: ✅ **"Require branches to be up to date before merging"** (optional)
7. Click **"Save changes"**

**Result:** PRs cannot be merged until both checks pass! ✅

### Step 3: Verify Everything Works

1. **Check the PR**: Go to the pull request you created
2. **View the checks**: You should see two checks running:
   - Linting
   - Unit tests
3. **Click "Details"** on each check to see the workflow output
4. **Wait for completion**: Both should show green checkmarks ✅
5. **Try to merge**: The "Merge pull request" button should be enabled after checks pass

## 📋 Success Criteria Checklist

To complete this challenge, you should be able to show:

- [x] No linting errors in `src/model/train.py`
- [x] All unit tests pass locally (verified: 3/3 passed)
- [ ] PR created with both code checks visible
- [ ] Both "Linting" and "Unit tests" checks completed successfully
- [ ] Branch protection rule requires both checks to pass
- [ ] PR shows successful completion of all checks

## 🔍 Verify Locally

You can run the same checks locally before pushing:

### Run Linting:
```bash
.venv/bin/python -m flake8 src/model/
```
**Expected:** No output (no errors) ✅

### Run Unit Tests:
```bash
.venv/bin/python -m pytest tests/ -v
```
**Expected:** `3 passed` ✅

## 🎯 Workflow Details

The PR validation workflow (`.github/workflows/03-pr-validation.yml`) now includes:

### Linting Job
```yaml
- Checkout code
- Setup Python 3.8
- Install flake8
- Run: flake8 src/model/
```

### Unit Tests Job
```yaml
- Checkout code
- Setup Python 3.8
- Install requirements.txt
- Run: pytest tests/
```

Both jobs run independently and must pass for the PR to be mergeable (if branch protection is enabled).

## 🔄 Future Development Workflow

From now on:
1. **Create feature branch**: `git checkout -b feature/your-feature`
2. **Make changes**: Edit code
3. **Test locally**:
   ```bash
   .venv/bin/python -m flake8 src/model/
   .venv/bin/python -m pytest tests/ -v
   ```
4. **Commit and push**: `git push -u origin feature/your-feature`
5. **Create PR**: On GitHub
6. **Wait for checks**: Both linting and unit tests must pass
7. **Get approval**: (if required by branch protection)
8. **Merge PR**: After all checks pass

## 📊 Current Workflow Status

You now have comprehensive CI/CD workflows:

| Workflow | Trigger | Jobs |
|----------|---------|------|
| 02-manual-trigger-job.yml | Push/PR/Manual | Azure ML job |
| 03-pr-validation.yml | PR to main | Linting + Unit tests |
| 04-code-checks.yml | Push/PR/Manual | Linting |

## 🚀 Quick Links

- **Create PR**: https://github.com/kumarallamraju/ka-mlops/pull/new/feature/test-code-checks
- **Actions**: https://github.com/kumarallamraju/ka-mlops/actions
- **Branch Protection**: https://github.com/kumarallamraju/ka-mlops/settings/branches
- **Pull Requests**: https://github.com/kumarallamraju/ka-mlops/pulls

## 🎉 Summary

All code is now:
- ✅ Linting-compliant (flake8)
- ✅ Test-verified (pytest)
- ✅ PR workflow-enabled
- ✅ Ready for branch protection

Create the PR and watch your automated code checks in action!
