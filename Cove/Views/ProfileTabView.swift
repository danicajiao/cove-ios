//
//  ProfileTabView.swift
//  Cove
//
//  Created by Daniel Cajiao on 12/17/22.
//

import SwiftUI

struct ProfileTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var presentAlert = false

    var body: some View {
        VStack {
            Text("Profile View")
            Button {
                presentAlert = true
            } label: {
                Text("Log out")
            }
        }
        .confirmationDialog("Confirm Log Out", isPresented: $presentAlert) {
            Button("Log out", role: .destructive) {
                self.appState.logOut()
                self.appState.path.removeAll()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
}

struct ProfileTabView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileTabView()
    }
}
