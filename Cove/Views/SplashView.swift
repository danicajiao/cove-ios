//
//  SplashView.swift
//  Cove
//
//  Created by Daniel Cajiao on 12/18/22.
//

import SwiftUI
import FirebaseAuth

struct SplashView: View {
//    @EnvironmentObject var appState: AppState
    
    var body: some View {
        
        GeometryReader { geo in
            ZStack {
                Image("splash")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: geo.size.width)
                    .ignoresSafeArea()
                Text("Cove")
                    .font(.custom("Getaway", size: 80))
                    .foregroundStyle(.white)
            }
        }
        
//        ZStack {
//            VStack {
//                Spacer()
//                Image("splash-illustration")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(height: 350)
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.backdropColor)
//            .ignoresSafeArea(.all, edges: .bottom)
//            
//            Text("Cove")
//                .font(.custom("Getaway", size: 80))
//        }
//        .onAppear {
//            print(self.appState.path)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                guard Auth.auth().currentUser != nil else {
//                    self.appState.path.append(.welcome)
//                    return
//                }
////                self.appState.path.append(.welcome)
//                self.appState.path.append(.main)
//            }
//        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
