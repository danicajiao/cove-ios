//
//  SplashView.swift
//  Cove
//
//  Created by Daniel Cajiao on 12/18/22.
//

import SwiftUI
import RiveRuntime

struct SplashView: View {
    var riveViewModel = RiveViewModel(fileName: "loading_indicator")
    
    var body: some View {
        ZStack {
            Color("NewColor")
                .ignoresSafeArea()
            riveViewModel.view()
                .frame(width: 172, height: 172)
                
            Image("cove")
                .offset(y: 250)
        }
        .ignoresSafeArea()
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
