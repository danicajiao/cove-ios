//
//  CoveApp.swift
//  Cove
//
//  Created by Daniel Cajiao on 2/16/22.
//

import SwiftUI
import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FBSDKCoreKit

// no changes in your AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        print("delegate run")
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return ApplicationDelegate.shared.application(
            application,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}

@main
struct CoveApp: App {
    // Inject into SwiftUI life-cycle via adaptor
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appState = AppState()
    @StateObject var bag = Bag()
    @StateObject private var networkMonitor = NetworkMonitor()
    
    init() {
        print("init run")
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: self.$appState.path) {
                // Root View
                ZStack {
                    if networkMonitor.isConnected {
                        WelcomeView()
                            .transition(.opacity)
                    } else {
                        SplashView()
                            .transition(.opacity)
                    }
                }
                .animation(.default, value: networkMonitor.isConnected)
                .navigationDestination(for: Path.self) { path in
                    switch path {
                    case .welcome:
                        WelcomeView()
                    case .login:
                        LogInView()
                    case .signup:
                        SignUpView()
                    case .main:
                        MainView()
                            .environmentObject(bag)
                    case .home:
                        HomeView()
                    case .product(let product):
                        ProductDetailView(product: product)
                            .environmentObject(bag)
                    }
                }
            }
            .environmentObject(self.appState)
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
