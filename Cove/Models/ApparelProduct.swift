//
//  ApparelProduct.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/27/23.
//

import FirebaseFirestore

struct ApparelProduct: Product {
    @DocumentID var id: String?
    @ServerTimestamp var createdAt: Timestamp?
    var categoryID: String
    var defaultPrice: Float
    var defaultImageURL: String
    var info: ApparelInfo
    var isFavorite: Bool?
    var productDetailsID: String

    struct ApparelInfo : Codable {
        var brand: String
        var name: String
        var colors: [ColorInfo]
        
        struct ColorInfo : Codable {
            var color: String
            var imageURL: String
            var price: Float
            var sizes: [SizeInfo]
            
            struct SizeInfo: Codable {
                var inventoryID: String
                var size: String
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ApparelProduct, rhs: ApparelProduct) -> Bool {
        return lhs.id == rhs.id
    }
}
