# Monetai iOS SDK - Swift Package Manager Example

This example demonstrates how to integrate Monetai iOS SDK using Swift Package Manager (SPM) with dynamic pricing via `getOffer`.

## Features Demonstrated

- SDK initialization using Swift Package Manager
- Dynamic pricing with `getOffer` API
- Event logging with parameters
- RevenueCat integration for subscription management
- Product display with discount pricing
- SwiftUI integration

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
2. Update with your own values:

   ```swift
   struct Constants {
       static let sdkKey = "your-sdk-key-here"
       static let userId = "example-user-id"
       static let useStoreKit2 = true
       static let promotionId = 6
       static let defaultProductId = "com.monetai.example.premium.annual"

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
let offer = try await monetaiSDK.getOffer(promotionId: promotionId)
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
    promotionId: promotionId
))
```

## Troubleshooting

### Common Issues

1. **"No such module 'MonetaiSDK'"**

   - Make sure the package dependencies are resolved
   - Clean build folder (`Shift + Cmd + K`)
   - Restart Xcode

2. **Build errors**

   - Check iOS deployment target (should be 13.0+)
   - Verify package dependencies are up to date

3. **SDK initialization fails**
   - Verify your SDK key is correct
   - Check internet connection
   - Review console logs for detailed error messages

### Getting Help

- Check the main [README](../../README.md) for general information
- Open an issue on [GitHub](https://github.com/hayanmind/monetai-ios/issues)

---

For more integration options, check out:

- [CocoaPods Example](../CocoaPodsExample/)
