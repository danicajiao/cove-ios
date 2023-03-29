//
//  Brand.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/28/23.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct Brand : Codable, Identifiable {
    @DocumentID var id: String?
    @ServerTimestamp var createdAt: Timestamp?
    var name: String
    var imageURL: String
}
