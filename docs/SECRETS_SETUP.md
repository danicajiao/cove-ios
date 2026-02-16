# CI/CD Secrets Setup Guide

This guide walks you through setting up all the required secrets for the iOS CI/CD workflows.

## Overview

The CI/CD workflows require several secrets to be configured in GitHub repository settings. These secrets handle:
- Code signing (certificates and provisioning profiles)
- App Store Connect authentication
- Git operations

## Prerequisites

Before starting, ensure you have:
- An Apple Developer account
- Access to App Store Connect
- A Mac with Xcode installed
- Your distribution certificate and provisioning profile

## Step 1: Configure Code Signing

### 1.1 Export Your Distribution Certificate

1. Open **Keychain Access** on your Mac
2. In the "Certificates" category, find your **Apple Distribution** certificate
3. Right-click the certificate → **Export "Apple Distribution: ..."**
4. Save as a `.p12` file with a strong password
5. Remember this password for later

### 1.2 Encode Certificate to Base64

```bash
base64 -i YourCertificate.p12 -o certificate.txt
```

Open `certificateb64.txt` and copy the contents. This is your `CERTIFICATES_P12` secret value.

### 1.3 Export Your Provisioning Profile

1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/profiles/list)
2. Download your **App Store** provisioning profile for your app
3. Save it as a `.mobileprovision` file

### 1.4 Encode Provisioning Profile to Base64

```bash
base64 -i YourProfile.mobileprovision -o profile.txt
```

Open `profileb64.txt` and copy the contents. This is your `PROVISIONING_PROFILE` secret value.

### 1.5 Get Provisioning Profile Name

```bash
# Extract the profile name
security cms -D -i YourProfile.mobileprovision | grep -A 1 "<key>Name</key>" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/'
```

This outputs the profile name, which is your `PROVISIONING_PROFILE_SPECIFIER` value.

### 1.6 Get Your Apple Team ID

1. Go to [Apple Developer Membership](https://developer.apple.com/account/#/membership/)
2. Find your **Team ID** (e.g., `A1B2C3D4E5`)
3. This is your `APPLE_TEAM_ID` value

**Note:** This secret is not currently used by the workflows, but is included for completeness and potential future use.

## Step 2: Create App Store Connect API Key

### 2.1 Generate API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to **Users and Access** → **Keys** (under Integrations)
3. Click the **+** button to create a new key
4. Enter a name (e.g., "GitHub Actions CI/CD")
5. Select **App Manager** access
6. Click **Generate**
7. Download the `.p8` file immediately (you can't download it again!)

### 2.2 Get Key ID and Issuer ID

After generating the key:
- **Key ID**: Displayed in the Key column (e.g., `A1B2C3D4E5`)
- **Issuer ID**: Click "Copy" next to Issuer ID at the top of the page

### 2.3 Encode API Key to Base64

```bash
base64 -i AuthKey_XXXXXXXXXX.p8 -o apikey.txt
```

Open `apikey.txt` and copy the contents. This is your `APP_STORE_CONNECT_API_KEY` secret value.

## Step 3: Create GitHub Personal Access Token

### 3.1 Generate PAT

1. Go to [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens)
2. Click **Generate new token** → **Generate new token (fine-grained)**
3. Give it a descriptive name (e.g., "Cove iOS CI/CD")
4. Set expiration (recommended: 90 days or custom)
5. Select scopes:
   - ✅ `repo` (Full control of private repositories)
6. Click **Generate token**
7. **Copy the token immediately** (you won't see it again!)

This token is your `GH_PAT` secret value.

## Step 4: Add Secrets to GitHub Repository

**Total: 9 secrets (8 required, 1 unused)**

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** for each of the following:

### Code Signing Secrets

| Secret Name | Value Source | Example |
|------------|--------------|---------|
| `CERTIFICATES_P12` | Base64 from Step 1.2 | `MIIKpAIBAzCCCm...` |
| `CERTIFICATES_PASSWORD` | Password from Step 1.1 | `YourSecurePassword123` |
| `PROVISIONING_PROFILE` | Base64 from Step 1.4 | `MIINUQYJKoZI...` |
| `PROVISIONING_PROFILE_SPECIFIER` | Profile name from Step 1.5 | `Cove App Store Profile` |
| `APPLE_TEAM_ID` | Team ID from Step 1.6 | `A1B2C3D4E5` *(not currently used)* |

### App Store Connect Secrets

| Secret Name | Value Source | Example |
|------------|--------------|---------|
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID from Step 2.2 | `A1B2C3D4E5` |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID from Step 2.2 | `12345678-1234-...` |
| `APP_STORE_CONNECT_API_KEY` | Base64 from Step 2.3 | `LS0tLS1CRUdJT...` |

### GitHub Secrets

| Secret Name | Value Source | Example |
|------------|--------------|---------|
| `GH_PAT` | Token from Step 3.1 | `ghp_xxxxxxxxxxxx` |

## Step 5: Verify Setup

After adding all secrets:

1. Go to **Actions** tab in your repository
2. If there are any workflow runs, check if they succeed
3. If not, create a test PR to trigger the PR checks workflow

## Troubleshooting

### Certificate Issues
- **Error: "No certificate found"**: Ensure your `.p12` file contains both the certificate and private key
- **Error: "Incorrect password"**: Double-check `CERTIFICATES_PASSWORD` matches the password used when exporting

### Provisioning Profile Issues
- **Error: "Profile doesn't match"**: Verify `PROVISIONING_PROFILE_SPECIFIER` matches the profile name exactly
- **Error: "Bundle ID mismatch"**: Ensure your provisioning profile is for `com.danicajiao.cove`

### App Store Connect Issues
- **Error: "Invalid credentials"**: Verify all three API key values are correct
- **Error: "Insufficient permissions"**: Ensure the API key has App Manager role

### GitHub Issues
- **Error: "Permission denied"**: Ensure `GH_PAT` has `repo` scope and hasn't expired
- **Error: "Can't push to repository"**: Check that the PAT belongs to a user with write access

## Security Best Practices

1. ✅ **Never** commit secrets to your repository
2. ✅ **Rotate** secrets regularly (every 90 days recommended)
3. ✅ **Use** different certificates for development and production
4. ✅ **Limit** API key permissions to only what's needed
5. ✅ **Monitor** secret usage in Actions logs
6. ✅ **Revoke** old secrets when rotating to new ones

## Updating Secrets

When you need to update a secret (e.g., expired certificate):

1. Generate the new certificate/key following the steps above
2. Go to **Settings** → **Secrets and variables** → **Actions**
3. Click on the secret name
4. Click **Update secret**
5. Paste the new value
6. Click **Update secret**

## Support

For issues with:
- **Code signing**: Contact Apple Developer Support
- **App Store Connect**: Check [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- **GitHub Actions**: See [GitHub Actions Documentation](https://docs.github.com/en/actions)
- **This project**: Open an issue in the repository

## Next Steps

After completing this setup:
1. Review the [CI/CD Workflows Documentation](CI_CD_WORKFLOWS.md)
2. Test the workflows by creating a test PR
3. Monitor the first TestFlight deployment
4. Plan your first App Store release

---

**Last Updated**: February 2026
