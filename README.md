# iOSVaultSDKContainerApp

1. Before start put the **iosASAVaultSDK.xcframework** into mynativeiosapp directory.
2. Put real sdk configuration information in **AppDelegate**
3. Copy the valid google services plist file into this directory iOSVaultSDKContainerApp/mynativeiosapp/GoogleService-Info.plist

After this example is ready to go. All needed dependencies are pre-installed already.

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
