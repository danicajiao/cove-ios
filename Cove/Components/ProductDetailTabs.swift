//
//  ProductDetailTabs.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/12/23.
//

import SwiftUI

struct ProductDetailTabs: View {
    @ObservedObject var viewModel: ProductDetailViewModel

    var body: some View {
        if let musicProductDetails = viewModel.productDetails as? MusicProductDetails {
            VStack {
                HStack(spacing: 0) {
                    if viewModel.detailSelection == .description {
                        Text("Description")
                            .font(Font.custom("Lato-Bold", size: 16))
                            .foregroundStyle(Color.Colors.Fills.primary)
                            .frame(minWidth: 120, minHeight: 40)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(Color.Colors.)
                            }
                            .onTapGesture {
                                withAnimation {
                                    viewModel.detailSelection = .description
                                }
                            }
                    } else {
                        Text("Description")
                            .font(Font.custom("Lato-Regular", size: 16))
                            .foregroundStyle(Color.Colors.Fills.tertiary)
                            .frame(minWidth: 120, minHeight: 40)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.detailSelection = .description
                                }
                            }
                    }

                    if viewModel.detailSelection == .tracklist {
                        Text("Tracklist")
                            .font(Font.custom("Lato-Regular", size: 16))
                            .foregroundStyle(Color.Colors.Fills.primary)
                            .frame(minWidth: 90, minHeight: 40)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(Color.backdrop)
                            }
                            .onTapGesture {
                                withAnimation {
                                    viewModel.detailSelection = .tracklist
                                }
                            }
                    } else {
                        Text("Tracklist")
                            .font(Font.custom("Lato-Regular", size: 16))
                            .foregroundStyle(Color.Colors.Fills.tertiary)
                            .frame(minWidth: 90, minHeight: 40)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.detailSelection = .tracklist
                                }
                            }
                    }

                    if viewModel.detailSelection == .about {
                        Text("About")
                            .font(Font.custom("Lato-Bold", size: 16))
                            .foregroundStyle(Color.Colors.Fills.primary)
                            .frame(minWidth: 75, minHeight: 40)
                            //                                    .padding(10)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(Color.backdrop)
                            }
                            .onTapGesture {
                                withAnimation {
                                    viewModel.detailSelection = .about
                                }
                            }
                    } else {
                        Text("About")
                            .font(Font.custom("Poppins-Regular", size: 16))
                            .foregroundStyle(Color.Colors.Fills.tertiary)
                            .frame(minWidth: 75, minHeight: 40)
                            //                                    .padding(10)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.detailSelection = .about
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if viewModel.detailSelection == .description {
                    Text(musicProductDetails.description)
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .foregroundStyle(Color.Colors.Fills.tertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if viewModel.detailSelection == .tracklist {
                    VStack {
                        ForEach(musicProductDetails.tracklist, id: \.self) { track in
                            HStack {
                                Text(track.title)
                                    .font(Font.custom("Poppins-Regular", size: 16))
                                    .foregroundStyle(Color.Colors.Fills.tertiary)

                                Text(String(track.durationSec))
                                    .font(Font.custom("Poppins-Regular", size: 16))
                                    .foregroundStyle(Color.Colors.Brand.accent)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                } else if viewModel.detailSelection == .about {
                    Text(musicProductDetails.about)
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .foregroundStyle(Color.Colors.Fills.tertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

        } else if let coffeeProductDetails = viewModel.productDetails as? CoffeeProductDetails {
            VStack {
                HStack(spacing: 0) {
                    if viewModel.detailSelection == .description {
                        Text("Description")
                            .font(Font.custom("Poppins-SemiBold", size: 16))
                            .foregroundStyle(Color.Colors.Fills.primary)
                            .frame(minWidth: 120, minHeight: 40)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(Color.backdrop)
                            }
                            .onTapGesture {
                                withAnimation {
                                    viewModel.detailSelection = .description
                                }
                            }
                    } else {
                        Text("Description")
                            .font(Font.custom("Poppins-Regular", size: 16))
                            .foregroundStyle(Color.Colors.Fills.tertiary)
                            .frame(minWidth: 120, minHeight: 40)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.detailSelection = .description
                                }
                            }
                    }

                    if viewModel.detailSelection == .origin {
                        Text("Origin")
                            .font(Font.custom("Poppins-SemiBold", size: 16))
                            .foregroundStyle(Color.Colors.Fills.primary)
                            .frame(minWidth: 75, minHeight: 40)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(Color.backdrop)
                            }
                            .onTapGesture {
                                withAnimation {
                                    viewModel.detailSelection = .origin
                                }
                            }
                    } else {
                        Text("Origin")
                            .font(Font.custom("Poppins-Regular", size: 16))
                            .foregroundStyle(Color.Colors.Fills.tertiary)
                            .frame(minWidth: 75, minHeight: 40)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.detailSelection = .origin
                                }
                            }
                    }

                    if viewModel.detailSelection == .about {
                        Text("About")
                            .font(Font.custom("Poppins-SemiBold", size: 16))
                            .foregroundStyle(Color.Colors.Fills.primary)
                            .frame(minWidth: 75, minHeight: 40)
                            //                                    .padding(10)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(Color.backdrop)
                            }
                            .onTapGesture {
                                withAnimation {
                                    viewModel.detailSelection = .about
                                }
                            }
                    } else {
                        Text("About")
                            .font(Font.custom("Poppins-Regular", size: 16))
                            .foregroundStyle(Color.Colors.Fills.tertiary)
                            .frame(minWidth: 75, minHeight: 40)
                            //                                    .padding(10)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.detailSelection = .about
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if viewModel.detailSelection == .description {
                    Text(coffeeProductDetails.description)
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .foregroundStyle(Color.Colors.Fills.tertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if viewModel.detailSelection == .origin {
                    VStack {
                        ForEach(coffeeProductDetails.origin, id: \.self) { originDetail in
                            HStack {
                                Text(originDetail.title)
                                    .font(Font.custom("Poppins-SemiBold", size: 16))
                                    .foregroundStyle(Color.Colors.Fills.tertiary)
                                Text(originDetail.content)
                                    .font(Font.custom("Poppins-Regular", size: 16))
                                    .foregroundStyle(Color.Colors.Brand.accent)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                } else if viewModel.detailSelection == .about {
                    Text(coffeeProductDetails.about)
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .foregroundStyle(Color.Colors.Fills.tertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

        } else if let apparelProductDetails = viewModel.productDetails as? ApparelProductDetails {
            VStack {
                HStack(spacing: 0) {
                    if viewModel.detailSelection == .description {
                        Text("Description")
                            .font(Font.custom("Poppins-SemiBold", size: 16))
                            .foregroundStyle(Color.Colors.Fills.primary)
                            .frame(minWidth: 120, minHeight: 40)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(Color.backdrop)
                            }
                            .onTapGesture {
                                withAnimation {
                                    viewModel.detailSelection = .description
                                }
                            }
                    } else {
                        Text("Description")
                            .font(Font.custom("Poppins-Regular", size: 16))
                            .foregroundStyle(Color.Colors.Fills.tertiary)
                            .frame(minWidth: 120, minHeight: 40)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.detailSelection = .description
                                }
                            }
                    }

                    if viewModel.detailSelection == .specifications {
                        Text("Specifics")
                            .font(Font.custom("Poppins-SemiBold", size: 16))
                            .foregroundStyle(Color.Colors.Fills.primary)
                            .frame(minWidth: 100, minHeight: 40)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(Color.backdrop)
                            }
                            .onTapGesture {
                                withAnimation {
                                    viewModel.detailSelection = .specifications
                                }
                            }
                    } else {
                        Text("Specifics")
                            .font(Font.custom("Poppins-Regular", size: 16))
                            .foregroundStyle(Color.Colors.Fills.tertiary)
                            .frame(minWidth: 100, minHeight: 40)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.detailSelection = .specifications
                                }
                            }
                    }

                    if viewModel.detailSelection == .about {
                        Text("About")
                            .font(Font.custom("Poppins-SemiBold", size: 16))
                            .foregroundStyle(Color.Colors.Fills.primary)
                            .frame(minWidth: 75, minHeight: 40)
                            //                                    .padding(10)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(Color.backdrop)
                            }
                            .onTapGesture {
                                withAnimation {
                                    viewModel.detailSelection = .about
                                }
                            }
                    } else {
                        Text("About")
                            .font(Font.custom("Poppins-Regular", size: 16))
                            .foregroundStyle(Color.Colors.Fills.tertiary)
                            .frame(minWidth: 75, minHeight: 40)
                            //                                    .padding(10)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.detailSelection = .about
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if viewModel.detailSelection == .description {
                    Text(apparelProductDetails.description)
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .foregroundStyle(Color.Colors.Fills.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if viewModel.detailSelection == .specifications {
                    VStack(spacing: 20) {
                        ForEach(apparelProductDetails.specifications, id: \.self) { spec in
                            VStack(alignment: .leading) {
                                Text(spec.title)
                                    .font(Font.custom("Poppins-SemiBold", size: 16))
                                    .foregroundStyle(Color.Colors.Fills.tertiary)
                                ForEach(spec.content, id: \.self) { el in
                                    Text(el)
                                        .font(Font.custom("Poppins-Regular", size: 16))
                                        .foregroundStyle(Color.Colors.Fills.tertiary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                } else if viewModel.detailSelection == .about {
                    Text(apparelProductDetails.about)
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .foregroundStyle(Color.Colors.Fills.tertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}
