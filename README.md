# iOS Vault SDK Container App

A comprehensive iOS container application that demonstrates the integration of the **ASA Vault SDK** into a native iOS SwiftUI application. This app serves as a reference implementation for financial institutions and developers looking to integrate ASA's banking and financial services SDK into their iOS applications.

## 🎯 Purpose & Overview

The **iOS Vault SDK Container App** is designed to:

- **Demonstrate SDK Integration**: Show how to integrate the ASA Vault SDK via the private Swift Package (recommended) or by embedding the `iosASAVaultSDK.xcframework` directly
- **Provide Reference Implementation**: Serve as a working example for developers implementing ASA Vault services
- **Handle Deep Links**: Process incoming vault URLs and notifications automatically
- **Manage User Sessions**: Handle user authentication and logout functionality
- **Bridge Native & React Native**: Seamlessly integrate React Native components within a SwiftUI application

The app acts as a container that hosts the ASA Vault SDK's React Native interface, providing banking and financial services through a native iOS experience.

## 🏗️ Architecture

### Key Components

1. **AppDelegate**: Extends `VaultAppDelegate` to handle SDK lifecycle and deep links
2. **ContentView**: SwiftUI main interface with SDK integration controls
3. **ReactNativeView**: UIViewControllerRepresentable that hosts the Vault SDK's React Native interface
4. **NotificationCenter Communication**: Enables communication between AppDelegate and ContentView

### Integration Flow

```
Deep Link/Notification → AppDelegate → NotificationCenter → ContentView → ReactNativeView → Vault SDK
```

## 🔧 Setup Instructions

### Prerequisites

