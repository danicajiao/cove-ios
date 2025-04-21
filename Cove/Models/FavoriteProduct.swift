//
//  FavoriteProduct.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/21/23.
//

import FirebaseFirestore

struct FavoriteProduct : Codable, Identifiable {
    @DocumentID var id: String?
    var productID: String
}
