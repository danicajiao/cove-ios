//
//  MainView.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/10/22.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var bag: Bag
    @StateObject private var tabState = TabState()

    var body: some View {
        TabView(selection: $tabState.currentTab) {
            TabNavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: tabState.currentTab == .home ? "house.fill" : "house")
                    .environment(\.symbolVariants, .none)
            }
            .tag(Tab.home)

            TabNavigationStack {
                Text("Browse View")
            }
            .tabItem {
                Label("Browse", systemImage: "magnifyingglass")
                    .environment(\.symbolVariants, .none)
            }
            .tag(Tab.browse)

            TabNavigationStack {
                BagView()
            }
            .tabItem {
                Label("Bag", systemImage: tabState.currentTab == .bag ? "bag.fill" : "bag")
                    .environment(\.symbolVariants, .none)
            }
            .badge(bag.totalItems)
            .tag(Tab.bag)

            TabNavigationStack {
                FavoritesView()
            }
            .tabItem {
                Label("Favorites", systemImage: tabState.currentTab == .favorites ? "heart.fill" : "heart")
                    .environment(\.symbolVariants, .none)
            }
            .tag(Tab.favorites)

            TabNavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: tabState.currentTab == .profile ? "person.crop.circle.fill" : "person.crop.circle")
                    .environment(\.symbolVariants, .none)
            }
            .tag(Tab.profile)
        }
        .environmentObject(tabState)
        .background(Color.Colors.Backgrounds.primary)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
