//
//  ProductDetailTabs.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/12/23.
//

import SwiftUI

struct ProductDetailTabs: View {
    @StateObject var viewModel: ProductDetailViewModel
    
    var body: some View {
        if let musicProductDetails = self.viewModel.productDetails as? MusicProductDetails {
            VStack {
                HStack(spacing: 0) {
                    if self.viewModel.detailSelection == .description {
                        Text("Description")
                            .font(Font.custom("Lato-Bold", size: 16))
                            .foregroundColor(.accent)
                            .frame(minWidth: 120, minHeight: 40)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.backdrop)
                            }
                            .onTapGesture {
                                withAnimation {
                                    self.viewModel.detailSelection = .description
                                }
                            }
                    } else {
                        Text("Description")
                            .font(Font.custom("Lato-Regular", size: 16))
                            .foregroundColor(.grey)
                            .frame(minWidth: 120, minHeight: 40)
                            .onTapGesture {
                                withAnimation {
                                    self.viewModel.detailSelection = .description
                                }
                            }
                    }
                    
                    if self.viewModel.detailSelection == .tracklist {
                        Text("Tracklist")
                            .font(Font.custom("Lato-Regular", size: 16))
                            .foregroundColor(.accent)
                            .frame(minWidth: 90, minHeight: 40)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.backdrop)
                            }
                            .onTapGesture {
                                withAnimation {
                                    self.viewModel.detailSelection = .tracklist
                                }
                            }
                    } else {
                        Text("Tracklist")
                            .font(Font.custom("Lato-Regular", size: 16))
                            .foregroundColor(.grey)
                            .frame(minWidth: 90, minHeight: 40)
                            .onTapGesture {
                                withAnimation {
                                    self.viewModel.detailSelection = .tracklist
                                }
                            }
                    }
                    
