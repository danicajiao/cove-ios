//
//  CoveApp.swift
//  Cove
//
//  Created by Daniel Cajiao on 2/16/22.
//

import SwiftUI
import UIKit
import FirebaseCore

// no changes in your AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct CoveApp: App {
    
    // Inject into SwiftUI life-cycle via adaptor
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
//            MainView()
        }
    }
}
