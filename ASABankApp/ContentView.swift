import SwiftUI

// Main SwiftUI view that serves as the container for the ASA Vault SDK
// Provides user interface controls and manages the SDK display state
struct ContentView: View {
    // State variable to control whether the Vault SDK interface is shown
    // This is the key state that triggers the full-screen SDK presentation
    @State private var showReactNativeView = false
    // Reference to AppDelegate to access SDK methods and configuration
    @State private var appDelegate: AppDelegate
    
    // Custom initializer to inject the AppDelegate dependency
    // Allows optional initial state for showReactNativeView (defaults to false)
    init(showReactNativeView: Bool = false, appDelegate: AppDelegate) {
        self.showReactNativeView = showReactNativeView
        self.appDelegate = appDelegate
    }
    
    var body: some View {
        // NavigationView provides the base navigation structure
        NavigationView {
            // VStack arranges the buttons vertically
            VStack {
                // Manual trigger button for opening the Vault SDK
                // Users can tap this to manually start the SDK interface
                Button("Click to start ASA Vault SDK") {
                    // Set state to true to trigger the full-screen SDK presentation
                    showReactNativeView = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                // Logout button to clear user session from the Vault SDK
                // Calls the SDK's logout method to clear authentication state
                Button("Click to logout user from ASA Vault SDK") {
                    // Call the SDK's logout method through AppDelegate
                    appDelegate.doLogoutSDK()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .ignoresSafeArea(edges: .all)
            // Full-screen modal presentation of the Vault SDK
            // This covers the entire screen when showReactNativeView is true
            .fullScreenCover(isPresented: $showReactNativeView) {
                // Present the React Native Vault SDK interface
                ReactNativeView(appDelegate: appDelegate)
                    .ignoresSafeArea(edges: .all)
            }
        }
        .ignoresSafeArea(edges: .all)
        // Set up notification observers when the view appears
        .onAppear {
            setupNotificationObserver()
        }
        // Clean up notification observers when the view disappears
        .onDisappear {
            removeNotificationObserver()
        }
    }
    
    // Set up NotificationCenter observers to listen for SDK-related events
    // This enables automatic SDK display when deep links or notifications are received
    private func setupNotificationObserver() {
        // Listen for "ShowVaultSDK" notifications from AppDelegate
        // This is triggered when deep links or push notifications are received
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ShowVaultSDK"),
            object: nil,
            queue: .main // Ensure UI updates happen on main thread
        ) { _ in
            // Automatically show the Vault SDK interface
            showReactNativeView = true
        }
        
        // Listen for "VaultSDKDidClose" notifications from AppDelegate
        // This is triggered when the user exits the Vault SDK
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("VaultSDKDidClose"),
            object: nil,
            queue: .main // Ensure UI updates happen on main thread
        ) { _ in
            // Hide the Vault SDK interface and return to main app
            showReactNativeView = false
        }
    }
    
    // Clean up notification observers to prevent memory leaks
    // Called when the view is about to disappear
    private func removeNotificationObserver() {
        // Remove observer for ShowVaultSDK notification
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ShowVaultSDK"), object: nil)
        // Remove observer for VaultSDKDidClose notification
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("VaultSDKDidClose"), object: nil)
    }
}

// UIViewControllerRepresentable bridge to integrate React Native Vault SDK with SwiftUI
// This struct wraps the SDK's React Native interface in a SwiftUI-compatible view
struct ReactNativeView: UIViewControllerRepresentable {
    // Reference to AppDelegate to access the Vault SDK methods
    @State private var appDelegate: AppDelegate
    
    // Initialize with AppDelegate reference for SDK access
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }
    
    // Create the UIViewController that will host the React Native Vault SDK
    // This method is called once when the view is first created
    func makeUIViewController(context: Context) -> UIViewController {
        // Create a standard UIViewController to serve as the container
        let viewController = UIViewController()
        
        // Get the React Native root view from the Vault SDK
        // This returns the main interface of the ASA Vault SDK
        // The SDK provides this view ready for full-screen presentation
        let rnView = appDelegate.getVaultView()
        
        // Disable autoresizing mask to use Auto Layout constraints instead
        rnView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the Vault SDK view as a subview of our container
        viewController.view.addSubview(rnView)
        
        // Set up Auto Layout constraints to make the SDK view fill the entire screen
        // This ensures the Vault SDK interface uses the full available space
        NSLayoutConstraint.activate([
            // Pin the top of SDK view to top of container
            rnView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            // Pin the bottom of SDK view to bottom of container
            rnView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            // Pin the leading edge of SDK view to leading edge of container
            rnView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            // Pin the trailing edge of SDK view to trailing edge of container
            rnView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor)
        ])
        
        // Return the configured view controller
        return viewController
    }
    
    // Called when SwiftUI needs to update the view controller
    // Currently no updates are needed, so this remains empty
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
