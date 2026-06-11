//
//  CoveApp.swift
//  Cove
//
//  Created by Daniel Cajiao on 2/16/22.
//

import FBSDKCoreKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import OSLog
import SwiftUI
import UIKit

// MARK: - Gateway smoke test

#if DEBUG
    private extension CoveApp {
        /// Calls `GET /health` once at launch and logs the result.
        ///
        /// Exercises the full path: iOS → Cloudflare Tunnel → cove-api gateway.
        /// `/health` is unauthenticated so this runs before the user signs in.
        /// Failure is logged but never surfaces to the user — it must not block
        /// or alter app launch in any way.
        func runGatewaySmokeTest() async {
            let logger = Logger(subsystem: "com.danicajiao.cove", category: "SmokeTest")
            do {
                let health = try await CoveAPIClient.shared.health()
                logger.info("✓ cove-api reachable — service: \(health.service), status: \(health.status), commit: \(health.commit)")
            } catch {
                logger.warning("✗ cove-api smoke test failed: \(error.localizedDescription)")
            }
        }
    }
#endif

// MARK: - AppDelegate

/// no changes in your AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        print("delegate run")
        return true
    }
}

@main
struct CoveApp: App {
    // Inject into SwiftUI life-cycle via adaptor
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appState = AppState()
    @StateObject var bag = Bag()
    @StateObject var favoritesStore = FavoritesStore()
    @StateObject private var networkMonitor = NetworkMonitor()

    @State private var authPath: [AuthPath] = []

    init() {
        print("init run")
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.authState == .loggedIn {
                    MainView()
                        .environment(\.imageRepository, CoveAPIImageRepository())
                        .environmentObject(bag)
                } else if appState.authState == .needsUsernameOnboarding {
                    UsernameOnboardingView(appState: appState)
                } else if appState.authState == .needsInterestOnboarding {
                    InterestOnboardingView(appState: appState)
                } else {
                    NavigationStack(path: $authPath) {
                        ZStack {
                            if networkMonitor.isConnected {
                                WelcomeView(
                                    onNavigateToLogin: { authPath.append(.login) },
                                    onNavigateToSignup: { authPath.append(.signup) }
                                )
                                .transition(.opacity)
                            } else {
                                SplashView()
                                    .transition(.opacity)
                            }
                        }
                        .animation(.default, value: networkMonitor.isConnected)
                        .navigationDestination(for: AuthPath.self) { path in
                            switch path {
                            case .login:
                                LoginView(onNavigateToSignup: { authPath.append(.signup) })
                            case .signup:
                                SignupView(onNavigateToLogin: { authPath.append(.login) })
                            }
                        }
                    }
                }
            }
            .task {
                #if DEBUG
                    await runGatewaySmokeTest()
                #endif
            }
            .onChange(of: appState.authState) { _, _ in
                authPath = []
            }
            .environmentObject(appState)
            .environmentObject(favoritesStore)
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
                ApplicationDelegate.shared.application(UIApplication.shared, open: url, options: [:])
            }
        }
    }
}
