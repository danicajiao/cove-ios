//
//  SignUpView.swift
//  Cove
//
//  Created by Daniel Cajiao on 1/1/23.
//

import SwiftUI

private enum Field: Hashable {
    case email
    case password
}

struct SignUpView: View {
    @EnvironmentObject private var appState: AppState
    
    @State private var presentAlert = false
    @State private var errorMessage: String? = nil
    
    enum Field: Hashable {
            case email
            case password
        }
    
    @FocusState var focusedField: Field?
    @State var showImage: Bool = true
    
    @State var email = ""
    @State var password = ""
    
    var body: some View {
//        let _ = Self._printChanges()

        VStack(spacing: 20) {
            Text("Cove")
                .font(.custom("Getaway", size: 50))
            
            VStack(spacing: 0) {
                Text("Sign Up")
                    .font(.custom("Poppins-SemiBold", size: 18))
            }
            
            if (showImage == true) {
                Image("signup-illustration")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            
            Group {
                VStack(spacing: 15) {
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "person.fill")
                            TextField("Email", text: $email)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .focused($focusedField, equals: .email)
                        }
                        
                        Color.black.frame(height: 2)
                    }
                    
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "lock.fill")
                            SecureField("Password", text: $password)
                                .focused($focusedField, equals: .password)
                        }
                        
                        Color.black.frame(height: 2)
                    }
                }
                .onChange(of: focusedField) { focusedField in
                    if focusedField != nil {
                        withAnimation {
                            showImage = false
                        }
                    }
                }
            }
            
            Button {
                self.appState.emailSignUp(email: self.email, password: self.password, onFailure: { error in
                    self.presentAlert = true
                    self.errorMessage = error?.localizedDescription
                }, onSuccess: {
                    self.email = ""
                    self.password = ""
                })
            } label: {
                Text("Sign up")
            }
            .buttonStyle(PrimaryButton(width: .infinity))
            
            HStack {
                Color.black.frame(height: 1)
                    .padding(.leading, 60)
                    .padding(.trailing)
                Text("or")
                    .font(.custom("Poppins-Regular", size: 14))
                Color.black.frame(height: 1)
                    .padding(.trailing, 60)
                    .padding(.leading)
            }
            
            // TODO: Add Links to Social Provider Views
            HStack(spacing: 30) {
                SocialButton(socialType: .apple)
                SocialButton(socialType: .facebook)
                SocialButton(socialType: .google)
            }
            
            HStack(spacing: 0) {
                Text("Already have an account? ")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.gray)
                Button {
                    self.appState.path.append(.login)
                } label: {
                    Text("Log in")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.black)
                }
            }
        }
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backdropColor)
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .topLeading) {
            Button {
                _ = self.appState.path.popLast()
            } label: {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.black)
                    .opacity(0.2)
                    .overlay {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                    .padding(10)
            }
        }
        .alert(isPresented: $presentAlert) {
            Alert(
                title: Text("Verify login"),
                message: Text(self.errorMessage ?? "")
            )
        }
        .onAppear {
            print(self.appState.path)
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
