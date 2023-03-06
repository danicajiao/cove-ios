//
//  HomeView.swift
//  Cove
//
//  Created by Daniel Cajiao on 2/16/22.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    
    private var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 100, maximum: .infinity), spacing: 20),
        GridItem(.adaptive(minimum: 100, maximum: .infinity), spacing: 20)
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HStack {
                    // TODO: Implement time-based greeting message
                    Text("Good morning, Daniel")
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
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondaryColor, lineWidth: 1)
                    }
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
                            ForEach(homeViewModel.categories, id: \.self) { category in
                                LargeButton(category: category)
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
                        ForEach(homeViewModel.items) { item in
                            ItemCardView(item: item)
                        }
                    }
                    .onAppear {
                        homeViewModel.getItemData()
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
                            ForEach(homeViewModel.origins, id: \.self) { origin in
                                OriginButton(origin: origin)
                            }
                        }
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
