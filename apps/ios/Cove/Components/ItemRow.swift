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
            if let coffeeProduct = bagItem.item as? CoffeeItem {
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
                        Text(coffeeProduct.info.name)
                            .font(Font.custom("Lato-Regular", size: 12))
                            .foregroundStyle(Color.Colors.Text.primary)
                        Text(coffeeProduct.info.roastery)
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
                        Text("$\(String(Int(coffeeProduct.defaultPrice)))")
                            .font(Font.custom("Lato-Bold", size: 16))
                            .foregroundStyle(Color.Colors.Text.primary)
                    }
                }
                .frame(height: 80)
                .padding(Spacing.xl)
            } else if let musicProduct = bagItem.item as? MusicItem {
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
                        Text(musicProduct.info.album)
                            .font(Font.custom("Lato-Regular", size: 12))
                            .foregroundStyle(Color.Colors.Text.primary)
                        Text(musicProduct.info.artist)
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
                        Text("$\(String(Int(musicProduct.defaultPrice)))")
                            .font(Font.custom("Lato-Bold", size: 16))
                            .foregroundStyle(Color.Colors.Text.primary)
                    }
                }
                .frame(height: 80)
                .padding(Spacing.xl)
            } else if let apparelProduct = bagItem.item as? ApparelItem {
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
                        Text(apparelProduct.info.name)
                            .font(Font.custom("Lato-Regular", size: 12))
                            .foregroundStyle(Color.Colors.Text.primary)
                        Text(apparelProduct.info.brand)
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
                        Text("$\(String(Int(apparelProduct.defaultPrice)))")
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
