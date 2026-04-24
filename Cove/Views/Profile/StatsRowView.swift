//
//  StatsRowView.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/15/26.
//

import SwiftUI

struct StatsRowView: View {
    var orders: Int = 0
    var followers: Int = 0
    var following: Int = 0

    var body: some View {
        HStack(spacing: 12) {
            StatBox(count: orders, label: "Orders")
            StatBox(count: followers, label: "Followers")
            StatBox(count: following, label: "Following")
        }
    }
}

private struct StatBox: View {
    let count: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(Font.custom("Lato-Bold", size: 18))
                .foregroundStyle(Color.Colors.Fills.primary)

            Text(label)
                .font(Font.custom("Lato-Regular", size: 12))
                .foregroundStyle(Color.Colors.Fills.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16) // spacing/lg
        .background(Color.Colors.Backgrounds.secondary)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.Colors.Strokes.primary, lineWidth: 1)
        }
    }
}

struct StatsRowView_Previews: PreviewProvider {
    static var previews: some View {
        StatsRowView(orders: 0, followers: 0, following: 0)
            .padding(.horizontal, 20)
            .background(Color.Colors.Backgrounds.primary)
    }
}
