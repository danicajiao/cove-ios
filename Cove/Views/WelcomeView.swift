//
//  WelcomeView.swift
//  Cove
//
//  Created by Daniel Cajiao on 12/7/22.
//

import SwiftUI
import FirebaseAuth
import RiveRuntime


struct WelcomeView: View {
    @EnvironmentObject private var appState: AppState
    var riveViewModel = RiveViewModel(
        fileName: "hero",
        alignment: .topCenter
    )
    
    var body: some View {
        VStack(spacing: 20) {
            riveViewModel.view()
            
            Spacer()
            
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("For the conscious")
                        .font(.custom("gazpacho-black", size: 30))
                    Text("shopper")
                        .font(.custom("gazpacho-black", size: 30))
                    Text("Cove.")
                        .font(.custom("gazpacho-black", size: 60))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    self.appState.path.append(.login)
                } label: {
                    Text("Login")
                }
                .buttonStyle(PrimaryButton())
                
                Button {
                    self.appState.path.append(.signup)
                } label: {
                    Text("Join for free")
                }
                .buttonStyle(SecondaryButton())
            }
            .frame(maxWidth: .infinity)
            .padding(20)
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            print(self.appState.path)
        }
        .background(Color("NewColor"))
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static let appState = AppState()
    
    static var previews: some View {
        WelcomeView()
            .environmentObject(appState)
    }
}
