//
//  BannerButton.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/9/22.
//

import SwiftUI

struct BannerButton: View {
    let bannerType: Int
    
    var body: some View {
        switch bannerType {
        case 1:
            Image("coffee-subscription-2048px-3198-3x2-1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 148)
                .overlay {
                    GeometryReader { geometry in
                        VStack {
                            VStack(alignment: .leading) {
                                Text("Select craft roasters")
                                    .font(Font.custom("Gazpacho-Bold", size: 12))
                                    .foregroundStyle(.textPrimary)
                                    .frame(width: 70, alignment: .leading)
                                
                                Spacer()
                                
                                HStack(alignment: .center) {
                                    Text("40%")
                                        .font(Font.custom("Gazpacho-Black", size: 34))
                                    Text("off")
                                        .font(Font.custom("Gazpacho-Bold", size: 14))
                                }
                                .foregroundStyle(.textPrimary)
                                
                                Spacer()
                                
                                Text("See all items \(Image(systemName: "arrow.right"))")
                                    .font(Font.custom("Lato-Regular", size: 10))
                                    .foregroundStyle(.textPrimary)
                                
                            }
                            .padding(14)
                            .frame(width: geometry.size.height - (11 * 2), height: geometry.size.height - (11 * 2))
                            .background(.white)
                            .cornerRadius(8)
                        }
                        .frame(width: geometry.size.height, height: geometry.size.height)
                    }
                }
                .cornerRadius(12)
                .customShadow()
        default:
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text("New")
                        .font(Font.custom("Gazpacho-Black", size: 36))
                    Text("Stumpton Huye Mountain")
                        .font(Font.custom("Lato-Regular", size: 14))
                }
                .foregroundStyle(.textPrimary)
                .frame(maxWidth: .infinity)
                
                Image("How-To-Store-Coffee-Beans-Gear-Patrol-Lead-Full")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150)
                    .clipped()
            }
            .frame(height: 120)
            .background(.white)
            .cornerRadius(12)
            .customShadow()
        }
    }
}

struct BannerButton_Previews: PreviewProvider {
    static var previews: some View {
        BannerButton(bannerType: 1)
            .padding(.horizontal, 20)
            .previewLayout(.sizeThatFits)
        
        BannerButton(bannerType: 2)
            .padding(.horizontal, 20)
            .previewLayout(.sizeThatFits)
    }
}
