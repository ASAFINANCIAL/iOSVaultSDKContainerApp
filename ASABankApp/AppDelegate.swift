import UIKit
import SwiftUI
import FirebaseCore
import iosASAVaultSDK


class AppDelegate: VaultAppDelegate {
    
    override func incomeVaultSDKUrl(_ url: String) {
        self.sdkConfiguration?["initialLink"] = url
        
        // Post notification to ContentView to show React Native view
        NotificationCenter.default.post(name: NSNotification.Name("ShowVaultSDK"), object: nil)
    }
    
    override func incomeVaultSDKNotification(_ notificationId: String) {
        self.sdkConfiguration?["initialMessageId"] = notificationId
        NotificationCenter.default.post(name: NSNotification.Name("ShowVaultSDK"), object: nil)
    }
    
    override func handleSDKDidCloseEvent() {
        super.handleSDKDidCloseEvent()
        
        // Post notification to ContentView to hide React Native view
        NotificationCenter.default.post(name: NSNotification.Name("VaultSDKDidClose"), object: nil)
    }
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let initialProps: [String: Any] = [
            "dynamicLinkSetup": [
                "universalUri": "https://asacore.com/asavault",
                "domainuri": "https://asavault.page.link",
                "androidRootBundle": "com.asavault.mynativeiosapp",
                "iosRootBundle": "com.asavault.mynativeiosapp",
                "env": "UAT"
            ],
            "asavaultsdkparamter": [
                "Subscriptionkey": "KEY_PLACEHOLDER", // It should be changed with real key
                "AsaFintechCode": 1, // It should be changed with real AsaFintechCode
                "ApplicationCode": 1, // It should be changed with real ApplicationCode
                "AuthorizationKey":"AuthorizationKey_PLACEHOLDER", // It should be changed with real AuthorizationKey
                "SkipAuth":false
            ]
        ]
        
        self.sdkConfiguration = initialProps
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        print(userActivity)
        return true
    }
    
}
