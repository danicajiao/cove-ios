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
    
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Cove")
                .font(.custom("Getaway", size: 50))
            
            VStack(spacing: 0) {
                Text("Login")
                    .font(.custom("Poppins-SemiBold", size: 18))
            }
            
            Image("login-illustration")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Group {
                VStack(spacing: 15) {
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "person.fill")
                            TextField("Email", text: $email)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                        }
                        
                        Color.black.frame(height: 2)
                    }
                    
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "lock.fill")
                            SecureField("Password", text: $password)
                        }
                        
                        Color.black.frame(height: 2)
                    }
                }
            }
            
            Button {
                self.appState.emailLogIn(email: self.email, password: self.password, onFailure: { error in
                    print("onFailure: email login failure")
                    self.presentAlert = true
                    self.errorMessage = error?.localizedDescription
                }, onSuccess: {
                    print("onSuccess: user logged in successfully")
                    self.appState.path.append(.main)
                    self.email = ""
                    self.password = ""
                })
            } label: {
                Text("Log in")
            }
            .buttonStyle(PrimaryButton())
            
//            NavigationLink(destination: HomeView()) {
//                RoundedRectangle(cornerRadius: 10)
//                    .foregroundColor(.black)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 55)
//                    .overlay {
//                        Text("Login")
//                            .font(.custom("Poppins-SemiBold", size: 14))
//                            .foregroundColor(.white)
//                    }
//            }
            
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
                Text("Don't have an account? ")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.gray)
                // TODO: Add Link to SignUp View
                NavigationLink(destination: EmptyView()) {
                    Text("Sign Up")
                        .font(.custom("Poppins-Regular", size: 14))
                }
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backdropColor)
        .alert(isPresented: $presentAlert) {
            Alert(
                title: Text("Verify login"),
                message: Text(self.errorMessage ?? "")
            )
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    _ = self.appState.path.popLast()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .onAppear {
            print(self.appState.path)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
