//
//  ItemCardView.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/6/22.
//

import SwiftUI
import FirebaseStorage

struct ItemCardView: View {
    @StateObject var item: Item
    @EnvironmentObject var tabState: TabState
//    @State private var rectHeight = CGFloat.random(in: 150...180)
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink(destination: ItemView(item: item)) {
                VStack {
                    Image(uiImage: UIImage(data: item.imgData) ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    VStack {
                        Text(item.name)
                            .font(Font.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.secondaryColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("$" + String(item.price))
                            .font(Font.custom("Poppins-Regular", size: 16))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 5))
                }
                .background(alignment: .bottom) {
                    Rectangle()
                        .frame(height: 160)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .shadow(color: .dropShadowColor, radius: 20)
                }
                .frame(width: 160, height: 250)
            }
            .buttonStyle(PlainButtonStyle())
            
            LikeButton(enabled: $item.favorited)
                .shadow(color: .dropShadowColor, radius: 20)
            
        }
    }
}

struct ItemCardView_Previews: PreviewProvider {
    
    static let asset = UIImage(named: "WST-1011_2")
    
    static let item = Item(id: "12345aaaa", brand: "Wonderstate Coffee", name: "Star Valley Decaf", price: 23, imgPath: "item-images/WST-1011_2.jpeg", imgData: (asset?.jpegData(compressionQuality: 1))!)
    
    
    static var previews: some View {
        ItemCardView(item: item)
//            .frame(maxWidth: 200, maxHeight: 200)
//            .previewLayout(.sizeThatFits)
    }
}
