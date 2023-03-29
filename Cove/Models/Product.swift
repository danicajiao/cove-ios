//
//  Product.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/8/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

protocol Product : Codable, Identifiable {
//    @Published var imgData: Data = Data()
//    @Published var favorited = false
    
    var id: String? { get }
    var createdAt: Timestamp? { get }
    var categoryID: String { get }
    var defaultPrice: Float { get }
    var defaultImageURL: String { get }
    var isFavorite: Bool? { get set }
    
//    associatedtype CodingKeys: RawRepresentable where CodingKeys.RawValue: StringProtocol
    
//    init(from decoder: Decoder) throws
    
//    init(defaultPrice: Float, defaultImgPath: String, createdAt: Timestamp, imgData: Data) {
//        self.defaultPrice = defaultPrice
//        self.defaultImgPath = defaultImgPath
//        self.createdAt = createdAt
//        self.imgData = imgData
//    }
    
//    // This initializer is used for previews
//    init(defaultPrice: Float, defaultImgPath: String, imgData: Data, createdAt: Timestamp) {
//        self.defaultPrice = defaultPrice
//        self.defaultImgPath = defaultImgPath
//        self.imgData = imgData
//        self.createdAt = createdAt
//    }
}
