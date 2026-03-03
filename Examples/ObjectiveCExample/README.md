# Monetai iOS SDK - Objective-C Example

This example demonstrates how to integrate Monetai iOS SDK in an Objective-C project with dynamic pricing via `getOffer` and RevenueCat for subscription management.

## Features Demonstrated

- SDK initialization with completion handler pattern (Obj-C compatible)
- Dynamic pricing with `getOffer` API
- Event logging with parameters
- RevenueCat integration for product loading and purchases
- Product display with discount pricing
- UIKit integration (programmatic layout)

## Prerequisites

- Xcode 15.0+
- iOS 16.0+
- CocoaPods

## Setup

### 1. Install Dependencies

```bash
cd Examples/ObjectiveCExample
pod install
```

### 2. Configure Constants

Open `Constants.m` and update with your credentials:

```objc
NSString * const kSDKKey = @"your-sdk-key-here";
NSString * const kUserId = @"example-user-id";
NSString * const kRevenueCatAPIKey = @"your-revenuecat-api-key-here";
```

### 3. Run the Project

Open `ObjectiveCExample.xcworkspace` in Xcode and run.

## Key Implementation Details

### SDK Initialization (Completion Handler)

```objc
[[MonetaiSDK shared] initializeWithSdkKey:kSDKKey
                                   userId:kUserId
                             useStoreKit2:kUseStoreKit2
                               completion:^(InitializeResult *result, NSError *error) {
    // Handle result
}];
```

### Get Offer (Dynamic Pricing)

```objc
[[MonetaiSDK shared] getOfferWithPlacement:kPlacement
                                completion:^(Offer *offer, NSError *error) {
    // offer.agentName - the matched agent
    // offer.products  - array of OfferProduct with sku, name, discountRate
}];
```

### Event Logging

```objc
[[MonetaiSDK shared] logEventWithEventName:@"button_click" params:@{
    @"button": @"test_button",
    @"screen": @"main"
}];
```

### Log View Product Item

```objc
ViewProductItemParams *params = [[ViewProductItemParams alloc]
    initWithProductId:product.sku
                price:discountedPrice
         regularPrice:regularPrice
         currencyCode:@"USD"
            placement:kPlacement
                month:nil];
[[MonetaiSDK shared] logViewProductItemWithParams:params];
```

## Troubleshooting

### Common Issues

1. **"No such module 'MonetaiSDK'"** - Run `pod install` and open `.xcworkspace`
2. **Build errors** - Check iOS deployment target (should be 16.0+)
3. **SDK initialization fails** - Verify SDK key, check network connection

### Getting Help

- Check the main [README](../../README.md) for general information
- Open an issue on [GitHub](https://github.com/hayanmind/monetai-ios/issues)

---

For more integration options, check out:

- [CocoaPods Example (Swift)](../CocoaPodsExample/)
- [Swift Package Manager Example](../SwiftPackageManagerExample/)
