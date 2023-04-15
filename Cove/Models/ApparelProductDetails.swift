//
//  ApparelProductDetails.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/11/23.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct ApparelProductDetails : ProductDetails {
    @DocumentID var id: String?
    var about: String
    var categoryID: String
    @ServerTimestamp var createdAt: Timestamp?
    var productID: String
    var description: String
    var specifications: [Specification]
    
    struct Specification : Codable, Hashable {
        var content: [String]
        var title: String
    }
}
