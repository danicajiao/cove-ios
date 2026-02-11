# iOS CI/CD Workflows Documentation

This document describes the CI/CD workflows configured for the Cove iOS app, including deployment to TestFlight and App Store.

## Overview

The Cove iOS app uses GitHub Actions for continuous integration and deployment following mobile development best practices:

- **Automated TestFlight deployments** on every merge to `main`
- **App Store submissions** triggered by release creation
- **Quality checks** on every pull request
- **Auto-incrementing build numbers** for each deployment
- **Manual marketing version bumps** only when releasing to App Store

## Workflows

### 1. PR Quality Checks (`pr-checks.yml`)

**Trigger:** Pull requests to `main` branch

**Purpose:** Ensure code quality before merging

**Steps:**
- ✅ Build the iOS app
- ✅ Run unit tests
- ✅ Run SwiftLint (if `.swiftlint.yml` exists)

**Configuration:**
- Runs on macOS latest
- Uses Xcode 15.2
- Builds for iOS Simulator (no code signing required)
- Uses CocoaPods for dependency management

**Note:** This workflow does NOT check version numbers, as version management is handled by the deployment workflows.

### 2. Deploy to TestFlight (`deploy-testflight.yml`)

**Trigger:** Push to `main` branch (typically from merged PRs)

**Purpose:** Automatically deploy to TestFlight for beta testing

**Steps:**
1. Checkout code
2. Install dependencies (Ruby, Fastlane, CocoaPods)
3. **Auto-increment build number** (`CFBundleVersion`)
4. Commit and push build number change
5. Import code signing certificates
6. Download provisioning profiles
7. Build and archive the app
8. Export IPA
9. Upload to TestFlight

**Versioning:**
- `CFBundleVersion` (Build Number): **Auto-incremented** (1, 2, 3, 4...)
- `CFBundleShortVersionString` (Marketing Version): **Unchanged** (stays at current version like 1.0)

### 3. Release to App Store (`release-appstore.yml`)

**Trigger:** Creation of a new GitHub release

**Purpose:** Submit a new version to App Store Connect

**Steps:**
1. Extract version from release tag (e.g., `v1.1.0` → `1.1.0`)
2. **Update marketing version** in Info.plist
3. **Auto-increment build number**
4. Commit version updates
5. Import code signing certificates
6. Build and archive the app
7. Export IPA
8. Upload to App Store Connect
9. Update release notes with build information

**Versioning:**
- `CFBundleShortVersionString`: **Manually set via release tag** (e.g., 1.0.0 → 1.1.0)
- `CFBundleVersion`: **Auto-incremented** for each release

**Creating a Release:**
```bash
# Example: Releasing version 1.1.0
git tag v1.1.0
git push origin v1.1.0
# Then create a release on GitHub with tag v1.1.0
```

## Required Secrets

The following secrets must be configured in your GitHub repository settings:

### Code Signing
- `CERTIFICATES_P12`: Base64-encoded .p12 certificate file
- `CERTIFICATES_PASSWORD`: Password for the .p12 certificate
- `PROVISIONING_PROFILE`: Base64-encoded provisioning profile
- `PROVISIONING_PROFILE_SPECIFIER`: Name of the provisioning profile
- `APPLE_TEAM_ID`: Your Apple Developer Team ID

### App Store Connect API
- `APP_STORE_CONNECT_API_KEY_ID`: API Key ID from App Store Connect
- `APP_STORE_CONNECT_API_ISSUER_ID`: Issuer ID from App Store Connect
- `APP_STORE_CONNECT_API_KEY`: Base64-encoded API Key (.p8 file)

### GitHub
- `GH_PAT`: GitHub Personal Access Token with repo permissions (for pushing commits)

## Versioning Strategy

### Build Number (`CFBundleVersion`)
- **Purpose:** Unique identifier for each build
- **Format:** Integer (1, 2, 3, 4...)
- **Management:** Auto-incremented by CI/CD on every deployment
- **Usage:** Used for TestFlight builds and App Store submissions

### Marketing Version (`CFBundleShortVersionString`)
- **Purpose:** User-facing version number
- **Format:** Semantic versioning (1.0.0, 1.1.0, 2.0.0)
- **Management:** Manually updated only when creating a release
- **Usage:** Displayed to users in App Store and Settings

