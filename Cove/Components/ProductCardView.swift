//
//  ProductCardView.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/6/22.
//

import SwiftUI
import FirebaseFirestoreSwift
import FirebaseStorage

struct ProductCardView: View {
    var product: any Product
    var headerStr: String = "Header"
    var bodyStr: String = "Body"
    var price: Float = 9
    
    @State var favorited: Bool

    init(product: any Product) {
        self.product = product

//        print("ProductCardView init: \(String(describing: product.id)) favorite: \(String(describing: product.isFavorite))")
 
        self._favorited = State(initialValue: product.isFavorite ?? false)

        if let coffeeProduct = product as? CoffeeProduct {
            // product is a CoffeeProduct
            self.headerStr = coffeeProduct.info.roastery
            self.bodyStr = coffeeProduct.info.name
            self.price = coffeeProduct.defaultPrice
        } else if let musicProduct = product as? MusicProduct {
            // product is a MusicProduct
            self.headerStr = musicProduct.info.artist
            self.bodyStr = musicProduct.info.album
            self.price = musicProduct.defaultPrice
        } else if let apparelProduct = product as? ApparelProduct {
            // product is a ApparelProduct
            self.headerStr = apparelProduct.info.brand
            self.bodyStr = apparelProduct.info.name
            self.price = apparelProduct.defaultPrice
        }
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink(value: Path.product(product)) {
                VStack {
                    Rectangle()
                        .foregroundColor(.background)
                        .cornerRadius(8)
                        .overlay {
                            let imageURL = URL(string: product.defaultImageURL)
                            AsyncImage(url: imageURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                            
                        }
                    
                    VStack {
                        Text(headerStr)
                            .font(Font.custom("Poppins-SemiBold", size: 14))
                            .foregroundColor(.grey)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(bodyStr)
                            .font(Font.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.grey)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("$\(Int(self.price))")
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
                        .shadow(color: .dropShadow, radius: 20)
                }
                .frame(width: 160, height: 250)
            }
            .buttonStyle(PlainButtonStyle())
            
            LikeButton(enabled: self.favorited)
                .shadow(color: .dropShadow, radius: 20)
                .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 5))

        }
        
    }

//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            NavigationLink(destination: ProductDetailView(product: product)) {
//                VStack {
//                    Rectangle()
//                        .foregroundColor(.backgroundColor)
//                        .cornerRadius(8)
//                        .overlay {
//                            let imageURL = URL(string: product.defaultImageURL)
//                            AsyncImage(url: imageURL) { image in
//                                image
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                            } placeholder: {
//                                ProgressView()
//                            }
//
//                        }
//
//                    VStack {
//                        Text(headerStr)
//                            .font(Font.custom("Poppins-SemiBold", size: 14))
//                            .foregroundColor(.greyColor)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//
//                        Text(bodyStr)
//                            .font(Font.custom("Poppins-Regular", size: 14))
//                            .foregroundColor(.greyColor)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//
//                        Text("$" + String(self.price))
//                            .font(Font.custom("Poppins-Regular", size: 16))
//                            .fontWeight(.bold)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                    }
//                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 5))
//                }
//                .background(alignment: .bottom) {
//                    Rectangle()
//                        .frame(height: 160)
//                        .cornerRadius(8)
//                        .foregroundColor(.white)
//                        .shadow(color: .dropShadowColor, radius: 20)
//                }
//                .frame(width: 160, height: 250)
//            }
//            .buttonStyle(PlainButtonStyle())
//
//            LikeButton(enabled: self.favorited)
//                .shadow(color: .dropShadowColor, radius: 20)
//                .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 5))
//        }
//    }
}

//struct ProductCardView_Previews: PreviewProvider {
//
//    static let asset = UIImage(named: "WST-1011_2")
//
//    static let product = CoffeeItem(id: "12345aaaa", defaultPrice: 23, defaultImgPath: "item-images/WST-1011_2.jpeg", imgData: (asset?.jpegData(compressionQuality: 1))!, createdAt: .init(), sku: "SKUNO", categoryID: , info: <#T##CoffeeItem.Info#>)
////    static let item = CoffeeItem(id: "12345aaaa", brand: "Wonderstate Coffee", name: "Star Valley Decaf", price: 23, imgPath: "item-images/WST-1011_2.jpeg", imgData: (asset?.jpegData(compressionQuality: 1))!)
//
//
//    static var previews: some View {
//        ProductCardView(product: product)
////            .frame(maxWidth: 200, maxHeight: 200)
////            .previewLayout(.sizeThatFits)
//    }
//}
