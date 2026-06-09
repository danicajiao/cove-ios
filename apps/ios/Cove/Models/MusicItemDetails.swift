//
//  MusicItemDetails.swift
//
//  Created by Daniel Cajiao on 4/9/23.
//

import Foundation

struct MusicItemDetails: ItemDetails {
    var id: String?
    var about: String
    var categoryId: String
    var createdAt: Date?
    var itemId: String
    var description: String
    var tracklist: [Track]

    struct Track: Codable, Hashable {
        var durationSec: Int
        var title: String
    }
}
