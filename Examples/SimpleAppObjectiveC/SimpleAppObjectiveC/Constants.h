//
//  Constants.h
//  SimpleAppObjectiveC
//
//  Created by Daehoon Kim on 7/24/25.
//

#import <Foundation/Foundation.h>

// MARK: - MonetaiSDK Configuration
// ⚠️ Important: Replace with your actual API keys before running
// Never commit real API keys to version control

extern NSString * const kSDKKey;
extern NSString * const kUserId;
extern BOOL const kUseStoreKit2;

// MARK: - Notification Names
extern NSString * const kMonetaiSDKInitializedNotification;
extern NSString * const kMonetaiSDKInitializationFailedNotification; 