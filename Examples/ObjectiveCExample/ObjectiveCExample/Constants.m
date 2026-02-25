//
//  Constants.m
//  ObjectiveCExample
//
//  Created by Daehoon Kim on 7/24/25.
//

#import "Constants.h"

// MARK: - MonetaiSDK Configuration
NSString * const kSDKKey = @"your-sdk-key-here";
NSString * const kUserId = @"example-user-id";
BOOL const kUseStoreKit2 = YES;
NSInteger const kPromotionId = 6;
NSString * const kDefaultProductId = @"your-default-product-id-here";

// MARK: - RevenueCat Configuration
NSString * const kRevenueCatAPIKey = @"your-revenuecat-api-key-here";

// MARK: - Notification Names
NSString * const kMonetaiSDKInitializedNotification = @"monetaiSDKInitialized";
NSString * const kMonetaiSDKInitializationFailedNotification = @"monetaiSDKInitializationFailed";
