//
//  AppState.swift
//  Cove
//
//  Created by Daniel Cajiao on 12/16/22.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit

enum Path : Hashable {
    case welcome
    case login
    case signup
    case main
    case home
    case product(any Product)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .welcome:
            hasher.combine(0)
        case .login:
            hasher.combine(1)
        case .signup:
            hasher.combine(2)
        case .main:
            hasher.combine(3)
        case .home:
            hasher.combine(4)
        case .product(let product):
            hasher.combine(5)
            if let coffeeProduct = product as? CoffeeProduct {
                hasher.combine(coffeeProduct)
            } else if let musicProduct = product as? MusicProduct {
                hasher.combine(musicProduct)
            } else if let apparelProduct = product as? ApparelProduct {
                hasher.combine(apparelProduct)
            }
            // add more cases as needed for other types
        }
    }
    
    static func == (lhs: Path, rhs: Path) -> Bool {
        switch (lhs, rhs) {
        case (.welcome, .welcome), (.login, .login), (.signup, .signup), (.main, .main), (.home, .home), (.product, .product):
            return true
        default:
            return false
        }
    }
}

enum AuthState {
    case loggedIn
    case loggedOut
}

enum AuthMethod: String {
    case email = "password"
    case apple = "apple.com"
    case facebook = "facebook.com"
    case google = "google.com"
}

class AppState: ObservableObject {
    @Published var path: [Path] = []
    @Published var authState: AuthState = .loggedOut
    var authMethod: AuthMethod? = nil
    
    func emailSignUp(email: String, password: String, onFailure: @escaping (Error?) -> Void, onSuccess: @escaping () -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error != nil {
                onFailure(error)
            } else {
                self.path.append(.main)
                onSuccess()
            }
        }
    }
    
    func emailLogIn(email: String, password: String, onFailure: @escaping (Error?) -> Void, onSuccess: @escaping () -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            // ...
            if error != nil {
                onFailure(error)
//                print(error?.localizedDescription ?? "")
            } else {
                strongSelf.path.append(.main)
                onSuccess()
            }
        }
    }
    
    func facebookLogIn(onFailure: @escaping (Error) -> Void) {
        // 1
        self.authMethod = .facebook
        
        let loginManager = LoginManager()
        
        if let _ = AccessToken.current {
            // Access token available -- user already logged in
            // Perform log out
            
            // 2
            loginManager.logOut()
            
        } else {
            // Access token not available -- user already logged out
            // Perform log in
            
            // 3
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
            
            loginManager.logIn(permissions: ["email"], from: rootViewController) { (result, error) in
                
                // 4
                // Check for error
                guard error == nil else {
                    // Error occurred
                    self.authMethod = nil
                    print(error!.localizedDescription)
                    return
                }
                
                // 5
                // Check for cancel
                guard let result = result, !result.isCancelled else {
                    self.authMethod = nil
                    print("User cancelled login")
                    return
                }
                
                
                              
                // Successfully logged in
                // 6
//                self?.updateButton(isLoggedIn: true)
//                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                
                
                // 7
//                Profile.loadCurrentProfile { (profile, error) in
//                    self?.updateMessage(with: Profile.current?.name)
//                }
                
                var user: Profile?
                var error: Error?
                
                Profile.loadCurrentProfile { profile, fbError in
                    user = profile
                    error = fbError
                }
                
                self.authenticateUser(for: user, with: error) { error in
                    onFailure(error)
                }
            }
        }
    }
    
    func googleLogIn(onFailure: @escaping (Error) -> Void) {
        // 1
        self.authMethod = .google
        
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                authenticateUser(for: user, with: error) { error in
                    onFailure(error)
                }
            }
        } else {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
            // 5
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
                guard let result = signInResult else {
                    // Inspect error
                    self.authMethod = nil
                    print(error?.localizedDescription ?? "")
                    return
                }
                self.authenticateUser(for: result.user, with: error) { error in
                    onFailure(error)
                }
            }
        }
    }
    
    /// Authenticate Google user with Firebase
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?, onFailure: @escaping (Error) -> Void) {
        // 1
        if let error = error {
            self.authMethod = nil
            print(error.localizedDescription)
            return
        }

        // 2
        guard
            let accessToken = user?.accessToken.tokenString,
            let idToken = user?.idToken?.tokenString
        else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

        // 3
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                GIDSignIn.sharedInstance.signOut()
                
                self.authMethod = nil
                print(error.localizedDescription)
            } else {
                self.authState = .loggedIn
                self.path.append(.main)
            }
        }
    }
    
    /// Authenticate Facebook user with Firebase
    private func authenticateUser(for user: Profile?, with error: Error?, onFailure: @escaping (Error) -> Void) {
        // 1
        if let error = error {
            self.authMethod = nil
            print(error.localizedDescription)
            return
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)

        // 3
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                let loginManager = LoginManager()
                
                loginManager.logOut()

                self.authMethod = nil
                print(error.localizedDescription)
                onFailure(error)
            } else {
                self.authState = .loggedIn
                self.path.append(.main)
            }
        }
    }
    
    func logOut() {
        guard let providerID = Auth.auth().currentUser?.providerData.first?.providerID as String? else {
            print("No user is logged in")
            return
        }
        
        switch providerID {
        case AuthMethod.apple.rawValue:
            print("Logging out apple user")
        case AuthMethod.facebook.rawValue:
            print("Logging out facebook user")
            do {
                try Auth.auth().signOut()
                LoginManager().logOut()
                self.authMethod = nil
                self.authState = .loggedOut
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        case AuthMethod.google.rawValue:
            print("Logging out google user")
            do {
                try Auth.auth().signOut()
                GIDSignIn.sharedInstance.signOut()
                self.authMethod = nil
                self.authState = .loggedOut
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        case AuthMethod.email.rawValue:
            print("Logging out email user")
            do {
                try Auth.auth().signOut()
                self.authMethod = nil
                self.authState = .loggedOut
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        default:
            print("No authMethod was set, this might be a bug.")
        }
    }
}
