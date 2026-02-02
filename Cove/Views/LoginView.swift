//
//  LoginView.swift
//  Cove
//
//  Created by Daniel Cajiao on 12/16/22.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
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
                    .foregroundStyle(.textPrimary)
                
                SpectrumDivider()
                
                Group {
                    Text("Log in to your account")
                        .font(.custom("Lato-Bold", size: 28))
                        .foregroundStyle(.textPrimary)
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
                            textContentType: .password,
                            label: "Password",
                            tag: 1
                        )
                        HStack {
                            Button {
                                print("TODO: nav to forgot password view")
                            } label: {
                                Text("Forgot password?")
                                    .font(.custom("Lato-Regular", size: 14))
                                    .underline()
                                    .foregroundStyle(.black.opacity(0.5))
                            }
                            Spacer()
                            Button {
                                print("TODO: auth with Face ID")
                            } label: {
                                Text("Face ID \(Image(systemName: "faceid"))")
                                    .font(.custom("Lato-Regular", size: 16))
                                    .foregroundStyle(.black.opacity(0.5))
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                }
                
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
                        Text("Log In")
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
                    Capsule()
                        .fill(.gray.opacity(0.5))
                        .frame(height: 2)
                        .padding(.leading, 60)
                        .padding(.trailing)
                    Text("OR")
                        .font(.custom("Lato-Regular", size: 12))
                        .foregroundStyle(.black.opacity(0.5))
                    Capsule()
                        .fill(.gray.opacity(0.5))
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
                        .foregroundStyle(.black.opacity(0.5))
                    Button {
                        self.appState.path.append(.signup)
                    } label: {
                        Text("Sign up")
                            .font(.custom("Lato-Regular", size: 14))
                            .foregroundColor(.textPrimary)
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .background(Color.backgroundPrimary.ignoresSafeArea(.all))
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
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct LoginView_Previews: PreviewProvider {
    static let appState = AppState()
    static var previews: some View {
        LoginView()
            .environmentObject(appState)
    }
}
