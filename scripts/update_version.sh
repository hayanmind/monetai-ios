#!/bin/bash

# Script to update SDK version across all platforms
# Usage: ./scripts/update_version.sh <new_version>

if [ $# -eq 0 ]; then
    echo "Usage: $0 <new_version>"
    echo "Example: $0 1.1.0"
    exit 1
fi

NEW_VERSION=$1

echo "Updating SDK version to $NEW_VERSION..."

# Update podspec version
echo "Updating MonetaiSDK.podspec..."
sed -i '' "s/spec.version      = \"[^\"]*\"/spec.version      = \"$NEW_VERSION\"/" MonetaiSDK.podspec

echo "Note: For Swift Package Manager, create git tag: git tag v$NEW_VERSION"

echo "Version updated successfully!"
echo "Don't forget to:"
echo "1. Commit the changes"
echo "2. Create a git tag: git tag v$NEW_VERSION"
echo "3. Push the tag: git push origin v$NEW_VERSION" 