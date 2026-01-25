//
//  SectionHeader.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/21/25.
//

import SwiftUI

struct SectionHeader: View {
    var title: String
    var body: some View {
        HStack {
            Text(title)
                .font(Font.custom("Lato-Bold", size: 20))
            Spacer()
            Button {
                // TODO: Navigate to Categories View
            } label: {
                HStack {
                    Text("See all")
                        .font(Font.custom("Lato-Regular", size: 14))
                    Image(systemName: "arrow.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14)
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

#Preview {
    SectionHeader(title: "Preview")
}
