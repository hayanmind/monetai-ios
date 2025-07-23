# Monetai iOS Native SDK

Discover hidden app revenue from non-purchasing users using AI-powered iOS Native SDK.

## Features

- 🤖 AI-based user prediction (purchaser/non-purchaser)
- 📊 Real-time event logging
- 🎯 A/B testing support
- 💰 Automatic discount creation and management
- 🛒 StoreKit 1/2 support
- 📱 SwiftUI and UIKit support

## Requirements

- iOS 13.0+
- Swift 5.9+
- Xcode 15.0+

## Security

⚠️ **Important**: The example projects include `Constants.swift` files with placeholder values. Before running the examples, update these files with your actual API keys. Never commit real API keys to version control.

## Installation

### Swift Package Manager (Recommended)

1. Open your project in Xcode
2. Select `File` → `Add Package Dependencies...`
3. Enter the repository URL:
   ```
   https://github.com/hayanmind/monetai-ios.git
   ```
4. Select version and click `Add Package`

### CocoaPods

1. Add MonetaiSDK to your `Podfile`:

   ```ruby
   pod 'MonetaiSDK'
   ```

2. Run pod install:

   ```bash
   pod install
   ```

3. Import the framework:
   ```swift
   import MonetaiSDK
   ```

## Usage

### 1. SDK Initialization

```swift
import MonetaiSDK

// Initialize SDK at app launch
Task {
    do {
        let result = try await MonetaiSDK.shared.initialize(
            sdkKey: "your-sdk-key",
            userId: "user-id",
            useStoreKit2: true // Use StoreKit 2 (recommended)
        )

        print("SDK initialization complete: \(result)")
    } catch {
        print("SDK initialization failed: \(error)")
    }
}
```

### 2. Event Logging

```swift
// Log user behavior events
await MonetaiSDK.shared.logEvent(eventName: "app_launch")
await MonetaiSDK.shared.logEvent(eventName: "button_click", params: ["value": 1.0])

// Using LogEventOptions
let options = LogEventOptions.event("custom_event", params: [
    "category": "user_action",
    "timestamp": Date().timeIntervalSince1970
])
await MonetaiSDK.shared.logEvent(options)
```

### 3. User Prediction

```swift
// Predict user purchase likelihood
do {
    let result = try await MonetaiSDK.shared.predict()

    switch result.prediction {
    case .purchaser:
        print("User likely to purchase")
    case .nonPurchaser:
        print("Predicted as non-purchaser - offer discount")
    case .none:
        print("Unable to predict")
    }
} catch {
    print("Prediction failed: \(error)")
}
```

### 4. Discount Management

```swift
// Check current discount status
do {
    let discount = try await MonetaiSDK.shared.getCurrentDiscount()
    if let discount = discount {
        let isActive = discount.endedAt > Date()
        print("Discount status: \(isActive ? "Active" : "Expired")")
    } else {
        print("No discount available")
    }
} catch {
    print("Failed to check discount: \(error)")
}

// Check if user has active discount
let hasDiscount = try await MonetaiSDK.shared.hasActiveDiscount()
```

### 5. SwiftUI Integration

```swift
import SwiftUI
import MonetaiSDK

struct ContentView: View {
    @StateObject private var monetaiSDK = MonetaiSDK.shared

    var body: some View {
        VStack {
            if monetaiSDK.isInitialized {
                Text("SDK Initialized")
                    .foregroundColor(.green)
            } else {
                Text("Initializing SDK...")
                    .foregroundColor(.orange)
            }

            Button("Predict User") {
                Task {
                    let result = try? await monetaiSDK.predict()
                    // Handle result
                }
            }

            if let discount = monetaiSDK.currentDiscount {
                Text("Discount Available!")
                    .foregroundColor(.blue)
                Text("Expires: \(discount.endedAt.formatted())")
                    .font(.caption)
            }
        }
        .onReceive(monetaiSDK.discountInfoLoaded) {
            // Handle discount info loaded
        }
        .onAppear {
            // Set up discount change callback
            monetaiSDK.onDiscountInfoChange = { discount in
                // Handle discount changes
            }
        }
    }
}
```

### 6. UIKit Integration

