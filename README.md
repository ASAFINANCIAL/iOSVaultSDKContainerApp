# iOS Vault SDK Container App

A comprehensive iOS container application that demonstrates the integration of the **ASA Vault SDK** into a native iOS SwiftUI application. This app serves as a reference implementation for financial institutions and developers looking to integrate ASA's banking and financial services SDK into their iOS applications.

## 🎯 Purpose & Overview

The **iOS Vault SDK Container App** is designed to:

- **Demonstrate SDK Integration**: Show how to properly integrate the `iosASAVaultSDK.xcframework` into a native iOS application
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

1. **iOS Development Environment**: Xcode 14+ with iOS 13+ deployment target
2. **ASA Vault SDK**: Access to `iosASAVaultSDK.xcframework`
3. **Firebase Project**: Valid Google Services configuration
4. **ASA Credentials**: Valid subscription key, fintech code, and authorization key

### Installation Steps

1. **Add the iOS Vault SDK Framework**

   ```bash
   # Place the framework in the ASABankApp directory
   cp iosASAVaultSDK.xcframework ASABankApp/
   ```

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
        "SkipAuth": false
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
        }
        .onAppear {
            setupNotificationObserver()
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

- **Firebase**: Analytics, Performance, Messaging, and Dynamic Links
- **iosASAVaultSDK**: The core ASA Vault SDK framework
- **SwiftUI**: Modern iOS UI framework
- **UIKit**: For React Native bridge components

## 📋 Configuration Checklist

- [ ] `iosASAVaultSDK.xcframework` placed in ASABankApp directory
- [ ] `GoogleService-Info.plist` configured with your Firebase project
- [ ] Real subscription key updated in AppDelegate
- [ ] ASA Fintech Code configured
- [ ] Application Code configured
- [ ] Authorization Key updated
- [ ] Bundle identifiers match your app configuration

## 🚀 Ready to Go

After completing the setup steps above, your iOS Vault SDK Container App is ready to run. All necessary dependencies are pre-installed, and the integration points are fully configured for seamless operation.
