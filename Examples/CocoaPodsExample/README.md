# Monetai iOS SDK - CocoaPods Example

This example demonstrates how to integrate Monetai iOS SDK using CocoaPods package manager.

## Features Demonstrated

- ✅ SDK initialization using CocoaPods
- ✅ Event logging with parameters
- ✅ User prediction and A/B testing
- ✅ Discount management
- ✅ Real-time discount status updates
- ✅ SwiftUI integration

## Prerequisites

- Xcode 15.0+
- iOS 13.0+
- CocoaPods installed on your system

## Setup

### 1. Install CocoaPods (if not already installed)

```bash
sudo gem install cocoapods
```

### 2. Navigate to the example directory

```bash
cd Examples/CocoaPodsExample
```

### 3. Install dependencies

```bash
pod install
```

### 4. Open the workspace

```bash
open CocoaPodsExample.xcworkspace
```

**⚠️ Important**: Always open the `.xcworkspace` file, not the `.xcodeproj` file when using CocoaPods.

## Configuration

1. Open `ContentView.swift`
2. Update the SDK key and user ID with your own values:
   ```swift
   private let sdkKey = "your-sdk-key"
   private let userId = "your-user-id"
   ```

## Running the Example

1. Select a target device or simulator
2. Press `Cmd + R` to build and run the app
3. The app will automatically initialize the Monetai SDK and display the status
4. Try different features:
   - Tap buttons to log events
   - Use "Predict User Behavior" to get AI predictions
   - Check discount status and availability

## Integration Method

This example uses CocoaPods to integrate Monetai SDK:

### Podfile

```ruby
platform :ios, '13.0'
use_frameworks!

target 'CocoaPodsExample' do
  pod 'MonetaiSDK', :path => '../../'
end
```

### Import

```swift
import MonetaiSDK
```

## Key Implementation Details

### SDK Initialization

```swift
let result = try await monetaiSDK.initialize(
    sdkKey: sdkKey,
    userId: userId,
    useStoreKit2: false // Using StoreKit 1 for CocoaPods example
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
let options = LogEventOptions.event("cocoapods_example_custom", params: [
    "integration_type": "cocoapods",
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

## Troubleshooting

### Common Issues

1. **"No such module 'MonetaiSDK'"**

   - Make sure you opened the `.xcworkspace` file
   - Run `pod install` again
   - Clean build folder (`Shift + Cmd + K`)

2. **Build errors**

   - Check iOS deployment target (should be 13.0+)
   - Try running `pod update`

3. **SDK initialization fails**
   - Verify your SDK key is correct
   - Check internet connection
   - Review console logs for detailed error messages

### Getting Help

- Check the main [README](../../README.md) for general information
- Review the [API Reference](../../README.md#api-reference)
- Open an issue on [GitHub](https://github.com/hayanmind/monetai-ios/issues)

---

For more integration options, check out:

- [Swift Package Manager Example](../SwiftPackageManagerExample/)
