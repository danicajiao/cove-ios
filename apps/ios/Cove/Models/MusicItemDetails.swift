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

    // Remove in Phase 3 when Firestore is decommissioned (#324).
    private enum CodingKeys: String, CodingKey {
        case id // @DocumentID
        case about, categoryId, createdAt, description, tracklist
        case itemId = "productId"
    }

    struct Track: Codable, Hashable {
        var durationSec: Int
        var title: String
    }
}
