import Foundation

/// Utility for managing SDK version information
public struct SDKVersion {
    /// Returns the current SDK version
    /// 
    /// Note: This version should be updated using the update_version.sh script
    /// to match the version in MonetaiSDK.podspec and .version file
    public static func getVersion() -> String {
        return "1.0.0"
    }
} 