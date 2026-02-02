//
//  SocialButton.swift
//  Cove
//
//  Created by Daniel Cajiao on 12/20/22.
//

import SwiftUI

enum SocialType {
    case apple
    case facebook
    case google
}

struct SmallSocialButton: View {
    @EnvironmentObject var appState: AppState
    
    @State private var presentAlert = false
    @State private var errorMessage: String? = nil
    
    let socialType: SocialType
    let color: Color
    let imgName: String

    init(socialType: SocialType) {
        self.socialType = socialType
        
        switch self.socialType {
        case .apple:
            self.color = .black
            self.imgName = "apple"
        case .facebook:
            self.color = Color(red: 0.376, green: 0.537, blue: 0.839)
            self.imgName = "facebook"
        case .google:
            self.color = .white
            self.imgName = "google"
        }
    }
    
    var body: some View {
        Button {
            // TODO: Add Links to Social Provider Views
            switch self.socialType {
            case .apple:
                print("Apple sign in pressed")
            case .facebook:
                print("Facebook sign in pressed")
                self.appState.facebookLogIn { error in
                    self.errorMessage = error.localizedDescription
                    self.presentAlert = true
                }
            case .google:
                print("Google sign in pressed")
                self.appState.googleLogIn { error in
                    self.errorMessage = error.localizedDescription
                    self.presentAlert = true
                }
            }
        } label: {
            Circle()
                .fill(self.color)
                .strokeBorder(.borderPrimary, lineWidth: 1)
                .frame(width: 55, height: 55)
                .overlay {
                    Image(self.imgName)
                }
        }
        .alert(isPresented: $presentAlert) {
            Alert(
                title: Text("Error"),
                message: Text(self.errorMessage ?? "")
            )
        }
    }
}

struct SmallSocialButton_Previews: PreviewProvider {
    static var previews: some View {
        SmallSocialButton(socialType: .google)
    }
}
