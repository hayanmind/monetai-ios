# SimpleAppObjectiveC

A sample Objective-C app demonstrating MonetaiSDK integration.

## Overview

This project showcases the core features of MonetaiSDK implemented in Objective-C. It provides the same functionality as the Swift-based SimpleApp example, making it perfect for developers working with Objective-C codebases.

## Key Features

- **SDK Initialization**: Automatic SDK setup on app launch
- **Purchase Prediction**: AI-powered user purchase probability prediction
- **Event Logging**: Send user behavior events to the server
- **Discount Banner**: Display active discount banners
- **Real-time Status Monitoring**: Live SDK initialization status tracking

## Project Structure

```
SimpleAppObjectiveC/
├── SimpleAppObjectiveC/
│   ├── AppDelegate.h/m          # App delegate and SDK initialization
│   ├── ViewController.h/m       # Main view controller
│   ├── DiscountBannerView.h/m   # Discount banner view
│   ├── Constants.h/m            # Configuration constants
│   ├── SceneDelegate.h/m        # Scene delegate
│   └── main.m                   # App entry point
├── Podfile                      # CocoaPods dependency configuration
└── README.md                    # Project documentation
```

## Setup

### 1. SDK Key Configuration

Update the SDK keys in `Constants.m` with your actual credentials:

```objc
NSString * const kSDKKey = @"your-actual-sdk-key-here";
NSString * const kUserId = @"your-user-id";
```

### 2. Install Dependencies

```bash
cd Examples/SimpleAppObjectiveC
pod install
```

### 3. Run the Project

Open `SimpleAppObjectiveC.xcworkspace` in Xcode and run the project.

## Usage

### SDK Initialization

The SDK is automatically initialized when the app starts:

```objc
// Automatic initialization in AppDelegate.m
InitializationResult *result = [[MonetaiSDK shared] initializeWithSdkKey:kSDKKey
                                                                  userId:kUserId
                                                           useStoreKit2:kUseStoreKit2
                                                                  error:nil];
```

### Purchase Prediction

Tap the "Predict Purchase" button to run purchase prediction:

```objc
PredictionResult *result = [[MonetaiSDK shared] predictAndReturnError:nil];
```

### Event Logging

Tap the "Log Event" button to log test events:

```objc
NSDictionary *params = @{
    @"button": @"test_button",
    @"screen": @"main"
};
[[MonetaiSDK shared] logEventWithEventName:@"button_click" params:params];
```

### Discount Banner

Discount banners are automatically displayed when active discounts are available:

```objc
// Discount information change callback
[MonetaiSDK shared].onDiscountInfoChange = ^(AppUserDiscount * _Nullable discountInfo) {
    // Handle discount banner display/hide
};
```

## UI Components

- **Title**: "MonetaiSDK Demo"
- **Status Display**: Real-time SDK initialization status
- **Prediction Button**: Execute purchase prediction functionality
- **Event Logging Button**: Log test events
- **Discount Status**: Display current discount information
- **Result Display**: Show operation results as text
- **Discount Banner**: Display at bottom when active discounts exist

## Notification System

SDK initialization status is delivered through notifications:

```objc
// Initialization success
[[NSNotificationCenter defaultCenter] postNotificationName:kMonetaiSDKInitializedNotification object:nil];

// Initialization failure
[[NSNotificationCenter defaultCenter] postNotificationName:kMonetaiSDKInitializationFailedNotification object:error];
```

## Important Notes

1. **SDK Key Security**: Do not include actual SDK keys in version control
2. **Error Handling**: Implement proper handling for network errors and SDK initialization failures
3. **Memory Management**: Use weak references appropriately to prevent memory leaks in Objective-C

## Troubleshooting

### Build Errors

1. Ensure `pod install` has been executed
2. Verify you're using the `.xcworkspace` file
3. Check that MonetaiSDK framework is properly linked

### Runtime Errors

1. Verify SDK key is correct
2. Check network connectivity
3. Review console logs for error messages

## Requirements

- **Xcode**: 15.0 or later
- **iOS**: 13.0 or later
- **CocoaPods**: For dependency management
- **Valid SDK Key**: Obtain from Monetai Dashboard

## Getting Help

- 📖 [Main SDK Documentation](../../README.md)
- 🐛 [GitHub Issues](https://github.com/hayanmind/monetai-ios/issues)
- 📧 [Email Support](mailto:support@monetai.io)
- 🌐 [Online Documentation](https://docs.monetai.io)

## License

This project is a sample code for MonetaiSDK.
