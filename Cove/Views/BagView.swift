//
//  BagView.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/17/23.
//

import SwiftUI

struct BagView: View {
    @EnvironmentObject var bag: Bag
    @StateObject var viewModel = BagViewModel()
    
//    @State var total: Int = 0
    
    private func deleteItem(at indexSet: IndexSet) {
        self.bag.bagProducts.remove(atOffsets: indexSet)
        self.bag.categories.remove(atOffsets: indexSet)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("My Shopping Bag")
                        .font(Font.custom("Poppins-SemiBold", size: 26))
                        .padding(.top, 28)
                    Spacer()
                }
                .padding([.leading, .trailing], 20)
                
                if self.bag.bagProducts.isEmpty {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.Colors.Backgrounds.secondary)
                        .overlay {
                            Text("Products you add to your bag can be found here!")
                                .multilineTextAlignment(.center)
                                .font(Font.custom("Poppins-Regular", size: 16))
                                .foregroundStyle(Color.Colors.Fills.primary)
                                .padding(50)
                            
                        }
                        .border(Color.Colors.Strokes.primary, width: 1)
                        .frame(height: 300)
                        .padding([.leading, .trailing], 20)
                } else {
                    List {
                        ForEach(Array(self.$bag.bagProducts.enumerated()), id: \.offset) { index, $bagProduct in
                            ProductRow(bagProduct: $bagProduct)
                                .listRowInsets(EdgeInsets())
                        }
                        .onDelete(perform: self.deleteItem)
                    }
                    .listStyle(.inset)
                    .buttonStyle(BorderlessButtonStyle())
                    .frame(height: 300)
                }
                
                VStack {
                    Rectangle()
                        .frame(height: 4)
                        .foregroundStyle(Color.Colors.Fills.quinary)
                    
                    HStack {
                        TextField("Insert your coupon code", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                            .font(Font.custom("Poppins-Regular", size: 14))
                            .padding([.leading, .trailing])
                            .frame(maxHeight: .infinity)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.Colors.Strokes.primary, lineWidth: 1)
                            }
                        
                        Button {
                        } label: {
                            Text("Apply")
                        }
                        .buttonStyle(PrimaryButton(width: 72, height: .infinity))
                    }
                    .frame(height: 40)
                    .padding([.leading, .trailing], 20)
                    .padding([.top, .bottom], 10)
                    
                    Rectangle()
                        .frame(height: 4)
                        .foregroundStyle(Color.Colors.Fills.quinary)
                }
                
                if !self.bag.bagProducts.isEmpty {
                    Text("Other products you might like")
                        .font(Font.custom("Poppins-SemiBold", size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .trailing], 20)
                    
    //                Spacer()
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 20) {
                            ForEach(self.viewModel.similarProducts, id: \.id) { product in
                                ProductCardView(product: product)
                            }
                        }
                        .padding(50)
                    }
                    .padding(-50)
                    .padding([.leading, .trailing], 20)
                }
            }
        }
        .background(Color(.Colors.Backgrounds.primary).ignoresSafeArea(.all))
        .safeAreaInset(edge: .bottom) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Total")
                        .font(Font.custom("Poppins-Regular", size: 14))
                        .foregroundStyle(Color.Colors.Fills.tertiary)
                    Text("$\(self.bag.total)")
                        .font(Font.custom("Poppins-SemiBold", size: 20))
                        .foregroundStyle(Color.Colors.Brand.accent)
                }
                
                Button {
                } label: {
                    Text("Proceed to checkout")
                }
                .buttonStyle(PrimaryButton(width: .infinity))
            }
            .padding()
            .background {
                Color.white.ignoresSafeArea()
            }
            .overlay(Rectangle().frame(height: 1).padding(.top, -1).foregroundStyle(Color.Colors.Fills.quinary), alignment: .top)
        }
        .onAppear {
            self.bag.total = 0
            self.bag.totalItems = 0
            for bagProduct in bag.bagProducts {
                self.bag.total += Int(bagProduct.product.defaultPrice) * bagProduct.quantity
                self.bag.totalItems += bagProduct.quantity
            }
        }
        .onChange(of: bag.bagProducts) {
            print("Bag product changed!")
            self.bag.total = 0
            self.bag.totalItems = 0
            for bagProduct in bag.bagProducts {
                self.bag.total += Int(bagProduct.product.defaultPrice) * bagProduct.quantity
                self.bag.totalItems += bagProduct.quantity
            }
            Task {
                try await self.viewModel.fetchSimilarProducts(categories: self.bag.categories)
            }
        }
    }
}
