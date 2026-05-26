//
//  MusicItemDetails.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/9/23.
//

import FirebaseFirestore

struct MusicItemDetails: ItemDetails {
    @DocumentID var id: String?
    var about: String
    var categoryId: String
    @ServerTimestamp var createdAt: Timestamp?
    var itemId: String
    var description: String
    var tracklist: [Track]

    struct Track: Codable, Hashable {
        var durationSec: Int
        var title: String
    }
}
