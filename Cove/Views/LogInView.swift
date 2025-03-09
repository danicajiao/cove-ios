//
//  LogInView.swift
//  Cove
//
//  Created by Daniel Cajiao on 12/16/22.
//

import SwiftUI
import FirebaseAuth

enum Field: Hashable {
    case email
    case password
}

struct LogInView: View {
    @EnvironmentObject private var appState: AppState
    
    @State private var presentAlert = false
    @State private var errorMessage: String? = nil
    
    @State var showImage: Bool = true
    
    @State var email: String = ""
    @State var password: String = ""
    
    @FocusState private var focusedField: Field?

    var spectrum = Gradient(colors: [
        .spectrumRed,
        .spectrumOrange,
        .spectrumYellow,
        .spectrumGreen,
        .spectrumBlue,
        .spectrumViolet
    ])
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Cove.")
                .font(.custom("Gazpacho-Heavy", size: 50))
            
            Capsule()
                .fill(LinearGradient(gradient: spectrum, startPoint: .leading, endPoint: .trailing))
                .frame(maxWidth: .infinity, maxHeight: 4)
            
            Text("Log in to your account")
                .font(.custom("Lato-Bold", size: 28))
                .frame(maxWidth: .infinity, alignment: .leading)
        
            VStack(spacing: 4) {
                EmailField(text: $email, focus: $focusedField)
                PasswordField(text: $password, focus: $focusedField)
            }
            
            Button {
                self.appState.emailLogIn(email: self.email, password: self.password, onFailure: { error in
                    self.presentAlert = true
                    self.errorMessage = error?.localizedDescription
                }, onSuccess: {
                    self.email = ""
                    self.password = ""
                })
            } label: {
                Text("Log in")
            }
            .buttonStyle(PrimaryButton())
            
            
            HStack {
                Capsule()
                    .fill(.black.opacity(0.5))
                    .frame(height: 2)
                    .padding(.leading, 60)
                    .padding(.trailing)
                Text("OR")
                    .font(.custom("Lato-Regular", size: 12))
                Capsule()
                    .fill(.black.opacity(0.5))
                    .frame(height: 2)
                    .padding(.trailing, 60)
                    .padding(.leading)
            }
            
            // TODO: Add Links to Social Provider Views
            HStack(spacing: 30) {
                SmallSocialButton(socialType: .apple)
                SmallSocialButton(socialType: .facebook)
                SmallSocialButton(socialType: .google)
            }
            
            HStack(spacing: 0) {
                Text("Don't have an account? ")
                    .font(.custom("Lato-Regular", size: 14))
                    .foregroundColor(.black.opacity(0.5))
                Button {
                    self.appState.path.append(.signup)
                } label: {
                    Text("Sign up")
                        .font(.custom("Lato-Regular", size: 14))
                        .foregroundColor(.black)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
        .background(Color.background)
        .overlay(alignment: .topLeading) {
            BackButton()
                .padding(20)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            print(self.appState.path)
        }
        .onChange(of: focusedField) { oldValue, newValue in
            print(oldValue)
            print(newValue)
        }
    }
}

struct LogInView_Previews: PreviewProvider {
    static let appState = AppState()
    static var previews: some View {
        LogInView()
            .environmentObject(appState)
    }
}
