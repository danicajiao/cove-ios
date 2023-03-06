//
//  HomeViewModel.swift
//  Cove
//
//  Created by Daniel Cajiao on 12/6/22.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class HomeViewModel: ObservableObject {
    @Published var items = [Item]()
    
    let categories = ["Music", "Coffee", "Home", "Bevs", "Apparel"]
    let origins = ["Colombia", "Guatemala", "Ethiopia", "Costa Rica", "Kenya"]
    
    func getItemData() {
        // Get a reference to firestore
        let db = Firestore.firestore()
        
        // Get a reference to storage
        let storageRef = Storage.storage().reference()
        
        // Read the documents at a specific path
        db.collection("coffees").limit(to: 4).getDocuments { snapshot, error in
            if error == nil {
                // No errors
                if let snapshot = snapshot {
                    // Update the item property in the main thread
                    // Get all the documents and create items
                    self.items = snapshot.documents.map { d in
                        // Create an Item for each document returned
                        let item = Item(id: d.documentID,
                                        brand: d["roastery"] as? String ?? "",
                                        name: d["name"] as? String ?? "",
                                        price: d["price"] as? Float ?? 0,
                                        imgPath: d["imgPath"] as? String ?? "")
                        item.printItem()
                        return item
                    }
                    
                    for item in self.items {
                        // Specify the path
                        let fileRef = storageRef.child(item.imgPath)

                        // Retrieve the data
                        fileRef.getData(maxSize: 1 * 1024 * 1024 as Int64) { data, error in
                            // Check for errors
                            if error == nil && data != nil {
                                // Create a UIImage
                                if let data = data {
                                    item.imgData = data
                                }
                            }
                        }
                    }
                }
            }
            else {
                // Handle the error
            }
        }
    }
}
