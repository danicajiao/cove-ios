//
//  Brand.swift
//
//  Created by Daniel Cajiao on 3/28/23.
//

import Foundation

struct Brand: Codable, Identifiable {
    var id: String?
    var createdAt: Date?
    var name: String
    var imageURL: String
}
