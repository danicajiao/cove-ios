//
//  SplashView.swift
//  Cove
//
//  Created by Daniel Cajiao on 12/18/22.
//

import SwiftUI
import RiveRuntime

struct SplashView: View {
    var riveViewModel = RiveViewModel(
        fileName: "hero"
    )
    var body: some View {
        riveViewModel.view()
        Text("Splash View")
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
