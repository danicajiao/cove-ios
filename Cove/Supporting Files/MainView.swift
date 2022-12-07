//
//  MainView.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/10/22.
//

import SwiftUI

struct MainView: View {
    @StateObject private var tabState = TabState()
    
    var body: some View {
        NavigationView {
            TabView(selection: $tabState.currentTab) {
                HomeView()
                    .onTapGesture {
                        tabState.currentTab = "home"
                    }
                    .tabItem {
                        Label("Home", systemImage: tabState.currentTab == "home" ? "house.fill" : "house")
                            .environment(\.symbolVariants, .none)
                    }
                    .tag("home")
                    .navigationBarHidden(true)
                
                Text("Browse Scene")
                    .onTapGesture {
                        tabState.currentTab = "browse"
                    }
                    .tabItem {
                        Label("Browse", systemImage: tabState.currentTab == "browse" ? "magnifyingglass" : "magnifyingglass")
                            .environment(\.symbolVariants, .none)
                    }
                    .tag("browse")
                
                Text("Bag Scene")
                    .onTapGesture {
                        tabState.currentTab = "bag"
                    }
                    .tabItem {
                        Label("Bag", systemImage: tabState.currentTab == "bag" ? "bag.fill" : "bag")
                            .environment(\.symbolVariants, .none)
                    }
                    .tag("bag")
                
                Text("Favorites Scene")
                    .onTapGesture {
                        tabState.currentTab = "favorites"
                    }
                    .tabItem {
                        Label("Favorites", systemImage: tabState.currentTab == "favorites" ? "heart.fill" : "heart")
                            .environment(\.symbolVariants, .none)
                    }
                    .tag("favorites")
                
                Text("Profile Scene")
                    .onTapGesture {
                        tabState.currentTab = "profile"
                    }
                    .tabItem {
                        Label("Profile", systemImage: tabState.currentTab == "profile" ? "person.crop.circle.fill" : "person.crop.circle")
                            .environment(\.symbolVariants, .none)
                    }
                    .tag("profile")
                
                
            }
            .environmentObject(tabState)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
