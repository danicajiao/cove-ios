//
//  SmallCategoryButton.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/21/25.
//

import SwiftUI

struct SmallCategoryButton: View {
    let category: String
    
    var body: some View {
        switch category {
        case "Music":
            Rectangle()
                .overlay {
                    Image("727a7238365525.576d3001c7656 2")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaleEffect(1.5, anchor: .leading)
                }
                .overlay(alignment: .topLeading) {
                    Text(category)
                        .font(Font.custom("Gazpacho-Black", size: 14))
                        .padding(10)
                }
                .frame(width: 130, height: 60)
                .cornerRadius(8)
                .customShadow()
        case "Coffee":
            Rectangle()
                .overlay {
                    Image("coffee-subscription-2048px-3198-3x2-1")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaleEffect(2.5, anchor: .top)
                }
                .overlay(alignment: .topLeading) {
                    Text(category)
                        .font(Font.custom("Gazpacho-Black", size: 14))
                        .padding(10)
                }
                .frame(width: 130, height: 60)
                .cornerRadius(8)
                .customShadow()
        case "Home":
            Rectangle()
                .foregroundColor(.clear)
                .overlay {
                    Image("6a24c9162480919.63d6b3eceb963")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaleEffect(1.8, anchor: UnitPoint(x: 0.65, y: 0.42))
                }
                .overlay(alignment: .topLeading) {
                    Text(category)
                        .font(Font.custom("Gazpacho-Black", size: 14))
                        .padding(8)
                }
                .frame(width: 130, height: 60)
                .cornerRadius(10)
                .customShadow()
        case "Bevs":
            Rectangle()
                .overlay {
                    Color(UIColor(red: 255/255, green: 252/255, blue: 247/255, alpha: 1))
                    Image("58533a99308279.5ef03e3c0da5a")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .rotationEffect(.degrees(45))
                        .offset(x: 35)
                }
                .overlay(alignment: .topLeading) {
                    Text(category)
                        .font(Font.custom("Gazpacho-Black", size: 14))
                        .padding(10)
                }
                .frame(width: 130, height: 60)
                .cornerRadius(8)
                .customShadow()
        default:
            Rectangle()
                .foregroundColor(.clear)
                .overlay {
                    Image("817b69111912037.600a933bbd858")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaleEffect(1.5, anchor: UnitPoint(x: 0, y: 0.1))
                }
                .overlay(alignment: .topLeading) {
                    Text(category)
                        .font(Font.custom("Gazpacho-Black", size: 14))
                        .padding(10)
                }
                .frame(width: 130, height: 60)
                .cornerRadius(8)
                .customShadow()
        }
    }
}

#Preview {
    SmallCategoryButton(category: "Preview")
}