```swift
import UIKit
import MonetaiSDK
import Combine

class ViewController: UIViewController {
    private let monetaiSDK = MonetaiSDK.shared
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Subscribe to discount info loaded events
        monetaiSDK.discountInfoLoaded
            .sink { [weak self] in
                self?.updateDiscountUI()
            }
            .store(in: &cancellables)

        // Set up discount change callback
        monetaiSDK.onDiscountInfoChange = { [weak self] discount in
            DispatchQueue.main.async {
                self?.updateDiscountUI()
            }
        }
    }

    private func predictUser() {
        Task {
            do {
                let result = try await monetaiSDK.predict()
                await MainActor.run {
                    // Update UI with prediction result
                }
            } catch {
                // Handle error
            }
        }
    }

    private func updateDiscountUI() {
        // Update UI based on current discount status
        if let discount = monetaiSDK.currentDiscount {
            // Show discount UI
        } else {
            // Hide discount UI
        }
    }
}
```

## API Reference

### MonetaiSDK

#### Initialization

```swift
func initialize(
    sdkKey: String,
    userId: String,
    useStoreKit2: Bool = false
) async throws -> InitializeResult
```

#### Event Logging

```swift
func logEvent(eventName: String, params: [String: Any]? = nil) async
func logEvent(_ options: LogEventOptions) async
```

#### User Prediction

```swift
func predict() async throws -> PredictResponse
```

#### Discount Management

```swift
func getCurrentDiscount() async throws -> AppUserDiscount?
func hasActiveDiscount() async throws -> Bool
```

#### SDK Management

```swift
func reset()
func getUserId() -> String?
func getSdkKey() -> String?
func getInitialized() -> Bool
func getExposureTimeSec() -> Int?
```

### Models

#### InitializeResult

```swift
struct InitializeResult {
    let organizationId: Int
    let platform: String
    let version: String
    let userId: String
    let group: ABTestGroup?
}
```

#### PredictResponse

```swift
struct PredictResponse {
    let prediction: PredictResult?
    let testGroup: ABTestGroup?
}
```

#### PredictResult

```swift
enum PredictResult: String, Codable {
    case nonPurchaser = "non-purchaser"
    case purchaser = "purchaser"
}
```

#### ABTestGroup

```swift
enum ABTestGroup: String, Codable {
    case baseline = "baseline"
    case monetai = "monetai"
    case unknown = "unknown"
}
```

#### AppUserDiscount

```swift
struct AppUserDiscount: Codable {
    let startedAt: Date
    let endedAt: Date
    let appUserId: String
    let sdkKey: String
}
```

#### LogEventOptions

```swift
struct LogEventOptions {
    let eventName: String
    let params: [String: Any]?
    let createdAt: Date

    // Convenience methods
    static func event(_ eventName: String) -> LogEventOptions
    static func event(_ eventName: String, params: [String: Any]) -> LogEventOptions
}
```

## Example Projects

Check out the complete example apps in the `Examples/` directory:

- **Swift Package Manager Example**: `Examples/SwiftPackageManagerExample/`
- **CocoaPods Example**: `Examples/CocoaPodsExample/`

Each example demonstrates:

- SDK initialization
- Event logging
- User prediction
- Discount management
- Integration-specific setup

## Error Handling

```swift
do {
    let result = try await MonetaiSDK.shared.initialize(
        sdkKey: sdkKey,
        userId: userId
    )
} catch MonetaiError.notInitialized {
    // SDK not initialized
} catch MonetaiError.invalidSDKKey {
    // Invalid SDK key
} catch MonetaiError.invalidUserId {
    // Invalid user ID
} catch MonetaiError.apiError(let message) {
    // API error with message
} catch MonetaiError.networkError(let error) {
    // Network error
} catch MonetaiError.storeKitError(let error) {
    // StoreKit error
}
```

## Best Practices

1. **Initialize Early**: Initialize the SDK as early as possible in your app lifecycle
2. **Event Logging**: Log meaningful user interactions for better predictions
3. **Error Handling**: Always handle potential errors when calling SDK methods
4. **User Privacy**: Ensure user consent before tracking events
5. **Testing**: Test with different user types and scenarios

## License

MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- Issues: [GitHub Issues](https://github.com/hayanmind/monetai-ios/issues)
- Email: support@monetai.io
- Documentation: [https://docs.monetai.io](https://docs.monetai.io)

---

Made with ❤️ by the Monetai Team
