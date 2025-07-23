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

# Update .version file
echo "Updating .version file..."
echo "$NEW_VERSION" > .version

# Update podspec version
echo "Updating MonetaiSDK.podspec..."
sed -i '' "s/spec.version      = \"[^\"]*\"/spec.version      = \"$NEW_VERSION\"/" MonetaiSDK.podspec

echo "Version updated successfully!"
echo "Don't forget to:"
echo "1. Commit the changes: git add .version MonetaiSDK.podspec"
echo "2. Commit: git commit -m \"Bump version to $NEW_VERSION\""
echo "3. Push to main: git push origin main"
echo "4. GitHub Actions will automatically create tag and deploy" 