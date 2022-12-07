//
//  OriginButton.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/11/22.
//

import SwiftUI

struct OriginButton: View {
    let origin: String
    
    var body: some View {
        switch origin {
        case "Colombia":
            Rectangle()
                .foregroundColor(.clear)
                .overlay {
                    Image("coffee-origin-colombia")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaleEffect(1.3)
                        .offset(x: 100, y: -30)
                }
                .overlay(alignment: .topLeading) {
                    Text(origin)
                        .font(Font.custom("Poppins-Regular", size: 14))
                        .padding(10)
                }
                .frame(width: 140, height: 200)
                .cornerRadius(8)
        case "Guatemala":
            Rectangle()
                .foregroundColor(.clear)
                .overlay {
                    Image("coffee-origin-guatemala")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .offset(x: -20, y: 0)
                }
                .overlay(alignment: .topLeading) {
                    Text(origin)
                        .font(Font.custom("Poppins-Regular", size: 14))
                        .padding(10)
                }
                .frame(width: 140, height: 200)
                .cornerRadius(8)
        case "Ethiopia":
            Rectangle()
                .foregroundColor(.clear)
                .overlay {
                    Image("coffee-origin-ethiopia")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .offset(x: -100, y: 0)
                }
                .overlay(alignment: .topLeading) {
                    Text(origin)
                        .font(Font.custom("Poppins-Regular", size: 14))
                        .padding(10)
                }
                .frame(width: 140, height: 200)
                .cornerRadius(8)
        case "Costa Rica":
            Rectangle()
                .foregroundColor(.clear)
                .overlay {
                    Image("coffee-origin-costa-rica")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .offset(x: -35, y: 0)
                }
                .overlay(alignment: .topLeading) {
                    Text(origin)
                        .font(Font.custom("Poppins-Regular", size: 14))
                        .padding(10)
                }
                .frame(width: 140, height: 200)
                .cornerRadius(8)
        default:
            Rectangle()
                .foregroundColor(.clear)
                .overlay {
                    Image("coffee-origin-kenya")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaleEffect(1.1)
                        .offset(x: 0, y: -10)
                }
                .overlay(alignment: .topLeading) {
                    Text(origin)
                        .font(Font.custom("Poppins-Regular", size: 14))
                        .padding(10)
                }
                .frame(width: 140, height: 200)
                .cornerRadius(8)
        }
    }
}

struct OriginButton_Previews: PreviewProvider {
    static var previews: some View {
        OriginButton(origin: "Preview")
            .previewLayout(.sizeThatFits)
    }
}
