# MonetAI iOS SDK Examples

This directory contains example projects demonstrating how to integrate MonetAI iOS SDK using different package managers and integration methods.

## Available Examples

### 📦 Swift Package Manager Example

**Location**: `SwiftPackageManagerExample/`

- **Recommended** integration method
- Native Xcode support
- Easy dependency management
- Complete SwiftUI example with RevenueCat integration

[📖 View Swift Package Manager Example →](SwiftPackageManagerExample/)

### 🍫 CocoaPods Example

**Location**: `CocoaPodsExample/`

- Traditional iOS dependency manager
- Wide compatibility
- Easy setup with Podfile
- Demonstrates StoreKit 1 integration

[📖 View CocoaPods Example →](CocoaPodsExample/)

## Quick Comparison

| Feature                   | Swift Package Manager | CocoaPods |
| ------------------------- | --------------------- | --------- |
| **Ease of Setup**         | ⭐⭐⭐⭐⭐            | ⭐⭐⭐⭐  |
| **Xcode Integration**     | Native                | Workspace |
| **Build Time**            | Fast                  | Medium    |
| **Dependency Resolution** | Automatic             | Automatic |
| **Community Support**     | Growing               | Mature    |

## Common Features Demonstrated

All examples include:

- ✅ **SDK Initialization**: Proper setup and configuration
- ✅ **Event Logging**: User behavior tracking with parameters
- ✅ **User Prediction**: AI-powered purchase likelihood prediction
- ✅ **Discount Management**: Automatic discount creation and status checking
- ✅ **A/B Testing**: Test group assignment and management
- ✅ **Error Handling**: Comprehensive error management
- ✅ **SwiftUI Integration**: Modern iOS development patterns
- ✅ **Real-time Updates**: Live discount status updates

## Getting Started

### 1. Choose Your Integration Method

- **New projects**: Use Swift Package Manager
- **Existing CocoaPods projects**: Use CocoaPods example

### 2. Clone and Setup

```bash
# Clone the repository
git clone https://github.com/hayanmind/monetai-ios.git
cd monetai-ios/Examples

# Choose your example and follow its README
cd SwiftPackageManagerExample/  # For Swift Package Manager
cd CocoaPodsExample/     # For CocoaPods
```

### 3. Configuration

Each example includes a `Constants.swift` file for configuration. Update the following values:

```swift
// In Constants.swift
struct Constants {
    static let sdkKey = "your-sdk-key-here"
    static let userId = "your-unique-user-id"
    static let revenueCatAPIKey = "your-revenuecat-api-key-here"
}
```

**Note**: The `Constants.swift` file contains placeholder values. Update them with your actual API keys before running the examples.

### 4. Run and Explore

1. Open the project in Xcode
2. Build and run on simulator or device
3. Explore different features and integration patterns
4. Review the code for implementation details

## Integration Differences

### SDK Initialization

All examples use the same core API with slight variations:

```swift
// Common initialization pattern
let result = try await MonetaiSDK.shared.initialize(
    sdkKey: "your-sdk-key",
    userId: "user-id",
    useStoreKit2: true // Varies by example
)
```

### Package Manager Specific Setup

#### Swift Package Manager

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/hayanmind/monetai-ios.git", from: "1.0.0")
]
```

#### CocoaPods

```ruby
# Podfile
pod 'MonetaiSDK'
```

## Prerequisites

All examples require:

- **Xcode**: 15.0 or later
- **iOS**: 13.0 or later
- **Swift**: 5.0 or later
- **Valid SDK Key**: Obtain from MonetAI Dashboard

## Package Manager Installation

### Swift Package Manager

Already included in Xcode - no additional installation needed.

### CocoaPods

```bash
sudo gem install cocoapods
```

## Key SDK Features Demonstrated

### 🤖 AI-Powered Predictions

```swift
let result = try await MonetaiSDK.shared.predict()
switch result.prediction {
case .purchaser: // User likely to purchase
case .nonPurchaser: // Show discount to convert
}
```

### 📊 Event Tracking

```swift
// Simple event
await MonetaiSDK.shared.logEvent(eventName: "app_opened")

// Event with parameters
await MonetaiSDK.shared.logEvent(
    eventName: "product_viewed",
    params: ["product_id": "premium_plan"]
)
```

### 💰 Discount Management

```swift
// Check for active discounts
let discount = try await MonetaiSDK.shared.getCurrentDiscount()
let hasActiveDiscount = try await MonetaiSDK.shared.hasActiveDiscount()

// Listen for discount changes
MonetaiSDK.shared.onDiscountInfoChange = { discount in
    // Update UI accordingly
}
```

## Next Steps

1. **Choose** your preferred integration method
2. **Follow** the specific example's README
3. **Customize** the implementation for your app
4. **Test** with different user scenarios
5. **Deploy** to production with your SDK key

## Getting Help

- 📖 [Main SDK Documentation](../README.md)
- 🐛 [GitHub Issues](https://github.com/hayanmind/monetai-ios/issues)
- 📧 [Email Support](mailto:support@monetai.io)
- 🌐 [Online Documentation](https://docs.monetai.io)

---

**Happy coding!** 🚀
