import Foundation

/// Utility for managing SDK version information
public struct SDKVersion {
    /// Returns the current SDK version
    public static func getVersion() -> String {
        // Try to get version from Bundle info (works for both platforms)
        if let version = Bundle(for: MonetaiSDK.self).infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        
        // Fallback version - this should match the version in podspec and git tag
        return "0.0.0"
    }
} 