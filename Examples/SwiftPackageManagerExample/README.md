# Monetai iOS SDK - Swift Package Manager Example

This example demonstrates how to integrate Monetai iOS SDK using Swift Package Manager (SPM).

## Features Demonstrated

- ✅ SDK initialization using Swift Package Manager
- ✅ Event logging with parameters
- ✅ User prediction and A/B testing
- ✅ Discount management
- ✅ Real-time discount status updates
- ✅ SwiftUI integration
- ✅ RevenueCat integration for subscription management

## Prerequisites

- Xcode 15.0+
- iOS 13.0+
- Swift Package Manager (included with Xcode)

## Setup

### 1. Navigate to the example directory

```bash
cd Examples/SwiftPackageManagerExample
```

### 2. Open the project

```bash
open SwiftPackageManagerExample.xcodeproj
```

### 3. Configure dependencies

The project uses Swift Package Manager for dependency management. Dependencies are automatically resolved when you open the project in Xcode.

## Configuration

1. Open `Constants.swift`
2. Update the SDK key and user ID with your own values:
   ```swift
   struct Constants {
       // MARK: - MonetaiSDK Configuration
       static let sdkKey = "your-sdk-key-here"
       static let userId = "example-user-id"
       static let useStoreKit2 = true

       // MARK: - RevenueCat Configuration
       static let revenueCatAPIKey = "your-revenuecat-api-key-here"
   }
   ```

## Running the Example

1. Select a target device or simulator
2. Press `Cmd + R` to build and run the app
3. The app will automatically initialize the Monetai SDK and display the status
4. Try different features:
   - Tap buttons to log events
   - Use "Predict User Behavior" to get AI predictions
   - Check discount status and availability
   - Test RevenueCat subscription flows

## Integration Method

This example uses Swift Package Manager to integrate Monetai SDK:

### Package Dependencies

The project includes the following dependencies:

- MonetaiSDK (local package)
- RevenueCat (for subscription management)

### Import

```swift
import MonetaiSDK
import RevenueCat
```

## Key Implementation Details

### SDK Initialization

```swift
let result = try await monetaiSDK.initialize(
    sdkKey: sdkKey,
    userId: userId,
    useStoreKit2: true // Using StoreKit 2 for SPM example
)
```

### Event Logging

```swift
// Simple event
await monetaiSDK.logEvent(eventName: "app_opened")

// Event with parameters
await monetaiSDK.logEvent(eventName: "product_viewed", params: [
    "product_id": "premium_subscription"
])

// Using LogEventOptions
let options = LogEventOptions.event("spm_example_custom", params: [
    "integration_type": "swift_package_manager",
    "timestamp": Date().timeIntervalSince1970
])
await monetaiSDK.logEvent(options)
```

### User Prediction

```swift
do {
    let result = try await monetaiSDK.predict()
    // Handle prediction result
} catch {
    // Handle error
}
```

### Discount Management

```swift
// Check current discount
let discount = try await monetaiSDK.getCurrentDiscount()

// Check if user has active discount
let hasActiveDiscount = try await monetaiSDK.hasActiveDiscount()

// Set up discount change listener
monetaiSDK.onDiscountInfoChange = { discount in
    // Handle discount changes
}
```

### RevenueCat Integration

This example also demonstrates RevenueCat integration for subscription management:

```swift
// Initialize RevenueCat
Purchases.configure(withAPIKey: Constants.revenueCatAPIKey)

// Get available packages
let offerings = try await Purchases.shared.offerings()
let packages = offerings.current?.availablePackages ?? []

// Purchase package
let customerInfo = try await Purchases.shared.purchase(package: package)
```

## Troubleshooting

### Common Issues

1. **"No such module 'MonetaiSDK'"**

   - Make sure the package dependencies are resolved
   - Clean build folder (`Shift + Cmd + K`)
   - Restart Xcode

2. **Build errors**

   - Check iOS deployment target (should be 13.0+)
   - Ensure Swift version is 5.0+
   - Verify package dependencies are up to date

3. **SDK initialization fails**
   - Verify your SDK key is correct
   - Check internet connection
   - Review console logs for detailed error messages

### Getting Help

- Check the main [README](../../README.md) for general information
- Review the [API Reference](../../README.md#api-reference)
- Open an issue on [GitHub](https://github.com/hayanmind/monetai-ios/issues)

## Next Steps

- Implement user prediction in your purchase flow
- Set up event logging for key user actions
- Configure discount UI based on prediction results
- Test with different user scenarios
- Integrate with your own RevenueCat setup

---

For more integration options, check out:

- [CocoaPods Example](../CocoaPodsExample/)
- [Simple App Example](../SimpleApp/)
