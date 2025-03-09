//
//  BannerButton.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/9/22.
//

import SwiftUI

struct BannerButton: View {
    let bannerType: Int
    
//    init(bannerType: Int) {
//        self.bannerType = bannerType
//        print("Banner init")
//    }
    
    var body: some View {
        
        switch bannerType {
        case 1:
            Image("coffee-subscription-2048px-3198-3x2-1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxHeight: 160)
                .cornerRadius(8)
                .clipped()
                .overlay {
                    GeometryReader { geometry in
                        ZStack {
                            Rectangle()
                                .background(.ultraThinMaterial)
                                .foregroundColor(.clear)
                                .cornerRadius(8)

                            VStack {
                                Text("Select craft roasters")
                                    .font(Font.custom("Poppins-Regular", size: 14))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                HStack(alignment: .firstTextBaseline) {
                                    Text("70%")
                                        .font(Font.custom("Poppins-Semibold", size: 36))
                                    Text("off")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Text("See all items \(Image(systemName: "arrow.right"))")
                                    .font(Font.custom("Poppins-Regular", size: 12))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .foregroundColor(.blue)
                            .padding(10)
                        }
                        .padding(10)
                        .frame(maxWidth: geometry.size.height, maxHeight: geometry.size.height)
                    }
                }
        default:
            ZStack {
                Image("How-To-Store-Coffee-Beans-Gear-Patrol-Lead-Full")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(1.1)
                    .offset(x: 100, y: 0)
                
                Rectangle()
                    .foregroundColor(.bannerGradient)
                    .mask (
                        LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: UnitPoint(x: 0.55, y: 0), endPoint: UnitPoint(x: 0.6, y: 0))
                    )
                
                VStack(alignment: .leading) {
                    Text("New")
                        .font(Font.custom("Poppins-Semibold", size: 36))
                        .foregroundColor(.accent)
                    Text("Stumpton Huye Mountain")
                        .font(Font.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.accent)
                }
                .offset(x: -70, y: 0)
            }
            .frame(maxHeight: 114)
            .mask {
                Rectangle()
            }
            .cornerRadius(8)
        }
    }
}

struct BannerButton_Previews: PreviewProvider {
    static var previews: some View {
        BannerButton(bannerType: 1)
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            .previewLayout(.sizeThatFits)
        
        BannerButton(bannerType: 2)
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            .previewLayout(.sizeThatFits)
    }
}
