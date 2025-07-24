# SDK Version Management

This document explains how to update the SDK version across different distribution platforms.

## Version Locations

The SDK version is managed in the following files:

1. **MonetaiSDK.podspec** - CocoaPods version
2. **Sources/MonetaiSDK/Utils/SDKVersion.swift** - SDK runtime version
3. **.version** - Version tracking file

## Automatic Version Update (Recommended)

Use the provided script to update all version locations at once:

```bash
# Update to version 1.1.0
./scripts/update_version.sh 1.1.0
```

This script automatically updates:

- `.version` file
- `MonetaiSDK.podspec` version
- `Sources/MonetaiSDK/Utils/SDKVersion.swift` hardcoded version

## Manual Version Update

If you prefer to update versions manually, follow these steps:

### 1. CocoaPods

Update `MonetaiSDK.podspec`:

```ruby
Pod::Spec.new do |spec|
  spec.name         = "MonetaiSDK"
  spec.version      = "1.1.0"  # Update this line
  # ...
end
```

### 2. SDKVersion.swift

Update the hardcoded version in `Sources/MonetaiSDK/Utils/SDKVersion.swift`:

```swift
public static func getVersion() -> String {
    return "1.1.0"  # Update this line
}
```

### 3. .version file

Update the `.version` file in the project root:

```bash
echo "1.1.0" > .version
```

## Version Format

- Use semantic versioning: `MAJOR.MINOR.PATCH`
- Examples: `1.0.0`, `1.1.0`, `2.0.0`
- Pre-release versions: `1.0.0-beta.5`, `1.0.0-rc.1`

## How SDK Version is Used

The SDK version is automatically sent to the server during SDK initialization:

1. **SDK Initialization**: `MonetaiSDK.shared.initialize()` is called
2. **Version Retrieval**: `SDKVersion.getVersion()` returns the hardcoded version
3. **API Request**: Version is included in the `/sdk-integrations` API call
4. **Database Storage**: Version is stored in the database for tracking
