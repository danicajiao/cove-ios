//
//  Product.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/8/22.
//

import FirebaseFirestore

protocol Product : Codable, Identifiable, Hashable {
//    @Published var imgData: Data = Data()
//    @Published var favorited = false
    
    var id: String? { get }
    var createdAt: Timestamp? { get }
    var categoryID: String { get }
    var defaultPrice: Float { get }
    var defaultImageURL: String { get }
    var isFavorite: Bool? { get set }
    var productDetailsID: String { get }
}

struct ExampleProduct: Product {
    @DocumentID var id: String?
    @ServerTimestamp var createdAt: Timestamp?
    var categoryID: String
    var defaultPrice: Float
    var defaultImageURL: String
    var info: ExampleInfo
    var isFavorite: Bool?
    var productDetailsID: String
    
    struct ExampleInfo : Codable {
        var name: String
        var desc: String
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ExampleProduct, rhs: ExampleProduct) -> Bool {
        return lhs.id == rhs.id
    }

    static let placeholder = ExampleProduct(
        id: "aaaaa123445",
        createdAt: Timestamp.init(),
        categoryID: "some categoryID",
        defaultPrice: 23,
        defaultImageURL: "some url",
        info: ExampleInfo(name: "Some name", desc: "Some description"),
        isFavorite: true,
        productDetailsID: "12345"
    )
}
