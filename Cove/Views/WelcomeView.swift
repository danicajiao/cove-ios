//
//  WelcomeView.swift
//  Cove
//
//  Created by Daniel Cajiao on 12/7/22.
//

import FirebaseAuth
import SwiftUI

struct WelcomeView: View {
    
    @State var email = ""
    @State var password = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Cove")
                    .font(.custom("Getaway", size: 50))
                
                
                VStack(spacing: 0) {
                    Text("For the conscious")
                        .font(.custom("Poppins-SemiBold", size: 22))
                    Text("shopper")
                        .font(.custom("Poppins-SemiBold", size: 22))
                        .offset(x: 0, y: -5)
                }
                
                Image("splash-illustration")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc nec elit nec.")
                    .font(.custom("Poppins-Regular", size: 14))
                    .multilineTextAlignment(.center)
                
                NavigationLink(destination: HomeView()) {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .overlay {
                            Text("Login")
                                .font(.custom("Poppins-SemiBold", size: 14))
                                .foregroundColor(.white)
                        }
                }
                
                
                
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
                    NavigationLink(destination: EmptyView()) {
                        Circle()
                            .foregroundColor(.black)
                            .frame(width: 55, height: 55)
                            .overlay {
                                Image("apple")
                            }
                    }
                    NavigationLink(destination: EmptyView()) {
                        Circle()
                            .foregroundColor(Color(red: 0.376, green: 0.537, blue: 0.839))
                            .frame(width: 55, height: 55)
                            .overlay {
                                Image("facebook")
                            }
                    }
                    NavigationLink(destination: EmptyView()) {
                        Circle()
                            .foregroundColor(.white)
                            .frame(width: 55, height: 55)
                            .overlay {
                                Image("google")
                            }
                    }
                }
                
                HStack(spacing: 0) {
                    Text("Don't have an account? ")
                        .font(.custom("Poppins-Regular", size: 14))
                    // TODO: Add Link to SignUp View
                    NavigationLink(destination: EmptyView()) {
                        Text("Sign Up")
                            .font(.custom("Poppins-Regular", size: 14))
                    }
                    .foregroundColor(.gray)
                }
                
//                TextField("Email", text: $email)
//                    .textInputAutocapitalization(.never)
//                    .disableAutocorrection(true)
//                SecureField("Password", text: $password)
//                Button(action: { signup() }) {
//                    Text("Sign in")
//                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.backdropColor)
        }
    }

    func signup() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                print("user signed up successfully")
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
