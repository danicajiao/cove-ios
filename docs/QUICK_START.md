# Quick Start Guide - iOS CI/CD

This is a quick reference guide to get started with the iOS CI/CD workflows for Cove.

## 📋 Prerequisites

Before you begin, ensure you have:
- ✅ Apple Developer account with Admin/App Manager role
- ✅ Access to App Store Connect
- ✅ Access to repository settings (for configuring secrets)
- ✅ Distribution certificate and provisioning profile

## 🚀 Quick Setup (5 Steps)

### Step 1: Configure GitHub Secrets (15 minutes)

Navigate to: **Repository Settings → Secrets and variables → Actions**

Add these 9 secrets:

| Secret Name | Description |
|------------|-------------|
| `CERTIFICATES_P12` | Base64-encoded distribution certificate |
| `CERTIFICATES_PASSWORD` | Certificate password |
| `PROVISIONING_PROFILE` | Base64-encoded provisioning profile |
| `PROVISIONING_PROFILE_SPECIFIER` | Profile name (e.g., "Cove App Store") |
| `APPLE_TEAM_ID` | Your Apple Team ID |
| `APP_STORE_CONNECT_API_KEY_ID` | API Key ID |
| `APP_STORE_CONNECT_API_ISSUER_ID` | API Issuer ID |
| `APP_STORE_CONNECT_API_KEY` | Base64-encoded API key (.p8) |
| `GH_PAT` | GitHub Personal Access Token |

📖 **Detailed instructions**: See [docs/SECRETS_SETUP.md](SECRETS_SETUP.md)

### Step 2: Verify Workflows Are Active (1 minute)

1. Go to **Actions** tab in your repository
2. You should see 3 workflows:
   - ✅ PR Quality Checks
   - ✅ Deploy to TestFlight
   - ✅ Release to App Store

### Step 3: Test PR Checks (5 minutes)

Create a test PR to verify the build and test workflow:

```bash
git checkout -b test/ci-setup
echo "# CI Test" >> test.md
git add test.md
git commit -m "test: CI workflow"
git push origin test/ci-setup
```

Create a PR and watch the checks run!

### Step 4: Deploy to TestFlight (Manual)

When ready to deploy to TestFlight, manually trigger the workflow:

1. Go to **Actions** tab → **CD - Deploy to TestFlight**
2. Click **Run workflow** → Select `main` branch
3. Optionally provide a deployment reason
4. Click **Run workflow**

The workflow will:
1. ✅ Auto-increment build number
2. ✅ Build and archive the app
3. ✅ Upload to TestFlight

### Step 5: Release to App Store (Manual Trigger)

When ready to submit to App Store, manually trigger the workflow:

1. Go to **Actions** tab → **CD - Release to App Store**
2. Click **Run workflow** → Select `main` branch
3. Click **Run workflow**

**Note:** The workflow currently uses legacy tag parsing logic that is non-functional with the manual trigger. The version cannot be specified when triggering.

## 📊 Understanding the Workflows

### 1. PR Quality Checks
**Trigger:** Pull request to `main`

**What it does:**
- Builds the app
- Runs tests
- Checks code with SwiftLint (if configured)

**No version changes!**

### 2. Deploy to TestFlight
**Trigger:** Manual workflow dispatch with optional reason input

**What it does:**
- Auto-increments build number (1 → 2 → 3...)
- Keeps marketing version the same (e.g., 1.0.0)
- Deploys to TestFlight

**Result:** `1.0.0 (2)`, `1.0.0 (3)`, etc.

### 3. Release to App Store
**Trigger:** Manual workflow dispatch

**What it does:**
- Auto-increments build number
- Submits to App Store Connect

**Note:** Version cannot currently be specified when triggering. The workflow has legacy tag parsing logic that is non-functional with manual trigger.

## 🔄 Daily Workflow

### For Development:
```
1. Create feature branch
2. Make changes
3. Create PR → CI checks run automatically
4. Merge PR
5. Manually trigger TestFlight deployment when ready
6. Test in TestFlight
7. Repeat!
```

### For Release:
```
1. Decide version number (e.g., 1.1.0)
2. Manually trigger App Store release workflow
3. Workflow submits to App Store Connect
4. Monitor in App Store Connect
```

## 🎯 Version Number Examples

| Action | Marketing Version | Build Number |
|--------|------------------|--------------|
| Initial state | 1.0.0 | 1 |
| Manual TestFlight deploy | 1.0.0 | 2 |
| Manual TestFlight deploy | 1.0.0 | 3 |
| Manual TestFlight deploy | 1.0.0 | 4 |
| **Manual App Store release** | **1.0.0** | **5** |
| Manual TestFlight deploy | 1.0.0 | 6 |
| Manual TestFlight deploy | 1.0.0 | 7 |

**Note:** Marketing version does not automatically increment with current workflow configuration.

## 🐛 Common Issues

### Build fails with "No provisioning profile"
→ Check `PROVISIONING_PROFILE_SPECIFIER` matches exactly

### "Incorrect password" error
→ Verify `CERTIFICATES_PASSWORD` is correct

### Can't push build number change
→ Ensure `GH_PAT` has `repo` scope

### Build number already exists in TestFlight
→ Should never happen with auto-increment; check if script ran

## 📚 Additional Resources

- [Complete CI/CD Documentation](CI_CD_WORKFLOWS.md)
- [Detailed Secrets Setup Guide](SECRETS_SETUP.md)
- [Fastlane Configuration](../fastlane/README.md)

## 🆘 Getting Help

1. Check the [Troubleshooting section](CI_CD_WORKFLOWS.md#troubleshooting) in full docs
2. Review workflow logs in GitHub Actions tab
3. Open an issue in the repository

---

**Last Updated**: February 2026
