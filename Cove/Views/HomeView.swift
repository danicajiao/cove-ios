//
//  HomeView.swift
//  Cove
//
//  Created by Daniel Cajiao on 2/16/22.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

extension Color {
    static let backgroundColor = Color("BackgroundColor")
    static let primaryColor = Color("PrimaryColor")
    static let secondaryColor = Color("SecondaryColor")
    static let tertiaryColor = Color("TertiaryColor")
    static let quaternaryColor = Color("QuaternaryColor")
    static let dropShadowColor = Color("DropShadowColor")
    static let backdropColor = Color("BackdropColor")
    static let fruityGradient = Color("FruityGradient")
    static let chocoGradient = Color("ChocoGradient")
    static let citrusGradient = Color("CitrusGradient")
    static let earthyGradient = Color("EarthyGradient")
    static let floralGradient = Color("FloralGradient")
    static let bannerGradient = Color("BannerGradient")
}

struct HomeView: View {
    
    @State var items = [Item]()
    
    let categories = ["Fruity", "Choco", "Citrus", "Earthy", "Floral"]
    let origins = ["Colombia", "Guatemala", "Ethiopia", "Costa Rica", "Kenya"]
    
    private var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 100, maximum: .infinity), spacing: 20),
        GridItem(.adaptive(minimum: 100, maximum: .infinity), spacing: 20)
        ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HStack {
                    // TODO: Implement time-based greeting message
                    Text("Good morning, Faith")
                        .frame(maxWidth: 215, alignment: .leading)
                        .font(Font.custom("Poppins-SemiBold", size: 26))
                        .padding(EdgeInsets(top: 28, leading: 0, bottom: 0, trailing: 0))
                    Spacer()
                    // TODO: Add notifications button to the right of greeting Text
                    Image(systemName: "bell.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .padding(EdgeInsets(top: 28, leading: 0, bottom: 0, trailing: 0))
                        .foregroundColor(.primaryColor)
                }
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
                TextField("\(Image(systemName: "magnifyingglass")) Espresso, light roast, floral", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                    .font(Font.custom("Poppins-Regular", size: 14))
                    .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondaryColor, lineWidth: 1)
                    )
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
                VStack {
                    HStack {
                        Text("Categories")
                            .font(Font.custom("Poppins-SemiBold", size: 22))
                        Spacer()
                        // TODO: Navigate to Categories scene
                        Button("See all \(Image(systemName: "arrow.forward"))") {
                        }
                        .foregroundColor(.primaryColor)
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(categories, id: \.self) { category in
                                CategoryButton(category: category)
                            }
                        }
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    }
                }
                
                BannerButton(bannerType: 1)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
                VStack {
                    HStack {
                        Text("Popular")
                            .font(Font.custom("Poppins-SemiBold", size: 22))
                        Spacer()
                        // TODO: Navigate to Browse scene
                        Button("See all \(Image(systemName: "arrow.forward"))") {
                        }
                        .foregroundColor(.primaryColor)
                    }
                    
                    LazyVGrid(
                        columns: columns,
                        alignment: .center,
                        spacing: 20,
                        pinnedViews: [.sectionHeaders, .sectionFooters]
                    ) {
                        ForEach(items) { item in
                            ItemCardView(item: item)
                        }
                    }
                    .onAppear {
                        getItemData()
                    }
                    
                }
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
                BannerButton(bannerType: 2)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
                VStack {
                    HStack {
                        Text("Origins")
                            .font(Font.custom("Poppins-SemiBold", size: 22))
                        Spacer()
                        // TODO: Navigate to Browse scene
                        Button("See all \(Image(systemName: "arrow.forward"))") {
                        }
                        .foregroundColor(.primaryColor)
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(origins, id: \.self) { origin in
                                OriginButton(origin: origin)
                            }
                        }
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                    }
                }
            }
        }
    }
    
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
//                    DispatchQueue.main.sync {
                        // Get all the documents and create items
                        items = snapshot.documents.map { d in
                            // Create an Item for each document returned
                            let item = Item(id: d.documentID,
                                            brand: d["roastery"] as? String ?? "",
                                            name: d["name"] as? String ?? "",
                                            price: d["price"] as? Float ?? 0,
                                            imgPath: d["imgPath"] as? String ?? "")
                            item.printItem()
                            return item
                        }
//                    }
                    
                    for item in items {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
