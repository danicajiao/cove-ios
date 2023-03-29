//
//  FavoriteProduct.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/21/23.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct FavoriteProduct : Codable, Identifiable {
    @DocumentID var id: String?
    var productID: String
}
