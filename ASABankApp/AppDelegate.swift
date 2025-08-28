import UIKit
import SwiftUI
import FirebaseCore
import iosASAVaultSDK // Import the ASA Vault SDK framework


// AppDelegate extends VaultAppDelegate from the iOS Vault SDK
// This provides the base functionality for handling vault-related events
class AppDelegate: VaultAppDelegate {
    
    // Called when the app receives a deep link URL intended for the Vault SDK
    override func incomeVaultSDKUrl(_ url: String) {
        // Store the incoming URL in the SDK configuration for later use
        self.sdkConfiguration?["initialLink"] = url
        
        // Notify ContentView to automatically show the Vault SDK interface
        // This enables automatic opening when deep links are received
        NotificationCenter.default.post(name: NSNotification.Name("ShowVaultSDK"), object: nil)
    }
    
    // Called when the app receives a push notification for the Vault SDK
    override func incomeVaultSDKNotification(_ notificationId: String) {
        // Store the notification ID in the SDK configuration
        self.sdkConfiguration?["initialMessageId"] = notificationId
        // Automatically show the Vault SDK when notification is received
        NotificationCenter.default.post(name: NSNotification.Name("ShowVaultSDK"), object: nil)
    }
    
    // Called when the user closes or exits the Vault SDK
    override func handleSDKDidCloseEvent() {
        // Call the parent implementation to handle cleanup
        super.handleSDKDidCloseEvent()
        
        // Notify ContentView to hide the Vault SDK interface
        // This returns the user to the main app interface
        NotificationCenter.default.post(name: NSNotification.Name("VaultSDKDidClose"), object: nil)
    }
    
    // Standard iOS app launch method - called when app starts
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure the Vault SDK with required parameters
        let initialProps: [String: Any] = [
            // Dynamic link configuration for deep linking functionality
            "dynamicLinkSetup": [
                // Bundle identifier for Android app (used for cross-platform links)
                "androidRootBundle": "ASA.ASABankApp",
                // Bundle identifier for iOS app (must match your app's bundle ID)
                "iosRootBundle": "ASA.ASABankApp",
                // Environment setting - UAT (User Acceptance Testing) or PROD
                "env": "UAT"
            ],
            // ASA Vault SDK specific configuration parameters
            "asavaultsdkparamter": [
                // API subscription key - replace with your actual key from ASA
                "Subscriptionkey": "KEY_PLACEHOLDER", // It should be changed with real key
                // Your financial institution's code assigned by ASA
                "AsaFintechCode": 1, // It should be changed with real AsaFintechCode
                // Your application's code assigned by ASA
                "ApplicationCode": 1, // It should be changed with real ApplicationCode
                // Authorization key for API access - replace with actual key
                "AuthorizationKey":"AuthorizationKey_PLACEHOLDER", // It should be changed with real AuthorizationKey
                // Whether to skip authentication flow (false = require auth)
                "SkipAuth":false
            ]
        ]
        
        // Set the configuration in the parent VaultAppDelegate
        // This initializes the SDK with the above parameters
        self.sdkConfiguration = initialProps
        // Call parent implementation to complete SDK initialization
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    // Handle universal links and user activities (optional override)
    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // Log the user activity for debugging purposes
        print(userActivity)
        // Return true to indicate the activity was handled
        return true
    }
    
}
