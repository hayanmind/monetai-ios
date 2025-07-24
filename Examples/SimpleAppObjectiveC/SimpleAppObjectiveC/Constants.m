//
//  Constants.m
//  SimpleAppObjectiveC
//
//  Created by Daehoon Kim on 7/24/25.
//

#import "Constants.h"

// MARK: - MonetaiSDK Configuration
NSString * const kSDKKey = @"your-sdk-key-here";
NSString * const kUserId = @"example-user-id";
BOOL const kUseStoreKit2 = YES; // Recommended: Use StoreKit 2

// MARK: - Notification Names
NSString * const kMonetaiSDKInitializedNotification = @"monetaiSDKInitialized";
NSString * const kMonetaiSDKInitializationFailedNotification = @"monetaiSDKInitializationFailed"; 