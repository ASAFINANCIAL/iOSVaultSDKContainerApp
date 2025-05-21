import SwiftUI

struct ContentView: View {
    @State private var showReactNativeView = false
    @State private var appDelegate: AppDelegate
    
    init(showReactNativeView: Bool = false, appDelegate: AppDelegate) {
        self.showReactNativeView = showReactNativeView
        self.appDelegate = appDelegate
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Button("Click to start ASA Vault SDK") {
                    showReactNativeView = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .ignoresSafeArea(edges: .all)
            .fullScreenCover(isPresented: $showReactNativeView) {
                ReactNativeView(appDelegate: appDelegate)
                    .ignoresSafeArea(edges: .all)
            }
        }
        .ignoresSafeArea(edges: .all)
    }
}

struct ReactNativeView: UIViewControllerRepresentable {
    @State private var appDelegate: AppDelegate
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        // It returns root view of Vault SDK
        // It is enough just show this View in new VC.
        // Recommended to use it only in full screen mode.
        let rnView = appDelegate.getVaultView()
        rnView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(rnView)
        NSLayoutConstraint.activate([
            rnView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            rnView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            rnView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            rnView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor)
        ])
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
