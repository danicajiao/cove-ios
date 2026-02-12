# CI/CD Architecture Overview

This document provides a high-level overview of how the iOS CI/CD system works.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         GitHub Repository                        │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  Developer   │  │   PR Created │  │   Release Created    │  │
│  │  Pushes Code │  │              │  │   (Manual Trigger)   │  │
│  └──────┬───────┘  └──────┬───────┘  └──────────┬───────────┘  │
│         │                  │                      │               │
│         ▼                  ▼                      ▼               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │              │  │              │  │                      │  │
│  │  Merge to    │  │  PR Checks   │  │  App Store Release   │  │
│  │  Main Branch │  │  Workflow    │  │  Workflow            │  │
│  │              │  │              │  │                      │  │
│  └──────┬───────┘  └──────┬───────┘  └──────────┬───────────┘  │
│         │                  │                      │               │
└─────────┼──────────────────┼──────────────────────┼───────────────┘
          │                  │                      │
          ▼                  ▼                      ▼
   ┌─────────────┐    ┌─────────────┐      ┌─────────────┐
   │  TestFlight │    │    Build    │      │  App Store  │
   │  Deployment │    │     Only    │      │   Connect   │
   │             │    │  (No Deploy)│      │             │
   └─────────────┘    └─────────────┘      └─────────────┘
```

## Workflow Interactions

### 1. Development Flow (PR Checks)

```
Pull Request → PR Checks Workflow
                     ↓
              ┌─────────────┐
              │  Checkout   │
              │  Install    │
              │  Build      │
              │  Test       │
              │  Lint       │
              └─────────────┘
                     ↓
              Status Posted
              to PR
```

**Key Points:**
- No version changes
- No deployment
- Fast feedback loop
- Runs in parallel with other PRs

### 2. TestFlight Flow (Continuous Deployment)

```
Merge to Main → TestFlight Workflow
                     ↓
        ┌───────────────────────┐
        │  Increment Build #    │ ← Auto-increment script
        └───────────┬───────────┘
                    ↓
        ┌───────────────────────┐
        │  Commit & Push        │ ← Updates Info.plist
        └───────────┬───────────┘
                    ↓
        ┌───────────────────────┐
        │  Build & Archive      │ ← Code signing
        └───────────┬───────────┘
                    ↓
        ┌───────────────────────┐
        │  Upload to TestFlight │ ← altool
        └───────────────────────┘
```

**Key Points:**
- Auto-increments build number (CFBundleVersion)
- Keeps marketing version unchanged
- Commits build number back to repo
- Deploys to TestFlight automatically

### 3. App Store Flow (Manual Release)

```
Create Release → App Store Workflow
  (v1.1.0)              ↓
         ┌──────────────────────────┐
         │  Extract Version from Tag│ ← v1.1.0 → 1.1.0
         └──────────┬───────────────┘
                    ↓
         ┌──────────────────────────┐
         │  Update Marketing Version│ ← Info.plist
         └──────────┬───────────────┘
                    ↓
         ┌──────────────────────────┐
         │  Increment Build #       │ ← Auto-increment
         └──────────┬───────────────┘
                    ↓
         ┌──────────────────────────┐
         │  Commit & Push           │
         └──────────┬───────────────┘
                    ↓
         ┌──────────────────────────┐
         │  Build & Archive         │
         └──────────┬───────────────┘
                    ↓
         ┌──────────────────────────┐
         │  Submit to App Store     │
         └──────────┬───────────────┘
                    ↓
         ┌──────────────────────────┐
         │  Update Release Notes    │
         └──────────────────────────┘
```

**Key Points:**
- Updates both marketing version and build number
- Submits to App Store Connect for review
- Updates GitHub release with build info

## File Structure & Responsibilities

### Workflow Files (.github/workflows/)
```
pr-checks.yml
├── Triggers on: Pull Request
├── Uses: Xcode build commands
└── No dependencies on Fastlane

deploy-testflight.yml
├── Triggers on: Push to main
├── Uses: Xcode + increment script
└── Requires: All GitHub secrets

### Workflow Files (.github/workflows/)
```
pr-checks.yml
├── Triggers on: Pull Request
├── Uses: Xcode build commands
└── No dependencies on Fastlane

deploy-testflight.yml
├── Triggers on: Push to main
├── Uses: Fastlane beta lane
└── Requires: All GitHub secrets

release-appstore.yml
├── Triggers on: Release creation
├── Uses: Fastlane release lane
└── Requires: All GitHub secrets
```

### Fastlane (fastlane/)
```
Fastfile
├── Purpose: iOS automation for CI/CD and local development
├── Lanes: build, test, beta, release, bump_build
└── Features: 
    - TestFlight build number synchronization
    - Automated version bumping and git commits
    - Code signing and archiving
    - Upload to TestFlight and App Store Connect
```

