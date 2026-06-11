//
//  TabState.swift
//  Cove
//
//  Created by Daniel Cajiao on 5/8/22.
//

import Foundation

enum Tab {
    case home
    case browse
    case bag
    case favorites
    case profile
}

class TabState: Identifiable, ObservableObject {
    @Published var currentTab: Tab = .home
    @Published var previousTab: Tab = .home
}
