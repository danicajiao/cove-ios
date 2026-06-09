//
//  ItemTypes.swift
//
//  Created by Daniel Cajiao on 4/12/23.
//

/// ltree path prefixes for the top-level item categories in `catalog.categories`.
///
/// These are used for dispatching category-specific UI (e.g. `ItemCard` subtitle
/// logic) when working with legacy `CoffeeItem` / `MusicItem` / `ApparelItem`
/// types. Items sourced from the cove-api gateway are represented as
/// `DiscoveryItem` and do not require this enum for display.
enum ItemTypes: String {
    case coffee = "food.coffee"
    case music
    case apparel
}