                    if self.viewModel.detailSelection == .about {
                        Text("About")
                            .font(Font.custom("Lato-Bold", size: 16))
                            .foregroundColor(.accent)
                            .frame(minWidth: 75, minHeight: 40)
                        //                                    .padding(10)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.backdrop)
                            }
                            .onTapGesture {
                                withAnimation {
                                    self.viewModel.detailSelection = .about
                                }
                            }
                    } else {
                        Text("About")
                            .font(Font.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.grey)
                            .frame(minWidth: 75, minHeight: 40)
                        //                                    .padding(10)
                            .onTapGesture {
                                withAnimation {
                                    self.viewModel.detailSelection = .about
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if self.viewModel.detailSelection == .description {
                    Text(musicProductDetails.description)
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.grey)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                else if self.viewModel.detailSelection == .tracklist {
                    VStack {
                        ForEach(musicProductDetails.tracklist, id: \.self) { track in
                            HStack {
                                Text(track.title)
                                    .font(Font.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.grey)
                                
                                Text(String(track.durationSec))
                                    .font(Font.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.accent)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                else if self.viewModel.detailSelection == .about {
                    Text(musicProductDetails.about)
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.grey)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
            }
            
        } else if let coffeeProductDetails = self.viewModel.productDetails as? CoffeeProductDetails {
            VStack {
                HStack(spacing: 0) {
                    if self.viewModel.detailSelection == .description {
                        Text("Description")
                            .font(Font.custom("Poppins-SemiBold", size: 16))
                            .foregroundColor(.accent)
                            .frame(minWidth: 120, minHeight: 40)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.backdrop)
                            }
                            .onTapGesture {
                                withAnimation {
                                    self.viewModel.detailSelection = .description
                                }
                            }
                    } else {
                        Text("Description")
                            .font(Font.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.grey)
                            .frame(minWidth: 120, minHeight: 40)
                            .onTapGesture {
                                withAnimation {
                                    self.viewModel.detailSelection = .description
                                }
                            }
                    }
                    
                    if self.viewModel.detailSelection == .origin {
                        Text("Origin")
                            .font(Font.custom("Poppins-SemiBold", size: 16))
                            .foregroundColor(.accent)
                            .frame(minWidth: 75, minHeight: 40)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.backdrop)
                            }
                            .onTapGesture {
                                withAnimation {
                                    self.viewModel.detailSelection = .origin
                                }
                            }
                    } else {
                        Text("Origin")
                            .font(Font.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.grey)
                            .frame(minWidth: 75, minHeight: 40)
                            .onTapGesture {
                                withAnimation {
                                    self.viewModel.detailSelection = .origin
                                }
                            }
                    }
                    
                    if self.viewModel.detailSelection == .about {
                        Text("About")
                            .font(Font.custom("Poppins-SemiBold", size: 16))
                            .foregroundColor(.accent)
                            .frame(minWidth: 75, minHeight: 40)
                        //                                    .padding(10)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.backdrop)
                            }
                            .onTapGesture {
                                withAnimation {
                                    self.viewModel.detailSelection = .about
                                }
                            }
                    } else {
                        Text("About")
                            .font(Font.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.grey)
                            .frame(minWidth: 75, minHeight: 40)
                        //                                    .padding(10)
                            .onTapGesture {
                                withAnimation {
                                    self.viewModel.detailSelection = .about
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if self.viewModel.detailSelection == .description {
                    Text(coffeeProductDetails.description)
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.grey)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                else if self.viewModel.detailSelection == .origin {
                    VStack {
                        ForEach(coffeeProductDetails.origin, id: \.self) { originDetail in
                            HStack {
                                Text(originDetail.title)
                                    .font(Font.custom("Poppins-SemiBold", size: 16))
                                    .foregroundColor(.grey)
                                Text(originDetail.content)
                                    .font(Font.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.accent)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                else if self.viewModel.detailSelection == .about {
                    Text(coffeeProductDetails.about)
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.grey)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
        } else if let apparelProductDetails = self.viewModel.productDetails as? ApparelProductDetails {
            VStack {
                HStack(spacing: 0) {
                    if self.viewModel.detailSelection == .description {
                        Text("Description")
                            .font(Font.custom("Poppins-SemiBold", size: 16))
                            .foregroundColor(.accent)
                            .frame(minWidth: 120, minHeight: 40)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.backdrop)
                            }
                            .onTapGesture {
                                withAnimation {
                                    self.viewModel.detailSelection = .description
                                }
                            }
                    } else {
                        Text("Description")
                            .font(Font.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.grey)
                            .frame(minWidth: 120, minHeight: 40)
                            .onTapGesture {
                                withAnimation {
                                    self.viewModel.detailSelection = .description
                                }
                            }
                    }
                    
                    if self.viewModel.detailSelection == .specifications {
                        Text("Specifics")
                            .font(Font.custom("Poppins-SemiBold", size: 16))
                            .foregroundColor(.accent)
                            .frame(minWidth: 100, minHeight: 40)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.backdrop)
                            }
                            .onTapGesture {
                                withAnimation {
                                    self.viewModel.detailSelection = .specifications
                                }
                            }
                    } else {
                        Text("Specifics")
                            .font(Font.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.grey)
                            .frame(minWidth: 100, minHeight: 40)
                            .onTapGesture {
                                withAnimation {
                                    self.viewModel.detailSelection = .specifications
                                }
                            }
                    }
                    
                    if self.viewModel.detailSelection == .about {
                        Text("About")
                            .font(Font.custom("Poppins-SemiBold", size: 16))
                            .foregroundColor(.accent)
                            .frame(minWidth: 75, minHeight: 40)
                        //                                    .padding(10)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.backdrop)
                            }
                            .onTapGesture {
                                withAnimation {
                                    self.viewModel.detailSelection = .about
                                }
                            }
                    } else {
                        Text("About")
                            .font(Font.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.grey)
                            .frame(minWidth: 75, minHeight: 40)
                        //                                    .padding(10)
                            .onTapGesture {
                                withAnimation {
                                    self.viewModel.detailSelection = .about
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if self.viewModel.detailSelection == .description {
                    Text(apparelProductDetails.description)
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.grey)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                else if self.viewModel.detailSelection == .specifications {
                    VStack(spacing: 20) {
                        ForEach(apparelProductDetails.specifications, id: \.self) { spec in
                            VStack(alignment: .leading) {
                                Text(spec.title)
                                    .font(Font.custom("Poppins-SemiBold", size: 16))
                                    .foregroundColor(.grey)
                                ForEach(spec.content, id: \.self) { el in
                                    Text(el)
                                        .font(Font.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(.grey)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                else if self.viewModel.detailSelection == .about {
                    Text(apparelProductDetails.about)
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.grey)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}
