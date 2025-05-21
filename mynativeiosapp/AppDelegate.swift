import UIKit
import SwiftUI
import FirebaseCore
import iosASAVaultSDK


class AppDelegate: VaultAppDelegate {
    
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
}
