//
//  MusicProduct.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/6/23.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct MusicProduct: Product {
    @DocumentID var id: String?
    @ServerTimestamp var createdAt: Timestamp?
    var categoryID: String
    var defaultPrice: Float
    var defaultImageURL: String
    var info: MusicInfo
    var isFavorite: Bool?

    struct MusicInfo : Codable {
        var artist: String
        var album: String
        var formats: [FormatInfo]
        
        struct FormatInfo : Codable {
            var format: String
            var imageURL: String
            var price: Float
        }
    }
}
