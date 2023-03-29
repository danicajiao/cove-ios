//
//  TestModel.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/16/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct TestModel: Codable, Identifiable {
    @DocumentID public var id: String?
    let field1: String
    let field2: Int
    
    private enum CodingKeys: String, CodingKey {
        case field1
        case field2 = "field_2"
    }
    
    func printItem() {
        print(self.field1, self.field2)
        print(self.id)
    }
}
    
