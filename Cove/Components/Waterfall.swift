//
//  Waterfall.swift
//  Cove
//
//  Created by Daniel Cajiao on 5/5/22.
//

import SwiftUI
import WaterfallGrid
import FirebaseStorage

struct Waterfall: View {
    let items = [Item(id: "12345a", brand: "Wonderstate Coffee", name: "Star Valley Decaf", price: 23.0, imgPath: "item-images/WST-1011_2.jpeg"),
                 Item(id: "12345aa", brand: "Wonderstate Coffee", name: "Star Valley Decaf", price: 23.0, imgPath: "item-images/OLY-1048_2.jpeg"),
                 Item(id: "12345aaa", brand: "Wonderstate Coffee", name: "Star Valley Decaf", price: 23.0, imgPath: "item-images/RTL-1015_2.jpeg"),
                 Item(id: "12345aaaa", brand: "Wonderstate Coffee", name: "Star Valley Decaf", price: 23.0, imgPath: "item-images/BDWN-1108.jpeg")]

//    var body: some View {
//        LazyVGrid(columns: <#T##[GridItem]#>, content: <#T##() -> _#>)
//    }
    
    private var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 100, maximum: 300), spacing: 0),
        GridItem(.adaptive(minimum: 100, maximum: 300), spacing: 0),
        ]

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: columns,
                alignment: .center,
                spacing: 20,
                pinnedViews: [.sectionHeaders, .sectionFooters]
            ) {
                ForEach(items) { item in
                    ItemCardView(item: item)
                }
            }
        }
    }
}

struct Waterfall_Previews: PreviewProvider {
    static var previews: some View {
        Waterfall()
    }
}
