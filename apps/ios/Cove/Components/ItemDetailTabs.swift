//
//  ItemDetailTabs.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/12/23.
//

import SwiftUI

struct ItemDetailTabs: View {
    @ObservedObject var viewModel: ItemDetailViewModel
    let stackSpacing = Spacing.lg
    let tabSpacing = Spacing.xs

    var body: some View {
        if let musicItemDetails = viewModel.itemDetails as? MusicItemDetails {
            VStack(spacing: stackSpacing) {
                HStack(spacing: tabSpacing) {
                    tabPill("Description", selection: .description)
                    tabPill("Tracklist", selection: .tracklist)
                    tabPill("About", selection: .about)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if viewModel.detailSelection == .description {
                    Text(musicItemDetails.description)
                        .font(Font.custom("Lato-Regular", size: 16))
                        .foregroundStyle(Color.Colors.Text.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if viewModel.detailSelection == .tracklist {
                    VStack {
                        ForEach(musicItemDetails.tracklist, id: \.self) { track in
                            HStack {
                                Text(track.title)
                                    .font(Font.custom("Lato-Regular", size: 16))
                                    .foregroundStyle(Color.Colors.Text.primary)

                                Text(String(track.durationSec))
                                    .font(Font.custom("Lato-Regular", size: 16))
                                    .foregroundStyle(Color.Colors.Brand.accent)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                } else if viewModel.detailSelection == .about {
                    Text(musicItemDetails.about)
                        .font(Font.custom("Lato-Regular", size: 16))
                        .foregroundStyle(Color.Colors.Text.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

        } else if let coffeeItemDetails = viewModel.itemDetails as? CoffeeItemDetails {
            VStack(spacing: stackSpacing) {
                HStack(spacing: tabSpacing) {
                    tabPill("Description", selection: .description)
                    tabPill("Origin", selection: .origin)
                    tabPill("About", selection: .about)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if viewModel.detailSelection == .description {
                    Text(coffeeItemDetails.description)
                        .font(Font.custom("Lato-Regular", size: 16))
                        .foregroundStyle(Color.Colors.Text.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if viewModel.detailSelection == .origin {
                    VStack {
                        ForEach(coffeeItemDetails.origin, id: \.self) { originDetail in
                            HStack {
                                Text(originDetail.title)
                                    .font(Font.custom("Lato-Bold", size: 16))
                                    .foregroundStyle(Color.Colors.Text.primary)
                                Text(originDetail.content)
                                    .font(Font.custom("Lato-Regular", size: 16))
                                    .foregroundStyle(Color.Colors.Brand.accent)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                } else if viewModel.detailSelection == .about {
                    Text(coffeeItemDetails.about)
                        .font(Font.custom("Lato-Regular", size: 16))
                        .foregroundStyle(Color.Colors.Text.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

        } else if let apparelItemDetails = viewModel.itemDetails as? ApparelItemDetails {
            VStack(spacing: stackSpacing) {
                HStack(spacing: tabSpacing) {
                    tabPill("Description", selection: .description)
                    tabPill("Specifics", selection: .specifications)
                    tabPill("About", selection: .about)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if viewModel.detailSelection == .description {
                    Text(apparelItemDetails.description)
                        .font(Font.custom("Lato-Regular", size: 16))
                        .foregroundStyle(Color.Colors.Text.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if viewModel.detailSelection == .specifications {
                    VStack(spacing: Spacing.lg) {
                        ForEach(apparelItemDetails.specifications, id: \.self) { spec in
                            VStack(alignment: .leading) {
                                Text(spec.title)
                                    .font(Font.custom("Lato-Bold", size: 16))
                                    .foregroundStyle(Color.Colors.Text.primary)
                                ForEach(spec.content, id: \.self) { item in
                                    Text(item)
                                        .font(Font.custom("Lato-Regular", size: 16))
                                        .foregroundStyle(Color.Colors.Text.primary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                } else if viewModel.detailSelection == .about {
                    Text(apparelItemDetails.about)
                        .font(Font.custom("Lato-Regular", size: 16))
                        .foregroundStyle(Color.Colors.Text.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    @ViewBuilder
    private func tabPill(
        _ label: String,
        selection: ItemDetailViewModel.DetailSelection
    ) -> some View {
        let isSelected = viewModel.detailSelection == selection

        // Bold version is always rendered (opacity 0) to reserve its wider width,
        // preventing siblings from shifting when the font weight changes.
        Text(label)
            .font(Font.custom("Lato-Bold", size: 14))
            .opacity(0)
            .overlay(
                Text(label)
                    .font(Font.custom(isSelected ? "Lato-Bold" : "Lato-Regular", size: 14))
                    .foregroundStyle(isSelected ? Color.Colors.Fills.primary : Color.Colors.Fills.tertiary)
            )
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.md)
            .overlay(
                Capsule()
                    .strokeBorder(Color.Colors.Strokes.primary, lineWidth: 1)
                    .opacity(isSelected ? 1 : 0)
            )
            .onTapGesture {
                withAnimation {
                    viewModel.detailSelection = selection
                }
            }
    }
}
