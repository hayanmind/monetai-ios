# Monetai iOS SDK Examples

This directory contains example projects demonstrating how to integrate Monetai iOS SDK using different package managers and languages. All examples showcase **dynamic pricing** via the `getOffer` API with RevenueCat for subscription management.

## Available Examples

### Swift Package Manager Example

**Location**: `SwiftPackageManagerExample/`

- Native Xcode dependency management with Swift Package Manager
- SwiftUI with RevenueCat integration
- Dynamic pricing with `getOffer` API
- Complete production-ready example

[View Swift Package Manager Example](SwiftPackageManagerExample/)

### CocoaPods Example

**Location**: `CocoaPodsExample/`

- Traditional iOS dependency manager
- SwiftUI with RevenueCat integration
- Dynamic pricing with `getOffer` API
- Easy setup with Podfile

[View CocoaPods Example](CocoaPodsExample/)

### Objective-C Example

**Location**: `ObjectiveCExample/`

- Objective-C implementation with completion handler pattern
- UIKit-based interface with CocoaPods
- Dynamic pricing with `getOffer` API
- RevenueCat integration for product loading and purchases
- Perfect for Objective-C codebases

[View Objective-C Example](ObjectiveCExample/)

## Quick Start

1. **Choose** your preferred integration method
2. **Navigate** to the example directory
3. **Follow** the example's README for detailed setup instructions
4. **Configure** your API keys in `Constants.swift` (or `Constants.m` for Objective-C)
5. **Build and run** the example

## Common Features

All examples demonstrate:

- SDK initialization and configuration
- Dynamic pricing with `getOffer` API
- Event logging with parameters
- RevenueCat integration for subscription management
- Product display with discount pricing
- `logViewProductItem` for product view tracking

## Prerequisites

- **Xcode**: 15.0 or later
- **iOS**: 16.0 or later
- **Valid SDK Key**: Obtain from Monetai Dashboard
- **RevenueCat API Key**: Required for subscription features

## Getting Help

- [Main SDK Documentation](../README.md)
- [GitHub Issues](https://github.com/hayanmind/monetai-ios/issues)
- [Email Support](mailto:support@monetai.io)
- [Online Documentation](https://docs.monetai.io)
