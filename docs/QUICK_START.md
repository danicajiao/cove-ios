# Quick Start Guide

Get the Cove iOS app building and running on your local machine.

## Prerequisites

- **Xcode 16+** (required for iOS 18 SDK)
- **CocoaPods** — `sudo gem install cocoapods`
- **Ruby + Bundler** — for Fastlane (optional, only needed for CI/CD lanes)

## Steps

### 1. Clone the repository

```bash
git clone https://github.com/danicajiao/cove-ios.git
cd cove-ios
```

### 2. Install dependencies

```bash
pod install
```

Open the project using the **`.xcworkspace`** file, not `.xcodeproj`:

```bash
open Cove.xcworkspace
```

### 3. Add `GoogleService-Info.plist`

The app requires a `GoogleService-Info.plist` file to connect to Firebase. This file contains API keys and project credentials and is **not committed to the repository**.

**Access is restricted to approved developers.** Request access by opening an issue or contacting the project owner.

Once you have the file, place it at:

```
Cove/Supporting Files/GoogleService-Info.plist
```

### 4. Build and run

Select a simulator or connected device in Xcode and press **⌘R**.

## Notes

- **Bundle ID:** `com.danicajiao.cove`
- **Minimum deployment target:** iOS 18.0
- Google Sign-In and Facebook Login are configured via `Info.plist` — no additional setup required beyond the `GoogleService-Info.plist`
- For CI/CD setup, see [CI/CD Workflows Documentation](CI_CD_WORKFLOWS.md)

## Troubleshooting

### `pod install` fails
→ Ensure CocoaPods is up to date: `sudo gem install cocoapods`

### Build fails with Firebase errors
→ Verify `GoogleService-Info.plist` is present at the correct path and added to the Xcode target

### Simulator shows blank screen or crashes on launch
→ Check that `GoogleService-Info.plist` is valid and matches the `cove-6a685` Firebase project

---

**Last Updated**: March 2026
