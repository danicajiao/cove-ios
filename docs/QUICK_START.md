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

### Step 4: Deploy to TestFlight (Automatic)

Once a PR is merged to `main`:
1. ✅ Build number auto-increments
2. ✅ App builds and archives
3. ✅ Uploads to TestFlight automatically

**That's it!** No manual steps needed.

### Step 5: Release to App Store (Manual Trigger)

When ready to submit to App Store:

```bash
# Tag the release
git tag v1.1.0
git push origin v1.1.0

# Then create a GitHub Release with that tag
# The workflow will automatically:
# - Update marketing version to 1.1.0
# - Increment build number
# - Build and submit to App Store Connect
```

## 📊 Understanding the Workflows

### 1. PR Quality Checks
**Trigger:** Pull request to `main`

**What it does:**
- Builds the app
- Runs tests
- Checks code with SwiftLint (if configured)

**No version changes!**

### 2. Deploy to TestFlight
**Trigger:** Push to `main` (merged PR)

**What it does:**
- Auto-increments build number (1 → 2 → 3...)
- Keeps marketing version the same (e.g., 1.0.0)
- Deploys to TestFlight

**Result:** `1.0.0 (2)`, `1.0.0 (3)`, etc.

### 3. Release to App Store
**Trigger:** Creating a GitHub release with tag `v*.*.*`

**What it does:**
- Updates marketing version from tag (v1.1.0 → 1.1.0)
- Auto-increments build number
- Submits to App Store Connect

**Result:** `1.1.0 (5)` submitted to App Store

## 🔄 Daily Workflow

### For Development:
```
1. Create feature branch
2. Make changes
3. Create PR → CI checks run automatically
4. Merge PR → Auto-deploys to TestFlight
5. Test in TestFlight
6. Repeat!
```

### For Release:
```
1. Decide version number (e.g., 1.1.0)
2. Create and push tag: git tag v1.1.0
3. Create GitHub release with that tag
4. Workflow automatically submits to App Store
5. Monitor in App Store Connect
```

## 🎯 Version Number Examples

| Action | Marketing Version | Build Number |
|--------|------------------|--------------|
| Initial state | 1.0.0 | 1 |
| Merge PR #1 | 1.0.0 | 2 |
| Merge PR #2 | 1.0.0 | 3 |
| Merge PR #3 | 1.0.0 | 4 |
| **Release v1.1.0** | **1.1.0** | **5** |
| Merge PR #4 | 1.1.0 | 6 |
| Merge PR #5 | 1.1.0 | 7 |

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
