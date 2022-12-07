//
//  CategoryButton.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/9/22.
//

import SwiftUI

struct CategoryButton: View {
    let category: String
    
    var body: some View {
        
        // TODO: Refactor category buttons to have less reused code
        // TODO: Correct text alignment
        switch category {
        case "Fruity":
            ZStack {
                Image("jocelyn-morales-YpvaFwddSoI-unsplash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(1.2)
                    .offset(x: 30, y: 2)
                Rectangle()
                    .foregroundColor(.fruityGradient)
                    .mask (
                        LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: UnitPoint(x: 0.4, y: 0), endPoint: UnitPoint(x: 0.5, y: 0))
                    )
                Text(category)
                    .font(Font.custom("Poppins-Regular", size: 16))
                    .offset(x: -32, y: 0)
            }
            .frame(width: 140, height: 65)
            .mask {
                Rectangle()
            }
            .cornerRadius(8)
        case "Choco":
            ZStack {
                Image("no-revisions-pLmTMF2Se7M-unsplash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(2.5)
                    .offset(x: 30, y: 0)
                Rectangle()
                    .foregroundColor(.chocoGradient)
                    .mask (
                        LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: UnitPoint(x: 0.4, y: 0), endPoint: UnitPoint(x: 0.5, y: 0))
                    )
                Text(category)
                    .font(Font.custom("Poppins-Regular", size: 14))
                    .offset(x: -32, y: 0)
            }
            .frame(width: 140, height: 65)
            .mask {
                Rectangle()
            }
            .cornerRadius(8)
        case "Citrus":
            ZStack {
                Image("am-jd-8du-1nR9OkM-unsplash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(1.4)
                    .offset(x: 30, y: -4)
                Rectangle()
                    .foregroundColor(.citrusGradient)
                    .mask (
                        LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: UnitPoint(x: 0.4, y: 0), endPoint: UnitPoint(x: 0.5, y: 0))
                    )
                Text(category)
                    .font(Font.custom("Poppins-Regular", size: 14))
                    .offset(x: -32, y: 0)
            }
            .frame(width: 140, height: 65)
            .mask {
                Rectangle()
            }
            .cornerRadius(8)
        case "Earthy":
            ZStack {
                Image("jocelyn-morales-uReASzIJDBs-unsplash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(1.0)
                    .offset(x: 30, y: 0)
                Rectangle()
                    .foregroundColor(.earthyGradient)
                    .mask (
                        LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: UnitPoint(x: 0.4, y: 0), endPoint: UnitPoint(x: 0.5, y: 0))
                    )
                Text(category)
                    .font(Font.custom("Poppins-Regular", size: 14))
                    .offset(x: -32, y: 0)
            }
            .frame(width: 140, height: 65)
            .mask {
                Rectangle()
            }
            .cornerRadius(8)
        default:
            ZStack {
                Image("michael-c-9qxNIXCg1Yw-unsplash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(1.7)
                    .offset(x: 35, y: -6)
                Rectangle()
                    .foregroundColor(.floralGradient)
                    .mask (
                        LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.55, y: 0))
                    )
                Text(category)
                    .font(Font.custom("Poppins-Regular", size: 14))
                    .offset(x: -32, y: 0)
            }
            .frame(width: 140, height: 65)
            .mask {
                Rectangle()
            }
            .cornerRadius(8)
        }
    }
}

struct CategoryButton_Previews: PreviewProvider {
    static var previews: some View {
        CategoryButton(category: "Preview")
            .previewLayout(.sizeThatFits)
    }
}