1. **iOS Development Environment**: Xcode 16.3+ (this project's deployment target is iOS 18.0)
2. **ASA Vault SDK Access**: GitHub access to the private [ios-asavaultsdk-spm](https://github.com/ASAFINANCIAL/ios-asavaultsdk-spm) repository (SSH key or personal access token), or a copy of the SDK xcframeworks for direct embedding
3. **CocoaPods**: Required for the SDK's native dependencies (Firebase, Sentry, Branch, Lottie) in both integration options
4. **Firebase Project**: Valid Google Services configuration
5. **ASA Credentials**: Valid subscription key, fintech code, application code, and authorization key

### Installation Steps

1. **Add the ASA Vault SDK** — choose one of the two options:

   **Option A — Private Swift Package (recommended, used by this app)**

   In Xcode: **File → Add Package Dependencies…**, enter the repository URL:

   ```
   https://github.com/ASAFINANCIAL/ios-asavaultsdk-spm
   ```

   Select the `main` branch (or a release tag), then add the **ASAVaultSDK** product to your app target. Xcode will prompt for GitHub credentials since the repository is private. The package bundles both `iosASAVaultSDK.xcframework` and `hermes.xcframework`, so no manual framework handling is needed.

   **Option B — Direct xcframework embedding**

   Copy **both** xcframeworks into your project (the SDK requires the Hermes engine alongside it):

   ```bash
   cp -R iosASAVaultSDK.xcframework hermes.xcframework YourApp/
   ```

   Then drag them into Xcode and add both to your target under **General → Frameworks, Libraries, and Embedded Content** with **Embed & Sign**.

2. **Configure Firebase**

   ```bash
   # Copy your Firebase configuration file
   cp GoogleService-Info.plist ASABankApp/
   ```

3. **Update SDK Configuration**
   Edit the configuration in `AppDelegate.swift` with your actual credentials:

   ```swift
   "Subscriptionkey": "YOUR_ACTUAL_SUBSCRIPTION_KEY",
   "AsaFintechCode": YOUR_FINTECH_CODE,
   "ApplicationCode": YOUR_APPLICATION_CODE,
   "AuthorizationKey": "YOUR_ACTUAL_AUTHORIZATION_KEY"
   ```

4. **Install Dependencies**

   ```bash
   pod install
   ```

   > ⚠️ **Important**: the Podfile's `post_install` hook that sets `BUILD_LIBRARY_FOR_DISTRIBUTION = YES` for `lottie-ios` is required. The SDK binary is built with library evolution enabled and calls Lottie through resilient dispatch thunks — without this setting the app crashes at launch with `dyld: Symbol not found`. If you are integrating into your own project, replicate this hook in your Podfile:
   >
   > ```ruby
   > post_install do |installer|
   >   installer.pods_project.targets.each do |target|
   >     if ['lottie-ios'].include?(target.name)
   >       target.build_configurations.each do |config|
   >         config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
   >       end
   >     end
   >   end
   > end
   > ```

5. **Open Workspace**
   ```bash
   open ASABankApp.xcworkspace
   ```

## 💻 iOS Vault SDK Integration Details

### 1. AppDelegate Integration

The `AppDelegate` class extends `VaultAppDelegate` from the iOS Vault SDK:

```swift
import iosASAVaultSDK

class AppDelegate: VaultAppDelegate {

    // Handle incoming vault URLs (deep links)
    override func incomeVaultSDKUrl(_ url: String) {
        self.sdkConfiguration?["initialLink"] = url
        NotificationCenter.default.post(name: NSNotification.Name("ShowVaultSDK"), object: nil)
    }

    // Handle push notifications
    override func incomeVaultSDKNotification(_ notificationId: String) {
        self.sdkConfiguration?["initialMessageId"] = notificationId
        NotificationCenter.default.post(name: NSNotification.Name("ShowVaultSDK"), object: nil)
    }

    // Handle SDK close events
    override func handleSDKDidCloseEvent() {
        super.handleSDKDidCloseEvent()
        NotificationCenter.default.post(name: NSNotification.Name("VaultSDKDidClose"), object: nil)
    }
}
```

### 2. SDK Configuration

The SDK is configured with dynamic link setup and ASA Vault parameters:

```swift
let initialProps: [String: Any] = [
    "dynamicLinkSetup": [
        "androidRootBundle": "ASA.ASABankApp",
        "iosRootBundle": "ASA.ASABankApp",
        "env": "UAT"
    ],
    "asavaultsdkparamter": [
        "Subscriptionkey": "KEY_PLACEHOLDER",
        "AsaFintechCode": 1,
        "ApplicationCode": 1,
        "AuthorizationKey": "AuthorizationKey_PLACEHOLDER",
        "SkipAuth": false,
        "debugEnabled": true
    ]
]
```

### 3. SwiftUI Integration

The main `ContentView` provides user interface controls and manages the SDK display:

```swift
struct ContentView: View {
    @State private var showReactNativeView = false
    @State private var appDelegate: AppDelegate

    var body: some View {
        NavigationView {
            VStack {
                Button("Click to start ASA Vault SDK") {
                    showReactNativeView = true
                }

                Button("Click to logout user from ASA Vault SDK") {
                    appDelegate.doLogoutSDK()
                }
            }
            .fullScreenCover(isPresented: $showReactNativeView) {
                ReactNativeView(appDelegate: appDelegate)
                    .ignoresSafeArea(edges: .all)
            }
        }
        .onAppear {
            setupNotificationObserver()
        }
        .onDisappear {
            removeNotificationObserver()
        }
    }
}
```

### 4. React Native Bridge

The `ReactNativeView` bridges SwiftUI with the Vault SDK's React Native interface:

```swift
struct ReactNativeView: UIViewControllerRepresentable {
    @State private var appDelegate: AppDelegate

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()

        // Get the Vault SDK's root view
        let rnView = appDelegate.getVaultView()
        rnView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(rnView)

        // Set up full-screen constraints
        NSLayoutConstraint.activate([
            rnView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            rnView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            rnView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            rnView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor)
        ])

        return viewController
    }
}
```

### 5. NotificationCenter Communication

The app uses NotificationCenter to enable communication between AppDelegate and ContentView:

```swift
// In ContentView - Setup observers
private func setupNotificationObserver() {
    NotificationCenter.default.addObserver(
        forName: NSNotification.Name("ShowVaultSDK"),
        object: nil,
        queue: .main
    ) { _ in
        showReactNativeView = true
    }

    NotificationCenter.default.addObserver(
        forName: NSNotification.Name("VaultSDKDidClose"),
        object: nil,
        queue: .main
    ) { _ in
        showReactNativeView = false
    }
}
```

## 🔑 Key Features

- **Automatic Deep Link Handling**: Automatically opens the Vault SDK when receiving vault URLs
- **Push Notification Support**: Handles incoming vault notifications
- **Session Management**: Provides logout functionality
- **Full-Screen Experience**: Vault SDK runs in full-screen mode for optimal user experience
- **Seamless Integration**: Native iOS app with embedded React Native Vault SDK

## 📱 Usage

1. **Launch the App**: The main screen shows two buttons
2. **Start Vault SDK**: Tap "Click to start ASA Vault SDK" to manually open the vault interface
3. **Automatic Opening**: The vault will also open automatically when receiving deep links or notifications
4. **Logout**: Use "Click to logout user from ASA Vault SDK" to clear user session
5. **Navigation**: The vault interface will close automatically when the user completes their session

## 🔧 Dependencies

The SDK itself is consumed via the private Swift Package (or embedded xcframeworks). Its native dependencies are installed through CocoaPods, pinned to the versions the SDK binary was built against:

| Dependency | Version | Purpose |
| --- | --- | --- |
| `Firebase/Analytics`, `Firebase/Performance`, `Firebase/Messaging`, `Firebase/Firestore` | 11.15.0 | Analytics, performance monitoring, push messaging, data sync |
| `BranchSDK` | 3.14.0 | Deep linking (replaces the discontinued Firebase Dynamic Links) |
| `Sentry` | 8.58.0 | Crash reporting |
| `lottie-ios` | 4.6.0 | Animations (must be built with `BUILD_LIBRARY_FOR_DISTRIBUTION = YES` — see step 4) |

Plus the frameworks that ship with the SDK package: **iosASAVaultSDK** (the core SDK) and **Hermes** (the React Native JS engine), and Apple's **SwiftUI**/**UIKit** for the app shell and React Native bridge.

## 📋 Configuration Checklist

- [ ] SDK added — either the `ios-asavaultsdk-spm` package (product **ASAVaultSDK**) or `iosASAVaultSDK.xcframework` + `hermes.xcframework` embedded with Embed & Sign
- [ ] `GoogleService-Info.plist` configured with your Firebase project
- [ ] Real subscription key updated in AppDelegate
- [ ] ASA Fintech Code configured
- [ ] Application Code configured
- [ ] Authorization Key updated
- [ ] `pod install` run, including the `lottie-ios` `post_install` hook
- [ ] Bundle identifiers match your app configuration

## 🚀 Ready to Go

After completing the setup steps above, your iOS Vault SDK Container App is ready to run. This repository comes pre-wired with the Swift Package integration and committed Pods, so cloning it, updating the credentials, and opening `ASABankApp.xcworkspace` is enough to build and run the demo.
