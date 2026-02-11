#!/bin/bash

# Script to auto-increment CFBundleVersion (build number) in Info.plist
# This script increments the build number by 1 each time it runs

set -e

# Path to Info.plist
INFO_PLIST="${1:-Cove/Supporting Files/Info.plist}"

if [ ! -f "$INFO_PLIST" ]; then
    echo "Error: Info.plist not found at $INFO_PLIST"
    exit 1
fi

echo "📦 Incrementing build number in $INFO_PLIST"

# Get current build number
CURRENT_BUILD=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFO_PLIST")
echo "Current build number: $CURRENT_BUILD"

# Increment build number
NEW_BUILD=$((CURRENT_BUILD + 1))
echo "New build number: $NEW_BUILD"

# Update build number in Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD" "$INFO_PLIST"

# Get current marketing version for display
MARKETING_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFO_PLIST")

echo "✅ Build number updated successfully!"
echo "Marketing Version: $MARKETING_VERSION"
echo "Build Number: $NEW_BUILD"

# Output for GitHub Actions
if [ -n "$GITHUB_OUTPUT" ]; then
    echo "build_number=$NEW_BUILD" >> $GITHUB_OUTPUT
    echo "marketing_version=$MARKETING_VERSION" >> $GITHUB_OUTPUT
fi
