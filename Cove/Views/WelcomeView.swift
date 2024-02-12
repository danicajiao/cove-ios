//
//  WelcomeView.swift
//  Cove
//
//  Created by Daniel Cajiao on 12/7/22.
//

import SwiftUI
import FirebaseAuth


struct WelcomeView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Cove")
                .font(.custom("Getaway", size: 60))
            
            Spacer()
            
            VStack(spacing: 0) {
                Text("For the conscious")
                    .font(.custom("Poppins-SemiBold", size: 25))
                Text("shopper")
                    .font(.custom("Poppins-SemiBold", size: 25))
                    .offset(x: 0, y: -5)
            }
            
            Text("Login with credentials or with an external provider")
                .font(.custom("Poppins-Regular", size: 15))
                .multilineTextAlignment(.center)
            
//            NavigationLink(value: Path.login) {
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
            
            Button {
                self.appState.path.append(.login)
            } label: {
                Text("Login")
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
//                NavigationLink(destination: EmptyView()) {
//                    Text("Sign Up")
//                        .font(.custom("Poppins-Regular", size: 14))
//                }
                Button {
                    self.appState.path.append(.signup)
                } label: {
                    Text("Sign up")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.black)
                }
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image("welcome-background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            print(self.appState.path)
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
