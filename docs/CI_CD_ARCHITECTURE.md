# CI/CD Architecture Overview

This document provides a high-level overview of how the iOS CI/CD system works.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         GitHub Repository                        │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  PR Created  │  │ Push to Main │  │  Manual Deployment   │  │
│  │              │  │              │  │      Triggers        │  │
│  └──────┬───────┘  └──────┬───────┘  └──────────┬───────────┘  │
│         │                  │                      │               │
│         ▼                  ▼                      ▼               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │              │  │              │  │                      │  │
│  │   CI - PR    │  │  CI - Main   │  │  CD - TestFlight    │  │
│  │   Checks     │  │  Build/Test  │  │  CD - App Store     │  │
│  │              │  │              │  │                      │  │
│  └──────┬───────┘  └──────┬───────┘  └──────────┬───────────┘  │
│         │                  │                      │               │
└─────────┼──────────────────┼──────────────────────┼───────────────┘
          │                  │                      │
          ▼                  ▼                      ▼
   ┌─────────────┐    ┌─────────────┐      ┌─────────────┐
   │    Lint     │    │  Build/Test │      │  TestFlight │
   │    Only     │    │   Results   │      │  App Store  │
   │             │    │             │      │   Connect   │
   └─────────────┘    └─────────────┘      └─────────────┘
```

## Workflow Interactions

### 1. Development Flow (PR Checks)

```
Pull Request → CI-PR Workflow
                     ↓
              ┌─────────────┐
              │  Checkout   │
              │  SwiftLint  │
              │  Check      │
              │  Conflicts  │
              │  Validate   │
              │  Info.plist │
              └─────────────┘
                     ↓
              Status Posted
              to PR
```

**Key Points:**
- Fast feedback (linting only)
- No version changes
- No build/test execution
- No deployment
- Runs in parallel with other PRs

### 2. Main Branch Flow (Continuous Validation)

```
Push to Main → CI-Main Workflow
                     ↓
         ┌───────────────────────┐
         │  Setup Ruby & Pods    │
         └───────────┬───────────┘
                     ↓
         ┌───────────────────────┐
         │  Build via Fastlane   │
         └───────────┬───────────┘
                     ↓
         ┌───────────────────────┐
         │  Test via Fastlane    │
         │  (continue on error)  │
         └───────────────────────┘
```

**Key Points:**
- Validates build after merge
- Runs tests but continues on failure
- No version changes
- No deployment
- Uses Fastlane lanes

### 3. TestFlight Flow (Manual Deployment)

```
Manual Trigger → CD-TestFlight Workflow
                     ↓
         ┌───────────────────────┐
         │  Setup & Dependencies │
         └───────────┬───────────┘
                     ↓
         ┌───────────────────────┐
         │  Code Signing Setup   │
         └───────────┬───────────┘
                     ↓
         ┌───────────────────────┐
         │  Fastlane Beta Lane   │
         │  - Increment Build #  │ ← Auto-increment script
         │  - Build & Archive    │ ← Code signing
         │  - Upload TestFlight  │ ← App Store Connect API
         │  - Commit & Push      │ ← Updates Info.plist
         └───────────┬───────────┘
                     ↓
         ┌───────────────────────┐
         │  Create GitHub Release│
         │  (prerelease=true)    │
         └───────────────────────┘
```

**Key Points:**
- Manually triggered via workflow_dispatch
- Auto-increments build number (CFBundleVersion)
- Keeps marketing version unchanged
- Commits build number back to repo
- Creates prerelease on GitHub
- Deploys to TestFlight

### 4. App Store Flow (Manual Release)

```
Manual Trigger → CD-App Store Workflow
                     ↓
         ┌───────────────────────┐
         │  Setup & Dependencies │
         └───────────┬───────────┘
                     ↓
         ┌───────────────────────┐
         │  Code Signing Setup   │
         └───────────┬───────────┘
                     ↓
         ┌───────────────────────┐
         │  Fastlane Release Lane│
         │  - Update Version     │ ← From parameter
         │  - Increment Build #  │ ← Auto-increment
         │  - Build & Archive    │
         │  - Submit App Store   │
         │  - Commit & Push      │
         └───────────┬───────────┘
                     ↓
         ┌───────────────────────┐
         │  Update Release Notes │
         │  (or create new)      │
         └───────────────────────┘
```

**Key Points:**
- Manually triggered via workflow_dispatch
- Updates both marketing version and build number
- Version passed as parameter to Fastlane lane
- Submits to App Store Connect for review
- Updates GitHub release with build info

## File Structure & Responsibilities

### Workflow Files (.github/workflows/)
```
ci-pr.yml
├── Triggers on: Pull Request to main
├── Validates: Linting, conflicts, Info.plist
└── No build/test execution

ci-main.yml
├── Triggers on: Push to main
├── Uses: Fastlane build and test lanes
└── No deployment

cd-testflight.yml
├── Triggers on: Manual workflow_dispatch
├── Uses: Fastlane beta lane
└── Requires: All GitHub secrets

cd-appstore.yml
├── Triggers on: Manual workflow_dispatch
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

**Note:** The `APPLE_TEAM_ID` secret is not currently used by workflows.

## Dependency Chain

```
GitHub Actions (Runner: macOS-26)
    ↓
Ruby 4.0.1 + Bundler
    ↓
Fastlane ~2.219 + CocoaPods ~1.15 (via Gemfile)
    ↓
Xcode (from macOS-26 runner)
    ↓
iOS SDK
```

### Tools Version Matrix

| Tool | Version | Purpose |
|------|---------|---------|
| macOS | macOS-26 | GitHub Actions runner |
| Xcode | Bundled with macOS-26 | iOS development |
| Ruby | 4.0.1 | Fastlane runtime |
| CocoaPods | ~1.15 | Dependency management |
| Fastlane | ~2.219 | iOS automation |

## Data Flow

### PR Check Flow
```
Source Code → Lint → Check Conflicts → Validate Info.plist → ✓/✗ Status
```

### Main Branch Flow
```
Source Code → Setup → Build (Fastlane) → Test (Fastlane) → Results
```

### TestFlight Flow
```
Manual Trigger → Setup → Code Sign → Fastlane Beta → TestFlight + GitHub Release
                                           ↓
                                      Commit Back
```

### App Store Flow
```
Manual Trigger → Setup → Code Sign → Fastlane Release → App Store + Update Release
                                           ↓
                                      Commit Back
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
