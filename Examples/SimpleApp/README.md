# Simple App Example

A minimal UIKit-based example demonstrating the core features of Monetai iOS SDK.

## Overview

SimpleApp is designed to be the most straightforward way to understand and integrate Monetai SDK into your iOS application. It uses UIKit and Swift Package Manager with remote package dependencies, making it perfect for developers who want to see the SDK in action with minimal setup.

## Features Demonstrated

- ✅ **SDK Initialization**: Basic setup in AppDelegate
- ✅ **User Prediction**: AI-powered purchase likelihood prediction
- ✅ **Event Logging**: Simple event tracking with parameters
- ✅ **Discount Management**: Check and display discount status
- ✅ **Real-time Updates**: Live discount status monitoring
- ✅ **Error Handling**: Comprehensive error management
- ✅ **UIKit Integration**: Traditional iOS development patterns

## Project Structure

```
SimpleApp/
├── SimpleApp.xcodeproj/          # Xcode project file
└── SimpleApp/
    ├── AppDelegate.swift         # SDK initialization
    ├── SceneDelegate.swift       # Scene management
    ├── ViewController.swift      # Main UI and SDK usage
    ├── DiscountBannerView.swift  # Custom discount display
    ├── Constants.swift           # Configuration constants
    ├── Info.plist               # App configuration
    └── Assets.xcassets/         # App assets
```

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/hayanmind/monetai-ios.git
cd monetai-ios/Examples/SimpleApp
```

### 2. Open the Project

The project uses Swift Package Manager with remote package dependencies. Dependencies are automatically resolved when you open the project in Xcode.

```bash
open SimpleApp.xcodeproj
```

### 3. Configure SDK Keys

Open `Constants.swift` and update the configuration:

```swift
struct Constants {
    // Replace with your actual API keys
    static let sdkKey = "your-sdk-key-here"
    static let userId = "your-unique-user-id"
    static let useStoreKit2 = true // Recommended
}
```

**⚠️ Important**: Never commit real API keys to version control. Use placeholder values for development.

### 4. Build and Run

1. Select your target device or simulator
2. Build and run the project (⌘+R)

## Key Implementation Details

### SDK Initialization

The SDK is initialized in `AppDelegate.swift`:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    Task {
        do {
            let result = try await MonetaiSDK.shared.initialize(
                sdkKey: Constants.sdkKey,
                userId: Constants.userId,
                useStoreKit2: Constants.useStoreKit2
            )
            print("Monetai SDK initialization completed:", result)
        } catch {
            print("Monetai SDK initialization failed:", error)
        }
    }

    return true
}
```

### User Prediction

The app demonstrates AI-powered purchase prediction:

```swift
@objc private func predictButtonTapped() {
    Task {
        do {
            let result = try await MonetaiSDK.shared.predict()
            updateResultLabel("Prediction: \(result.prediction)")
        } catch {
            updateResultLabel("Prediction failed: \(error.localizedDescription)")
        }
    }
}
```

### Event Logging

Simple event tracking with parameters:

```swift
@objc private func logEventButtonTapped() {
    Task {
        await MonetaiSDK.shared.logEvent(
            eventName: "button_tapped",
            params: ["button": "log_event", "timestamp": "\(Date())"]
        )
        updateResultLabel("Event logged successfully")
    }
}
```

### Discount Management

Real-time discount status monitoring:

```swift
private func setupDiscountMonitoring() {
    // Check current discount status
    Task {
        let hasDiscount = try await MonetaiSDK.shared.hasActiveDiscount()
        updateDiscountStatus(hasDiscount)
    }

    // Listen for discount changes
    MonetaiSDK.shared.onDiscountInfoChange = { [weak self] discount in
        DispatchQueue.main.async {
            self?.handleDiscountChange(discount)
        }
    }
}
```

## UI Components

### Main View Controller

The main interface includes:

- **Status Label**: Shows SDK initialization status
- **Predict Button**: Triggers AI purchase prediction
- **Log Event Button**: Demonstrates event tracking
- **Discount Status**: Shows current discount availability
- **Result Label**: Displays operation results

### Discount Banner View

A custom view component that displays discount information:

```swift
class DiscountBannerView: UIView {
    // Custom discount display implementation
    // Shows discount details and call-to-action
}
```

## Testing the App

1. **SDK Initialization**: Check the status label for initialization success
2. **Prediction**: Tap "Predict Purchase" to test AI prediction
3. **Event Logging**: Tap "Log Event" to test event tracking
4. **Discount Status**: Monitor discount availability changes
5. **Real-time Updates**: Watch for live discount status updates

## Troubleshooting

### Common Issues

1. **SDK Not Found**: Make sure the package dependencies are resolved
2. **Initialization Failed**: Check your SDK key and network connection
3. **Build Errors**: Verify package dependencies are up to date

### Debug Information

The app includes comprehensive logging:

- SDK initialization status
- Prediction results
- Event logging confirmations
- Error messages with details

## Related Examples

- [Swift Package Manager Example](../SwiftPackageManagerExample/) - Modern SwiftUI implementation
- [CocoaPods Example](../CocoaPodsExample/) - Traditional dependency management

## Getting Help

- 📖 [Main SDK Documentation](../../README.md)
- 🐛 [GitHub Issues](https://github.com/hayanmind/monetai-ios/issues)
- 📧 [Email Support](mailto:support@monetai.io)

---

**Happy coding!** 🚀
