# Fastlane Setup for Cove iOS

This directory contains Fastlane configuration for automating iOS app deployment.

## Installation

1. Install Ruby dependencies:
   ```bash
   bundle install
   ```

2. Install CocoaPods:
   ```bash
   pod install
   ```

## Available Lanes

### Build and Test

```bash
# Build the app for testing (no code signing)
bundle exec fastlane build

# Run unit tests
bundle exec fastlane test

# Run SwiftLint (if configured)
bundle exec fastlane lint
```

### Deployment

```bash
# Deploy to TestFlight
bundle exec fastlane beta

# Submit to App Store
# Note: Set version with version parameter
bundle exec fastlane release version:1.1.0
```

## Configuration

The Fastfile is configured for the Cove app with:
- Workspace: `Cove.xcworkspace`
- Scheme: `Cove`
- Bundle ID: `com.danicajiao.cove`

## Environment Variables

For deployment lanes, you'll need:
- `PROVISIONING_PROFILE_SPECIFIER`: Name of your provisioning profile

## CI/CD Integration

These lanes are used by GitHub Actions workflows:
- `deploy-testflight.yml` - Calls `beta` lane
- `release-appstore.yml` - Calls `release` lane
- `pr-checks.yml` - Calls `build` and `test` lanes

See `docs/CI_CD_WORKFLOWS.md` for complete documentation.
