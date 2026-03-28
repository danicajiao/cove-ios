//
//  WelcomeView.swift
//  Cove
//
//  Created by Daniel Cajiao on 12/7/22.
//

import FirebaseAuth
import RiveRuntime
import SwiftUI

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

            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("A new way to shop local")
                        .font(.custom("Gazpacho-Bold", size: 30))
                        .foregroundStyle(Color.Colors.Fills.primary)
                        .containerRelativeFrame(.horizontal, count: 2, span: 1, spacing: 0)
                    Text("Cove.")
                        .font(.custom("Gazpacho-Heavy", size: 60))
                        .foregroundStyle(Color.Colors.Fills.primary)
                }

                Button {
                    appState.path.append(.signup)
                } label: {
                    Text("Join for free")
                }
                .buttonStyle(PrimaryButton())

                Button {
                    appState.path.append(.login)
                } label: {
                    Text("Login")
                }
                .buttonStyle(SecondaryButton())
            }
            .padding(20)
        }
        .ignoresSafeArea(edges: .top)
        .background(Color.Colors.Backgrounds.primary)
        .onAppear {
            print(appState.path)
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static let appState = AppState()

    static var previews: some View {
        WelcomeView()
            .environmentObject(appState)
    }
}
