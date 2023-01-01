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
            
            HStack(spacing: 30) {
                SocialButton(socialType: .apple)
                SocialButton(socialType: .facebook)
                SocialButton(socialType: .google)
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
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backdropColor)
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