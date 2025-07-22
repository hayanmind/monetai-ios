import Foundation

/// Utility for managing SDK version information
public struct SDKVersion {
    /// Returns the current SDK version
    public static func getVersion() -> String {
        // Get version information from Bundle
        if let version = Bundle(for: MonetaiSDK.self).infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        
        // Return default value
        return "1.0.0"
    }
} 