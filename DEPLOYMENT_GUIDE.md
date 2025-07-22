# MonetAI iOS SDK - Deployment Guide

This guide explains how to deploy the MonetAI iOS SDK to make it available for public use across all three package managers.

## 📋 Prerequisites

Before deploying, ensure you have:

- [x] GitHub account with public repository
- [x] Valid `Package.swift` file
- [x] Valid `MonetaiSDK.podspec` file
- [x] Proper versioning strategy
- [x] Comprehensive README
- [x] LICENSE file

## 🚀 Deployment Steps

### 1. Swift Package Manager (Easiest)

Swift Package Manager requires **no registration** - just a public GitHub repository!

#### Steps:

```bash
# 1. Ensure your Package.swift is correct
# 2. Push code to GitHub
git add .
git commit -m "Release v1.0.0"
git push origin main

# 3. Create version tag
git tag 1.0.0
git push origin 1.0.0

# 4. Done! Users can now install via:
# https://github.com/your-username/monetai-ios.git
```

#### Users install with:

```swift
// In Xcode: File → Add Package Dependencies
https://github.com/your-username/monetai-ios.git

// Or in Package.swift
.package(url: "https://github.com/your-username/monetai-ios.git", from: "1.0.0")
```

#### Optional: Swift Package Index Registration

```bash
# Submit to Swift Package Index for better discoverability
# Visit: https://swiftpackageindex.com/add-a-package
# Simply provide your GitHub URL
```

### 2. CocoaPods (Requires Registration)

CocoaPods requires registration with **CocoaPods Trunk**.

#### Initial Setup (One-time):

```bash
# 1. Install CocoaPods (if not installed)
sudo gem install cocoapods

# 2. Register with CocoaPods Trunk
pod trunk register your-email@example.com 'Your Name' --description='MonetAI SDK'
# Check your email and click the verification link
```

#### Deployment Steps:

```bash
# 1. Validate your podspec
pod spec lint MonetaiSDK.podspec

# 2. If validation passes, push to GitHub with tag
git add .
git commit -m "Release v1.0.0"
git tag 1.0.0
git push origin main
git push origin 1.0.0

# 3. Push to CocoaPods Trunk
pod trunk push MonetaiSDK.podspec

# 4. Verify deployment
pod search MonetaiSDK
```

#### Users install with:

```ruby
# In Podfile
pod 'MonetaiSDK'

# Then run
pod install
```

### 3. Carthage (No Registration Needed)

Carthage requires **no registration** - users reference your GitHub URL directly.

#### Steps:

```bash
# 1. Ensure your repository has proper releases
git add .
git commit -m "Release v1.0.0"
git tag 1.0.0
git push origin main
git push origin 1.0.0

# 2. Create GitHub Release (recommended)
# Go to GitHub → Releases → Create new release
# Tag: 1.0.0
# Title: MonetAI iOS SDK v1.0.0
# Description: Initial release

# 3. Done! Users can now install
```

#### Users install with:

```
# In Cartfile
github "your-username/monetai-ios" ~> 1.0.0

# Then run
carthage update --platform iOS
```

#### Optional: Provide Binary Frameworks

```bash
# Build binary frameworks for faster user installation
carthage build --no-skip-current
carthage archive MonetaiSDK

# Upload MonetaiSDK.framework.zip to GitHub Releases
```

## 📝 Version Management

### Semantic Versioning

