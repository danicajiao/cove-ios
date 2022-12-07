//
//  ItemView.swift
//  Cove
//
//  Created by Daniel Cajiao on 5/8/22.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct ItemView: View {
    @StateObject var item: Item
    @State var count = 1
    @State var detailSelection = "description"
    
    @State var similarItems = [Item]()
    
    var rows: [GridItem] = [
        GridItem(.adaptive(minimum: .infinity, maximum: .infinity), spacing: 20)
        ]
    
    @ViewBuilder
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    
//                    Section(header: Text("------------------------------------")) { }
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(.backdropColor)
                            .scaleEffect(1.5)
                        Image(uiImage: UIImage(data: item.imgData) ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 250)
                    }
                    
                    VStack(spacing: 20) {
                        VStack(spacing: 10) {
                            Text(item.name)
                                .font(Font.custom("Poppins-Regular", size: 22))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
                            
                            HStack {
                                Text("$\(Int(item.price))")
                                    .font(Font.custom("Poppins-SemiBold", size: 22))
                                
                                Spacer()
                                
                                Button("-") {
                                    if count > 1 {
                                        count = count - 1
                                    }
                                }
                                .foregroundColor(.primaryColor)
                                
                                Text(String(count))
                                
                                Button("+") {
                                    if count < 15 {
                                        count = count + 1
                                    }
                                }
                                .foregroundColor(.primaryColor)
                            }
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        }
                        
                        NavigationLink(destination: Text("Item Reviews!")) {

                            HStack {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        RatingView(rating: 4)
                                        Text("4.3")
                                    }
                                    Text("22 Reviews \(Image(systemName: "chevron.right"))")
                                }
                                
                                Spacer()
                                
                                Circle()
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(.white)
                                    .overlay {
                                        Circle()
                                            .frame(width: 30, height: 30)
                                    }
                                
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background {
                                Rectangle()
                                    .foregroundColor(.backgroundColor)
                            }
                            .cornerRadius(8)
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        HStack(spacing: 20) {
                            Text("Description")
                                .font(Font.custom("Poppins-Regular", size: 16))
                                .onTapGesture {
                                    detailSelection = "description"
                                }

                            Text("Notes")
                                .font(Font.custom("Poppins-Regular", size: 16))
                                .onTapGesture {
                                    detailSelection = "notes"
                                }

                            Text("Origin")
                                .font(Font.custom("Poppins-Regular", size: 16))
                                .onTapGesture {
                                    detailSelection = "origin"
                                }

                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        
                        if detailSelection == "description" {
                            Text("DESCRIPTION")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        }
                        else if detailSelection == "notes" {
                            Text("NOTES")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        }
                        else if detailSelection == "origin" {
                            Text("ORIGIN")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        }
                        
        //                Divider()
                        
                        Text("Similar Products")
                            .font(Font.custom("Poppins-SemiBold", size: 18))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        
        //                ScrollView(.horizontal, showsIndicators: false) {
        //                    HStack(spacing: 20) {
        //                        ForEach(similarItems) { item in
        //                            ItemCardView(item: item)
        //                        }
        //                    }
        //                }
        //                .onAppear {
        //                    getItemData()
        //                }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(
                                rows: rows,
                                alignment: .bottom,
                                spacing: 20,
                                pinnedViews: [.sectionHeaders, .sectionFooters]
                            ) {
                                ForEach(similarItems) { item in
                                    ItemCardView(item: item)
                                }
                            }
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        }
                        .onAppear {
                            getItemData()
                        }
                    }
                    .background {
                        Color.white
                    }
                    .cornerRadius(20)
                }
                .safeAreaInset(edge: .top, spacing: geometry.safeAreaInsets.top) { }
            }
//            .background {
//                Color.backdropColor
//            }
            .edgesIgnoringSafeArea(.top)
//            .safeAreaInset(edge: .top, spacing: geometry.safeAreaInsets.top) { }
            
        }
        .navigationBarHidden(true)
    }
    
    func getItemData() {
        
        // Get a reference to the database
        let db = Firestore.firestore()
        
        // Get a reference to storage
        let storageRef = Storage.storage().reference()
        
        // Read the documents at a specific path
        db.collection("items").limit(to: 4).getDocuments { snapshot, error in
            if error == nil {
                // No errors
                if let snapshot = snapshot {
                    // Update the item property in the main thread
//                    DispatchQueue.main.sync {
                        // Get all the documents and create items
                        similarItems = snapshot.documents.map { d in
                            // Create an Item for each document returned
                            let item = Item(id: d.documentID,
                                            brand: d["brand"] as? String ?? "",
                                            name: d["name"] as? String ?? "",
                                            price: d["price"] as? Float ?? 0,
                                            imgPath: d["imgPath"] as? String ?? "")
                            item.printItem()
                            return item
                        }
//                    }
                    
                    for item in similarItems {
                        // Specify the path
                        let fileRef = storageRef.child(item.imgPath)

                        // Retrieve the data
                        fileRef.getData(maxSize: 1 * 1024 * 1024 as Int64) { data, error in
                            // Check for errors
                            if error == nil && data != nil {
                                // Create a UIImage
                                if let data = data {
//                                    DispatchQueue.main.async {
                                        item.imgData = data
//                                    }
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

struct ItemView_Previews: PreviewProvider {
    static let asset = UIImage(named: "WST-1011_2")
    
    static let item = Item(id: "12345aaaa", brand: "Wonderstate Coffee", name: "Star Valley Decaf", price: 23, imgPath: "item-images/WST-1011_2.jpeg", imgData: (asset?.jpegData(compressionQuality: 1))!)
    
    static var previews: some View {
        ItemView(item: item)
    }
}
