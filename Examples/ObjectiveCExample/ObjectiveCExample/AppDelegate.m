//
//  AppDelegate.m
//  ObjectiveCExample
//
//  Created by Daehoon Kim on 7/24/25.
//

#import "AppDelegate.h"
#import "Constants.h"
#import <MonetaiSDK/MonetaiSDK-Swift.h>
@import RevenueCat;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Log test event before SDK initialization to check pending events
    [[MonetaiSDK shared] logEventWithEventName:@"test_pending_event" params:@{@"test": @"pending_event_check"}];

    // Initialize RevenueCat
    RCPurchases.logLevel = RCLogLevelVerbose;
    [RCPurchases configureWithConfiguration:[[[[RCConfiguration builderWithAPIKey:kRevenueCatAPIKey]
                                               withAppUserID:kUserId]
                                              withStoreKitVersion:kUseStoreKit2 ? RCStoreKitVersion2 : RCStoreKitVersion1]
                                             build]];

    // Initialize Monetai SDK
    [[MonetaiSDK shared] initializeWithSdkKey:kSDKKey
                                       userId:kUserId
                                 useStoreKit2:kUseStoreKit2
                                   completion:^(InitializeResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Monetai SDK initialization failed: %@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kMonetaiSDKInitializationFailedNotification object:error];
            });
        } else {
            NSLog(@"Monetai SDK initialization completed: %@", result);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kMonetaiSDKInitializedNotification object:nil];
            });
        }
    }];

    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
}

@end