Follow [Semantic Versioning](https://semver.org/) (MAJOR.MINOR.PATCH):

- `1.0.0` - Initial release
- `1.0.1` - Bug fix
- `1.1.0` - New features (backward compatible)
- `2.0.0` - Breaking changes

### Release Process

```bash
# 1. Update version in files
# - Package.swift (if using version tags)
# - MonetaiSDK.podspec
# - README.md

# 2. Commit changes
git add .
git commit -m "Bump version to 1.1.0"

# 3. Create tag
git tag 1.1.0
git push origin main
git push origin 1.1.0

# 4. Update package managers
# SPM: Automatic (uses git tags)
# CocoaPods: pod trunk push MonetaiSDK.podspec
# Carthage: Automatic (users specify version in Cartfile)
```

## 🔒 Private Distribution Options

If you **don't want to open-source** your SDK:

### Option 1: Private CocoaPods Spec Repo

```ruby
# Create private spec repository
pod repo add private-specs https://github.com/your-company/private-specs.git

# Push to private repo
pod repo push private-specs MonetaiSDK.podspec

# Users add private source
# In Podfile
source 'https://github.com/your-company/private-specs.git'
pod 'MonetaiSDK'
```

### Option 2: Binary XCFramework Distribution

```bash
# Build XCFramework
xcodebuild archive \
  -scheme MonetaiSDK \
  -destination "generic/platform=iOS" \
  -archivePath MonetaiSDK-iOS.xcarchive \
  SKIP_INSTALL=NO

xcodebuild -create-xcframework \
  -archive MonetaiSDK-iOS.xcarchive -framework MonetaiSDK.framework \
  -output MonetaiSDK.xcframework

# Distribute via:
# - Direct download
# - Private CDN
# - Enterprise distribution
```

### Option 3: Private Package Repository

```swift
// Users add private repository
.package(url: "https://private-repo.company.com/monetai-ios.git", from: "1.0.0")
```

## 🧪 Pre-Release Testing

Before public deployment:

```bash
# 1. Test with local path
# SPM: .package(path: "../monetai-ios")
# CocoaPods: pod 'MonetaiSDK', :path => '../monetai-ios'
# Carthage: github "file://../../"

# 2. Test with development branch
# SPM: .package(url: "...", .branch("develop"))
# CocoaPods: pod 'MonetaiSDK', :git => '...', :branch => 'develop'
# Carthage: github "..." "develop"

# 3. Beta testing
git tag 1.0.0-beta.1
# Users can specify beta versions
```

## ✅ Deployment Checklist

Before deploying:

- [ ] **Code Quality**
  - [ ] All tests pass
  - [ ] Code is properly documented
  - [ ] No hardcoded credentials
- [ ] **Configuration Files**
  - [ ] Package.swift is valid
  - [ ] MonetaiSDK.podspec is valid (`pod spec lint`)
  - [ ] README.md is comprehensive
  - [ ] LICENSE file exists
- [ ] **Version Management**
  - [ ] Version numbers are consistent
  - [ ] CHANGELOG.md is updated
  - [ ] Git tags are created
- [ ] **Examples**

  - [ ] All example projects work
  - [ ] Integration guides are accurate
  - [ ] Sample API keys are removed

- [ ] Constants.swift files contain placeholder values (not real API keys)

- [ ] **Documentation**
  - [ ] API documentation is complete
  - [ ] Integration guides are clear
  - [ ] Troubleshooting section exists

## 📊 Monitoring Deployment

After deployment, monitor:

### CocoaPods Stats

```bash
pod stats MonetaiSDK
```

### GitHub Analytics

- Repository insights
- Release download counts
- Traffic analytics

### Swift Package Index

- Package popularity
- Build status
- Documentation coverage

## 🔄 Updating Releases

### Bug Fix Release (1.0.1)

```bash
# 1. Fix bugs, commit changes
git add .
git commit -m "Fix critical bug in prediction API"

# 2. Update version numbers
# 3. Create new tag
git tag 1.0.1
git push origin main
git push origin 1.0.1

# 4. Update CocoaPods
pod trunk push MonetaiSDK.podspec

# SPM and Carthage update automatically
```

### Major Release (2.0.0)

```bash
# 1. Update breaking changes
# 2. Update migration guide in README
# 3. Create pre-release for testing
git tag 2.0.0-beta.1
git push origin 2.0.0-beta.1

# 4. After testing, create final release
git tag 2.0.0
git push origin 2.0.0
pod trunk push MonetaiSDK.podspec
```

## 🆘 Troubleshooting Deployment

### Common CocoaPods Issues

```bash
# Validation errors
pod spec lint --verbose

# Network timeout
pod trunk push --verbose

# Dependencies conflict
pod repo update
```

### Common SPM Issues

```bash
# Package resolution issues
# Check Package.swift syntax
# Ensure all dependencies are accessible
# Verify version tags exist
```

### Common Carthage Issues

```bash
# Build failures
carthage build --no-skip-current --verbose

# Xcode compatibility
# Ensure project builds with command line tools
```

---

## 🎯 Recommended Approach

For **public SDK distribution**, we recommend this order:

1. **Start with Swift Package Manager** (easiest, no registration)
2. **Add CocoaPods support** (wider compatibility)
3. **Add Carthage support** (minimal effort, some users prefer it)

This approach maximizes compatibility while minimizing maintenance overhead.

Good luck with your deployment! 🚀