### Version Flow Example

1. **Development Phase:**
   - Marketing Version: `1.0.0`
   - Multiple merges to main → Build numbers: 1, 2, 3, 4...
   - Each build deploys to TestFlight with version `1.0.0 (1)`, `1.0.0 (2)`, etc.

2. **Release Phase:**
   - Create release with tag `v1.1.0`
   - Marketing Version updated to `1.1.0`
   - Build number continues incrementing (e.g., 5)
   - Submits to App Store as version `1.1.0 (5)`

3. **Post-Release:**
   - Marketing Version stays at `1.1.0`
   - Continue development and merging
   - Build numbers keep incrementing: 6, 7, 8...
   - TestFlight receives `1.1.0 (6)`, `1.1.0 (7)`, etc.

## Setup Instructions

### 1. Configure Secrets

Add all required secrets to your GitHub repository:
1. Go to Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add each secret listed above

### 2. Set up Code Signing

```bash
# Export certificate to .p12
# In Keychain Access:
# 1. Select your distribution certificate
# 2. File → Export Items
# 3. Save as .p12 with a password

# Base64 encode the certificate
base64 -i YourCertificate.p12 -o certificate.txt
# Copy contents of certificate.txt to CERTIFICATES_P12 secret

# Base64 encode the provisioning profile
base64 -i YourProfile.mobileprovision -o profile.txt
# Copy contents of profile.txt to PROVISIONING_PROFILE secret
```

### 3. Create App Store Connect API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Users and Access → Keys
3. Generate a new API key with App Manager role
4. Download the .p8 file
5. Note the Key ID and Issuer ID
6. Base64 encode the .p8 file and add to secrets

### 4. Install Fastlane (Local Development)

```bash
# Install Ruby dependencies
bundle install

# Install CocoaPods
pod install

# Run Fastlane lanes locally
bundle exec fastlane build    # Build for testing
bundle exec fastlane test     # Run tests
bundle exec fastlane beta     # Deploy to TestFlight
bundle exec fastlane release  # Deploy to App Store
```

## Tools Used

- **GitHub Actions**: CI/CD orchestration
- **Fastlane**: iOS automation (building, signing, deploying)
- **CocoaPods**: Dependency management
- **xcodebuild**: Building and archiving iOS apps
- **xcpretty**: Formatting build output
- **TestFlight**: Beta testing platform
- **App Store Connect**: App distribution and management

## Local Development

### Building the App
```bash
xcodebuild build \
  -workspace Cove.xcworkspace \
  -scheme Cove \
  -sdk iphonesimulator
```

### Running Tests
```bash
xcodebuild test \
  -workspace Cove.xcworkspace \
  -scheme Cove \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Incrementing Build Number
```bash
./scripts/ci/increment-build-number.sh "Cove/Supporting Files/Info.plist"
```

## Troubleshooting

### Build Fails with Code Signing Error
- Verify all code signing secrets are correctly configured
- Check that provisioning profile matches the bundle identifier
- Ensure certificates haven't expired

### TestFlight Upload Fails
- Verify App Store Connect API credentials
- Check that the bundle identifier matches your App Store Connect app
- Ensure you have proper permissions in App Store Connect

### Build Number Already Exists
- TestFlight requires unique build numbers
- The auto-increment script should prevent this
- If it occurs, manually increment the build number

### CocoaPods Installation Fails
- Clear CocoaPods cache: `pod cache clean --all`
- Update CocoaPods: `gem install cocoapods`
- Delete `Podfile.lock` and `Pods` directory, then run `pod install`

## Best Practices

1. **Never commit sensitive data**: Certificates, keys, and profiles should only be in GitHub Secrets
2. **Use pull requests**: All code should go through PR review and CI checks
3. **Test before releasing**: Use TestFlight builds for thorough testing before App Store submission
4. **Follow semantic versioning**: Major.Minor.Patch (e.g., 1.2.3)
5. **Document changes**: Include clear release notes in GitHub releases
6. **Monitor build numbers**: Ensure they increment correctly to avoid conflicts

## References

- [Fastlane Documentation](https://docs.fastlane.tools/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Apple Developer Portal](https://developer.apple.com/)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [CocoaPods](https://cocoapods.org/)
