//
//  ASABankAppApp.swift
//  ASABankApp
//
//  Created by Mykola Hrybeniuk on 28.08.2025.
//

import SwiftUI

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView(appDelegate: appDelegate)
        }
    }
}
