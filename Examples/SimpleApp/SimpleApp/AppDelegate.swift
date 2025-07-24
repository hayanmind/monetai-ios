//
//  AppDelegate.swift
//  SimpleApp
//
//  Created by Daehoon Kim on 7/23/25.
//

import UIKit
import MonetaiSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Log test event before SDK initialization to check pending events
        print("🔍 Testing pending events - logging test event before SDK init")
        
        // Initialize Monetai SDK
        Task {
            // Log test event before SDK initialization to check pending events
            await MonetaiSDK.shared.logEvent(eventName: "test_pending_event", params: ["test": "pending_event_check"])
            
            do {
                let result = try await MonetaiSDK.shared.initialize(
                    sdkKey: Constants.sdkKey,
                    userId: Constants.userId,
                    useStoreKit2: Constants.useStoreKit2
                )

                print("Monetai SDK initialization completed:", result)
                
                // Post notification for UI update
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .monetaiSDKInitialized, object: nil)
                }
            } catch {
                print("Monetai SDK initialization failed:", error)
                
                // Post notification for error
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .monetaiSDKInitializationFailed, object: error)
                }
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

