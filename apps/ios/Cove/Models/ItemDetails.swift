//
//  ItemDetails.swift
//
//  Created by Daniel Cajiao on 4/9/23.
//

import Foundation

protocol ItemDetails: Codable {
    var id: String? { get }
    var categoryId: String { get }
    var createdAt: Date? { get }
    var itemId: String { get }
}
