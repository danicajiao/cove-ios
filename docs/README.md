# iOS CI/CD Documentation

Welcome to the iOS CI/CD documentation for the Cove iOS app.

## 📖 Documentation Structure

### Getting Started
- **[Quick Start Guide](QUICK_START.md)** - Get up and running in 5 steps (20 minutes)
  - Perfect for first-time setup
  - Covers all essential configuration
  - Includes common troubleshooting tips

### Detailed Guides
- **[Secrets Setup Guide](SECRETS_SETUP.md)** - Complete guide for configuring GitHub secrets
  - Step-by-step instructions with commands
  - Covers code signing, App Store Connect API, and GitHub PAT
  - Includes security best practices

- **[CI/CD Workflows Guide](CI_CD_WORKFLOWS.md)** - Complete workflow documentation
  - Detailed explanation of all three workflows
  - Versioning strategy and examples
  - Local development instructions
  - Troubleshooting and best practices

### Technical Reference
- **[Fastlane Configuration](../fastlane/README.md)** - Fastlane setup and usage
  - Available lanes and commands
  - Configuration details
  - CI/CD integration notes

## 🎯 Which Document Should I Read?

### I'm setting up CI/CD for the first time
→ Start with [Quick Start Guide](QUICK_START.md)

### I need to configure secrets
→ Follow [Secrets Setup Guide](SECRETS_SETUP.md)

### I want to understand how workflows work
→ Read [CI/CD Workflows Guide](CI_CD_WORKFLOWS.md)

### I'm working with Fastlane locally
→ Check [Fastlane Configuration](../fastlane/README.md)

### Something isn't working
→ See Troubleshooting sections in [CI/CD Workflows Guide](CI_CD_WORKFLOWS.md) or [Quick Start Guide](QUICK_START.md)

## 🚀 Three Workflows

### 1. PR Quality Checks
**File:** `.github/workflows/ci-pr.yml`
- Runs on every pull request
- Builds and tests the app
- No version changes

### 2. Deploy to TestFlight
**File:** `.github/workflows/cd-testflight.yml`
- Manual trigger (workflow_dispatch)
- Auto-increments build number
- Deploys to TestFlight

### 3. Release to App Store
**File:** `.github/workflows/cd-appstore.yml`
- Manual trigger (workflow_dispatch)
- Updates marketing version
- Submits to App Store Connect

## 🔑 Required Secrets

All workflows require these GitHub secrets to be configured:

### Code Signing (5 secrets)
- `CERTIFICATES_P12`
- `CERTIFICATES_PASSWORD`
- `PROVISIONING_PROFILE`
- `PROVISIONING_PROFILE_SPECIFIER`
- `APPLE_TEAM_ID`

### App Store Connect (3 secrets)
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY`

### GitHub (1 secret)
- `GH_PAT`

## 📊 Version Management

### Build Number (CFBundleVersion)
- **Auto-incremented** on every deployment
- Format: Integer (1, 2, 3, 4...)
- Managed by: CI/CD workflows

### Marketing Version (CFBundleShortVersionString)
- **Manually set** via release tags
- Format: Semantic versioning (1.0.0, 1.1.0, 2.0.0)
- Managed by: Developer via GitHub releases

## 🛠 Tools & Technologies

- **GitHub Actions** - CI/CD orchestration
- **Fastlane** - iOS automation
- **CocoaPods** - Dependency management
- **Xcode** - iOS development
- **TestFlight** - Beta testing
- **App Store Connect** - App distribution

## 📞 Support

For issues or questions:
1. Check the troubleshooting sections in the guides
2. Review GitHub Actions logs
3. Open an issue in the repository

## 🔗 External Resources

- [Fastlane Documentation](https://docs.fastlane.tools/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Apple Developer Portal](https://developer.apple.com/)
- [App Store Connect](https://appstoreconnect.apple.com/)

---

**Last Updated**: February 2026
