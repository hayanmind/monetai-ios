//
//  Constants.swift
//  SimpleApp
//
//  Created by Daehoon Kim on 7/23/25.
//

import Foundation

struct Constants {
    // MARK: - MonetaiSDK Configuration
    // ⚠️ Important: Replace with your actual API keys before running
    // Never commit real API keys to version control
    
    static let sdkKey = "your-sdk-key-here"
    static let userId = "example-user-id"
    
    // MARK: - App Configuration
    static let useStoreKit2 = true // Recommended: Use StoreKit 2
}

// MARK: - Notification Names
extension Notification.Name {
    static let monetaiSDKInitialized = Notification.Name("monetaiSDKInitialized")
    static let monetaiSDKInitializationFailed = Notification.Name("monetaiSDKInitializationFailed")
} 