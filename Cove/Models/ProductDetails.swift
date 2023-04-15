//
//  ProductDetails.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/9/23.
//

import FirebaseFirestore

protocol ProductDetails : Codable {
    var id: String? { get }
    var categoryID: String { get }
    var createdAt: Timestamp? { get }
    var productID: String { get }
}
