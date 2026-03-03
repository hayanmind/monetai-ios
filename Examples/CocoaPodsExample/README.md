# Monetai iOS SDK - CocoaPods Example

This example demonstrates how to integrate Monetai iOS SDK using CocoaPods with dynamic pricing via `getOffer` and RevenueCat for subscription management.

## Features Demonstrated

- SDK initialization using CocoaPods
- Dynamic pricing with `getOffer` API
- Event logging with parameters
- RevenueCat integration for subscription management
- Product display with discount pricing
- SwiftUI integration

## Prerequisites

- Xcode 15.0+
- iOS 16.0+
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

**Important**: Always open the `.xcworkspace` file, not the `.xcodeproj` file when using CocoaPods.

## Configuration

1. Open `Constants.swift`
2. Update with your own values:

   ```swift
   struct Constants {
       static let sdkKey = "your-sdk-key-here"
       static let userId = "example-user-id"
       static let useStoreKit2 = true
       static let placement = "your-placement-here"
       static let defaultProductId = "your-default-product-id-here"

       static let revenueCatAPIKey = "your-revenuecat-api-key-here"
   }
   ```

## Running the Example

1. Select a target device or simulator
2. Press `Cmd + R` to build and run the app
3. The app will automatically initialize the Monetai SDK and display the status
4. Try different features:
   - Tap "Get Offer" to fetch dynamic pricing offers
   - View discount rates applied to products
   - Test RevenueCat subscription flows

## Integration Method

This example uses CocoaPods to integrate Monetai SDK:

### Podfile

```ruby
platform :ios, '16.0'
use_frameworks!

target 'CocoaPodsExample' do
  pod 'MonetaiSDK', :path => '../../'
  pod 'RevenueCat'
end
```

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
    useStoreKit2: true
)
```

### Get Offer (Dynamic Pricing)

```swift
let offer = try await monetaiSDK.getOffer(placement: placement)
// offer.agentName - the matched agent
// offer.products  - array of OfferProduct with sku, name, discountRate
```

### Event Logging

```swift
await monetaiSDK.logEvent(eventName: "app_launched", params: [
    "version": "1.0.0"
])
```

### Log View Product Item

```swift
await monetaiSDK.logViewProductItem(ViewProductItemParams(
    productId: product.sku,
    price: discountedPrice,
    regularPrice: regularPrice,
    currencyCode: "USD",
    placement: placement
))
```

## Troubleshooting

### Common Issues

1. **"No such module 'MonetaiSDK'"**

   - Make sure you opened the `.xcworkspace` file
   - Run `pod install` again
   - Clean build folder (`Shift + Cmd + K`)

2. **Build errors**

   - Check iOS deployment target (should be 16.0+)
   - Try running `pod update`

3. **SDK initialization fails**
   - Verify your SDK key is correct
   - Check internet connection
   - Review console logs for detailed error messages

### Getting Help

- Check the main [README](../../README.md) for general information
- Open an issue on [GitHub](https://github.com/hayanmind/monetai-ios/issues)

---

For more integration options, check out:

- [Swift Package Manager Example](../SwiftPackageManagerExample/)
- [Objective-C Example](../ObjectiveCExample/)
