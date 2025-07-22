# SDK Version Management

This document explains how to update the SDK version across different distribution platforms.

## Version Locations

The SDK version is managed in the following files:

1. **MonetaiSDK.podspec** - CocoaPods version
2. **Sources/MonetaiSDK/Utils/SDKVersion.swift** - Fallback version
3. **Git tags** - Swift Package Manager version

## Automatic Version Update

Use the provided script to update all version locations at once:

```bash
# Update to version 1.1.0
./scripts/update_version.sh 1.1.0

# Update to version 1.1.0 with build number 2
./scripts/update_version.sh 1.1.0 2
```

## Manual Version Update

If you prefer to update versions manually, follow these steps:

### 1. Swift Package Manager

Swift Package Manager uses Git tags for versioning. No changes needed in `Package.swift`.

To create a new version:

```bash
git tag v1.1.0
git push origin v1.1.0
```

### 2. CocoaPods

Update `MonetaiSDK.podspec`:

```ruby
Pod::Spec.new do |spec|
  spec.name         = "MonetaiSDK"
  spec.version      = "1.1.0"  # Update this line
  # ...
end
```

### 3. SDKVersion.swift

Update the fallback version in `Sources/MonetaiSDK/Utils/SDKVersion.swift`:

```swift
return "1.1.0"  // Update version fallback
```

## Release Process

After updating the version:

1. **Commit changes**:

   ```bash
   git add .
   git commit -m "Bump version to 1.1.0"
   ```

2. **Create and push tag**:

   ```bash
   git tag v1.1.0
   git push origin v1.1.0
   ```

3. **Publish to CocoaPods** (if applicable):
   ```bash
   pod trunk push MonetaiSDK.podspec
   ```

## Version Format

- Use semantic versioning: `MAJOR.MINOR.PATCH`
- Examples: `1.0.0`, `1.1.0`, `2.0.0`
- Build numbers are optional and can be used for internal builds

## Platform-Specific Notes

### Swift Package Manager

- Version is managed via compile-time constants in `Package.swift`
- Users specify version in their `Package.swift` dependencies
- No separate publishing process required

### CocoaPods

- Version is managed via compile-time constants in `podspec`
- Version must match git tag
- Requires publishing to CocoaPods trunk
- Users specify version in their `Podfile`
