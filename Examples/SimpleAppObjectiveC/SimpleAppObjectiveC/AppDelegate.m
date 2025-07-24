//
//  AppDelegate.m
//  SimpleAppObjectiveC
//
//  Created by Daehoon Kim on 7/24/25.
//

#import "AppDelegate.h"
#import "Constants.h"
#import <MonetaiSDK/MonetaiSDK-Swift.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Initialize Monetai SDK
    [[MonetaiSDK shared] initializeWithSdkKey:kSDKKey
                                       userId:kUserId
                                useStoreKit2:kUseStoreKit2
                                  completion:^(InitializeResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Monetai SDK initialization failed: %@", error.localizedDescription);
            
            // Post notification for error
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kMonetaiSDKInitializationFailedNotification object:error];
            });
        } else {
            NSLog(@"Monetai SDK initialization completed: %@", result);
            
            // Post notification for UI update
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kMonetaiSDKInitializedNotification object:nil];
            });
        }
    }];
    
    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

@end
