//
//  ItemRow.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/17/23.
//

import SwiftUI

struct ItemRow: View {
    @Binding var bagItem: BagItem

    @Environment(\.imageRepository) private var imageRepository

    @State private var imageURL: URL?

    var body: some View {
        Group {
            if let coffeeItem = bagItem.item as? CoffeeItem {
                HStack {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .background {
                                Color.Colors.Fills.inverse
                            }
                            .cornerRadius(Radius.lg)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 80, height: 80)

//                Spacer()

                    VStack(alignment: .leading) {
                        Text(coffeeItem.info.name)
                            .font(Font.custom("Lato-Regular", size: 12))
                            .foregroundStyle(Color.Colors.Text.primary)
                        Text(coffeeItem.info.roastery)
                            .font(Font.custom("Lato-Regular", size: 12))
                            .foregroundStyle(Color.Colors.Text.tertiary)

                        Spacer()

                        HStack {
                            Button {
                                if bagItem.quantity > 1 {
                                    bagItem.quantity -= 1
                                }
                            } label: {
                                Image(systemName: "minus.square")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            .foregroundStyle(Color.Colors.Brand.accent)
                            .disabled(bagItem.quantity == 1 ? true : false)

                            Text(String(bagItem.quantity))
                                .font(Font.custom("Lato-Regular", size: 14))
                                .frame(width: 30, height: 20)

                            Button {
                                if bagItem.quantity < 15 {
                                    bagItem.quantity += 1
                                }
                            } label: {
                                Image(systemName: "plus.square")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            .foregroundStyle(Color.Colors.Brand.accent)
                            .disabled(bagItem.quantity == 15 ? true : false)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
//                    Image(systemName: "x.circle")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .foregroundStyle(.accent)
//                        .frame(width: 20)
                        Spacer()
                        Text("$\(String(Int(coffeeItem.defaultPrice)))")
                            .font(Font.custom("Lato-Bold", size: 16))
                            .foregroundStyle(Color.Colors.Text.primary)
                    }
                }
                .frame(height: 80)
                .padding(Spacing.xl)
            } else if let musicItem = bagItem.item as? MusicItem {
                HStack {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(Radius.lg)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 80, height: 80)

//                Spacer()

                    VStack(alignment: .leading) {
                        Text(musicItem.info.album)
                            .font(Font.custom("Lato-Regular", size: 12))
                            .foregroundStyle(Color.Colors.Text.primary)
                        Text(musicItem.info.artist)
                            .font(Font.custom("Lato-Regular", size: 12))
                            .foregroundStyle(Color.Colors.Text.tertiary)

                        Spacer()

                        HStack {
                            Button {
                                if bagItem.quantity > 1 {
                                    bagItem.quantity -= 1
                                }
                            } label: {
                                Image(systemName: "minus.square")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            .foregroundStyle(Color.Colors.Brand.accent)
                            .disabled(bagItem.quantity == 1 ? true : false)

                            Text(String(bagItem.quantity))
                                .font(Font.custom("Lato-Regular", size: 14))
                                .frame(width: 30, height: 20)

                            Button {
                                if bagItem.quantity < 15 {
                                    bagItem.quantity += 1
                                }
                            } label: {
                                Image(systemName: "plus.square")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            .foregroundStyle(Color.Colors.Brand.accent)
                            .disabled(bagItem.quantity == 15 ? true : false)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
//                    Image(systemName: "x.circle")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .foregroundStyle(.accent)
//                        .frame(width: 20)
                        Spacer()
                        Text("$\(String(Int(musicItem.defaultPrice)))")
                            .font(Font.custom("Lato-Bold", size: 16))
                            .foregroundStyle(Color.Colors.Text.primary)
                    }
                }
                .frame(height: 80)
                .padding(Spacing.xl)
            } else if let apparelItem = bagItem.item as? ApparelItem {
                HStack {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(Radius.lg)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 80, height: 80)

                    //                Spacer()

                    VStack(alignment: .leading) {
                        Text(apparelItem.info.name)
                            .font(Font.custom("Lato-Regular", size: 12))
                            .foregroundStyle(Color.Colors.Text.primary)
                        Text(apparelItem.info.brand)
                            .font(Font.custom("Lato-Regular", size: 12))
                            .foregroundStyle(Color.Colors.Text.tertiary)

                        Spacer()

                        HStack {
                            Button {
                                if bagItem.quantity > 1 {
                                    bagItem.quantity -= 1
                                }
                            } label: {
                                Image(systemName: "minus.square")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            .foregroundStyle(Color.Colors.Brand.accent)
                            .disabled(bagItem.quantity == 1 ? true : false)

                            Text(String(bagItem.quantity))
                                .font(Font.custom("Lato-Regular", size: 14))
                                .frame(width: 30, height: 20)

                            Button {
                                if bagItem.quantity < 15 {
                                    bagItem.quantity += 1
                                }
                            } label: {
                                Image(systemName: "plus.square")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            .foregroundStyle(Color.Colors.Brand.accent)
                            .disabled(bagItem.quantity == 15 ? true : false)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
//                    Image(systemName: "x.circle")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .foregroundStyle(.accent)
//                        .frame(width: 20)
                        Spacer()
                        Text("$\(String(Int(apparelItem.defaultPrice)))")
                            .font(Font.custom("Lato-Bold", size: 16))
                            .foregroundStyle(Color.Colors.Text.primary)
                    }
                }
                .frame(height: 80)
                .padding(Spacing.xl)
            }
        }
        .task(id: bagItem.item.defaultImageURL) {
            imageURL = try? await imageRepository.imageURL(for: bagItem.item.defaultImageURL)
        }
    }
}
