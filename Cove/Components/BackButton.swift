//
//  BackButton.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/7/25.
//

import SwiftUI

struct BackButton: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        Button {
            _ = self.appState.path.popLast()
        } label: {
            Circle()
                .fill(.white)
                .strokeBorder(.black, lineWidth: 1)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.black)
                }
        }
    }
}

#Preview {
    BackButton()
}
