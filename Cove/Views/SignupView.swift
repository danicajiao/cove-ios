//
//  SignupView.swift
//  Cove
//
//  Created by Daniel Cajiao on 1/1/23.
//

import SwiftUI
import FirebaseAuth

struct SignupView: View {
    @EnvironmentObject private var appState: AppState
    
    @State private var presentAlert = false
    @State private var errorMessage: String? = nil
        
    @State var email: String = ""
    @State var password: String = ""
    @State var loading: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 20) {
                Text("Cove.")
                    .font(.custom("Gazpacho-Heavy", size: 40))
                    .foregroundStyle(Color(.Colors.Fills.primary))
                
                SpectrumDivider()
                
                Group {
                    Text("Create your account")
                        .font(.custom("Lato-Bold", size: 28))
                        .foregroundStyle(Color(.Colors.Fills.primary))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 4) {
                        CustomTextField(
                            placeholder: "email@provider.com",
                            text: $email,
                            returnKeyType: .next,
                            autocapitalizationType: UITextAutocapitalizationType.none,
                            keyboardType: .emailAddress,
                            textContentType: .username,
                            label: "Email",
                            tag: 0
                        )
                        CustomTextField(
                            placeholder: "Password",
                            text: $password,
                            isSecureTextEntry: true,
                            returnKeyType: .done,
                            keyboardType: .default,
                            textContentType: .password, // update to .newPassword once enrolled in ADP
                            label: "Password",
                            tag: 1
                        )
                        HStack {
                            Text("Passwords must contain at least 8 characters.")
                                .font(.custom("Lato-Regular", size: 14))
                                .foregroundStyle(Color(.Colors.Fills.tertiary))
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                    }
                }
                
                VStack(spacing: 10) {
                    Button {
                        loading = true
                        self.appState.emailLogIn(email: self.email, password: self.password,
                                                 onFailure: { error in
                            self.presentAlert = true
                            self.errorMessage = error?.localizedDescription
                            loading = false
                        }, onSuccess: {
                            // onSuccess work here
                            loading = false
                        })
                    } label: {
                        if !loading {
                            Text("Sign Up")
                        } else {
                            ProgressView()
                                .tint(.white)
                        }
                    }
                    .buttonStyle(PrimaryButton())
                    .alert(isPresented: $presentAlert) {
                        Alert(title: Text("Login Failed"), message: Text(self.errorMessage ?? "Missing error message"), dismissButton: .default(Text("OK")))
                    }
                    
                    HStack {
                        Text("By signing up, you are agreeing to our Terms of Service. View our Privacy Policy.")
                            .font(.custom("Lato-Regular", size: 14))
                            .foregroundStyle(Color(.Colors.Fills.tertiary))
                    }
                    .padding(.horizontal, 10)
                }
                
                HStack {
                    Capsule()
                        .fill(Color(.Colors.Fills.quaternary))
                        .frame(height: 2)
                        .padding(.leading, 60)
                        .padding(.trailing)
                    Text("OR")
                        .font(.custom("Lato-Regular", size: 12))
                        .foregroundStyle(Color(.Colors.Fills.quaternary))
                    Capsule()
                        .fill(Color(.Colors.Fills.quaternary))
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
                    Text("Already have an email? ")
                        .font(.custom("Lato-Regular", size: 14))
                        .foregroundStyle(Color(.Colors.Fills.tertiary))
                    Button {
                        self.appState.path.append(.login)
                    } label: {
                        Text("Log In")
                            .font(.custom("Lato-Regular", size: 14))
                            .foregroundStyle(Color(.Colors.Fills.primary))
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(20)
            .background(Color(.Colors.Backgrounds.primary))
            .overlay(alignment: .topLeading) {
                BackButton()
                    .padding(20)
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                print(self.appState.path)
            }
            .onDisappear {
                self.email = ""
                self.password = ""
            }
            .contentShape(Rectangle()) // Makes the entire view tappable
            .onTapGesture {
                // Dismiss the keyboard
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .all)
    }
}

struct SignupView_Previews: PreviewProvider {
    static let appState = AppState()
    static var previews: some View {
        SignupView()
            .environmentObject(appState)
    }
}