### Documentation (docs/)
```
README.md              → Documentation index
QUICK_START.md         → 20-minute setup guide
SECRETS_SETUP.md       → Detailed secrets configuration
CI_CD_WORKFLOWS.md     → Complete workflow documentation
ARCHITECTURE.md        → This file
```

## Version Management Logic

### Build Number (CFBundleVersion)

```ruby
# Fastlane bump_build lane logic
current_build = get_build_number(xcodeproj: "Cove.xcodeproj")

# Try to sync with TestFlight to avoid conflicts
begin
  latest_testflight = latest_testflight_build_number
  new_build = max(current_build, latest_testflight) + 1
rescue
  # Fall back to simple increment if TestFlight unavailable
  new_build = current_build + 1
end

increment_build_number(build_number: new_build, xcodeproj: "Cove.xcodeproj")
```

**Location:** `fastlane/Fastfile` - `bump_build` lane

### Marketing Version (CFBundleShortVersionString)

```ruby
# Fastlane release lane logic
version = options[:version]  # From workflow (e.g., "1.1.0")
increment_version_number(
  version_number: version,
  xcodeproj: "Cove.xcodeproj"
)
```

**Location:** `release-appstore.yml` workflow

## Security Architecture

### Secrets Storage
```
GitHub Repository Secrets
├── Code Signing Secrets (5)
│   ├── CERTIFICATES_P12 (Base64)
│   ├── CERTIFICATES_PASSWORD
│   ├── PROVISIONING_PROFILE (Base64)
│   ├── PROVISIONING_PROFILE_SPECIFIER
│   └── APPLE_TEAM_ID
├── App Store Connect API (3)
│   ├── APP_STORE_CONNECT_API_KEY_ID
│   ├── APP_STORE_CONNECT_API_ISSUER_ID
│   └── APP_STORE_CONNECT_API_KEY (Base64)
└── GitHub Access (1)
    └── GH_PAT
```

### Secret Usage

| Workflow | Secrets Used |
|----------|-------------|
| PR Checks | None |
| TestFlight | All 9 secrets |
| App Store Release | All 9 secrets |

### Security Best Practices
1. ✅ Secrets stored in GitHub (encrypted)
2. ✅ Never logged or exposed in workflow output
3. ✅ Base64 encoding for binary files
4. ✅ Personal Access Token for git operations
5. ✅ App Store Connect API instead of username/password

## Dependency Chain

```
GitHub Actions (Runner: macOS-latest)
    ↓
Ruby 3.2 + Bundler
    ↓
CocoaPods (via Podfile)
    ↓
Xcode 15.2
    ↓
iOS SDK
```

### Tools Version Matrix

| Tool | Version | Purpose |
|------|---------|---------|
| macOS | latest | GitHub Actions runner |
| Xcode | 15.2 | iOS development |
| Ruby | 3.2 | Fastlane runtime |
| CocoaPods | 1.15 | Dependency management |
| Fastlane | 2.219 | iOS automation (optional) |

## Data Flow

### PR Check Flow
```
Source Code → Build → Tests → Lint → ✓/✗ Status
```

### TestFlight Flow
```
Source Code → Increment → Build → Sign → Archive → Export → Upload → TestFlight
                ↓
           Commit Back
```

### App Store Flow
```
Release Tag → Extract → Update Version → Increment → Build → Sign →
                                                                      ↓
TestFlight ← Upload ← Export ← Archive ← (Build continues...)
     ↓
Update Release Notes
```

## Integration Points

### With Apple Services
- **TestFlight**: Beta distribution and testing
- **App Store Connect**: Production app distribution
- **Developer Portal**: Code signing certificates & profiles

### With GitHub
- **Actions**: CI/CD execution
- **Secrets**: Secure credential storage
- **Releases**: Trigger for App Store submissions
- **Pull Requests**: Quality gate enforcement

### With Developer Machine
- **Fastlane**: Local testing of automation
- **Git**: Version control and tagging
- **Xcode**: Development and local builds

## Monitoring & Observability

### Workflow Logs
- Available in: GitHub Actions tab
- Retention: 90 days
- Contains: Build output, test results, deployment status

### Build Artifacts
- Stored on failure: Build logs
- Location: GitHub Actions artifacts
- Purpose: Debugging failed builds

### Notifications
- PR status checks: Automatic
- Email notifications: Configurable in GitHub settings
- Slack/Discord: Can be added via GitHub Actions

## Future Enhancements

Potential improvements to consider:

1. **Automated Screenshot Generation**
   - Generate App Store screenshots
   - Upload via Fastlane

2. **Automated Release Notes**
   - Generate from commit messages
   - Update App Store Connect metadata

3. **Matrix Testing**
   - Test on multiple iOS versions
   - Test on multiple devices

4. **Performance Monitoring**
   - Track build times
   - Monitor binary size

5. **Deployment Notifications**
   - Slack notifications on deployment
   - Email notifications to stakeholders

---

**Last Updated**: February 2026
