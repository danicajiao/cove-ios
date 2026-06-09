//
//  ItemDetailView.swift
//
//  Created by Daniel Cajiao on 5/8/22.
//

import SwiftUI

/// A preference key to store a view's rect
struct ViewSizeKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue = CGSize.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {}
}

struct ItemDetailView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject var bag: Bag
    @StateObject var viewModel: ItemDetailViewModel

    let itemId: String

    @State private var uiImage: UIImage?
    @State private var averageColor: Color = .Colors.Backgrounds.primary

    @State var count: Int = 1

    init(itemId: String) {
        self.itemId = itemId
        _viewModel = StateObject(wrappedValue: ItemDetailViewModel(itemId: itemId))
    }

    var body: some View {
        Group {
            if let item = viewModel.item {
                // Item loaded, display the details
                ItemDetailContent(
                    item: item,
                    viewModel: viewModel,
                    uiImage: $uiImage,
                    averageColor: $averageColor,
                    count: $count
                )
            } else {
                // Loading state
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Loading item...")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, Spacing.sm)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarHidden(true)
    }
}

/// Extracted content view to handle the item display
private struct ItemDetailContent: View {
    let item: any Item
    @ObservedObject var viewModel: ItemDetailViewModel
    @Binding var uiImage: UIImage?
    @Binding var averageColor: Color
    @Binding var count: Int

    @Environment(\.imageRepository) private var imageRepository
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject var bag: Bag

    // MARK: - Image fetch

    private func fetchImage() async {
        // Fast path: use the pre-signed URL from the API when available.
        if let discoveryItem = item as? DiscoveryItem,
           let variants = discoveryItem.primaryImage,
           let url = variants.url(forTargetPointSize: 300) {
            await loadImage(from: url)
            return
        }

        // Fallback: fetch a signed URL via the image repository (legacy items).
        guard !item.defaultImageURL.isEmpty else { return }
        do {
            let url = try await imageRepository.imageURL(for: item.defaultImageURL)
            await loadImage(from: url)
        } catch {
            print("Error fetching image: \(error.localizedDescription)")
        }
    }

    private func loadImage(from url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                uiImage = image
                if let uiColor = image.averageColor {
                    averageColor = Color(uiColor)
                }
            }
        } catch {
            print("Error loading image: \(error.localizedDescription)")
        }
    }

    // MARK: - Computed properties

    var titleStr: String {
        if let discoveryItem = item as? DiscoveryItem {
            return discoveryItem.name
        } else if let coffeeItem = item as? CoffeeItem {
            return coffeeItem.info.name
        } else if let musicItem = item as? MusicItem {
            return musicItem.info.album
        } else if let apparelItem = item as? ApparelItem {
            return apparelItem.info.name
        }
        return "Title"
    }

    var subtitleStr: String {
        if let discoveryItem = item as? DiscoveryItem {
            return discoveryItem.makerName
        } else if let coffeeItem = item as? CoffeeItem {
            return coffeeItem.info.roastery
        } else if let musicItem = item as? MusicItem {
            return musicItem.info.artist
        } else if let apparelItem = item as? ApparelItem {
            return apparelItem.info.brand
        }
        return "Subtitle"
    }

    var price: Float {
        item.defaultPrice
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .background(
                            Color.Colors.Brand.blue
                                .padding(.top, -1000)
                        )
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .task {
                            await fetchImage()
                        }
                        .background(
                            Color.Colors.Brand.blue
                                .padding(.top, -1000)
                        )
                }

                VStack(spacing: Spacing.xl) {
                    VStack(spacing: Spacing.lg) {
                        VStack(spacing: 0) {
                            Text(titleStr)
                                .font(Font.custom("Gazpacho-Black", size: 20))
                                .foregroundStyle(Color.Colors.Text.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(subtitleStr)
                                .font(Font.custom("Lato-Regular", size: 20))
                                .foregroundStyle(Color.Colors.Text.tertiary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        NavigationLink(destination: Text("Item Reviews!")) {
                            HStack {
                                VStack(alignment: .leading, spacing: Spacing.sm) {
                                    HStack(spacing: Spacing.md) {
                                        Rating(rating: 4)
                                        Text("4.3")
                                            .font(Font.custom("Lato-Regular", size: 14))
                                    }
                                    Text("22 Reviews \(Image(systemName: "chevron.right"))")
                                        .font(Font.custom("Lato-Regular", size: 14))
                                        .foregroundStyle(Color.Colors.Text.tertiary)
                                }

                                Spacer()

                                Circle()
                                    .frame(width: 35, height: 35)
                                    .foregroundStyle(Color.Colors.Fills.inverse)
                                    .overlay {
                                        Circle()
                                            .frame(width: 30, height: 30)
                                    }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(Spacing.lg)
                            .background(Color.Colors.Fills.inverse)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous).stroke(Color.Colors.Strokes.primary, lineWidth: 1))
                        }
                        .buttonStyle(PlainButtonStyle())

                        ItemDetailTabs(viewModel: viewModel)
                    }
                    .padding(.horizontal, Spacing.xl)

                    Rectangle()
                        .frame(height: 3)
                        .foregroundStyle(Color.Colors.Fills.quinary)

                    VStack(spacing: Spacing.lg) {
                        SectionHeader(title: "Similar to this")

                        ScrollView(.horizontal) {
                            HStack(spacing: Spacing.md) {
                                ForEach(viewModel.similarItems, id: \.id) { item in
                                    ItemCard(item: item)
                                }
                            }
                        }
                        .scrollClipDisabled()
                    }
                    .padding(.horizontal, Spacing.xl)
                }
                .padding(.top, Spacing.xxxl)
                .padding(.bottom, Spacing.xl)
                .background(
                    Color.Colors.Fills.inverse
                        .padding(.bottom, -1000)
                )
            }
        }
        .overlay(alignment: .top) {
            HStack {
                BackButton()
                Spacer()
            }
            .padding(.horizontal, Spacing.xl)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Color.Colors.Fills.quinary)
                HStack(spacing: Spacing.lg) {
                    Button {
                        if !bag.bagItems.contains(where: { bagItem in
                            bagItem.item.id == item.id
                        }) {
                            bag.bagItems.append(BagItem(item: item, quantity: count))
                            bag.totalItems += count
                        } else {
                            let indexOfExisting = bag.bagItems.firstIndex { bagItem in
                                bagItem.item.id == item.id
                            }
                            guard let index = indexOfExisting else {
                                print("Failed to get local index of existing item")
                                return
                            }
                            bag.bagItems[index].quantity += count
                            bag.totalItems += count
                        }

                        if !bag.categories.contains(where: { category in
                            category == item.categoryId
                        }) {
                            bag.categories.append(item.categoryId)
                        }

                        print(bag.bagItems)
                    } label: {
                        Text("Add to visit list")
                    }
                    .buttonStyle(PrimaryButton())
                }
                .padding(.vertical, Spacing.sm)
                .padding(.horizontal, Spacing.xl)
                .background {
                    Color.Colors.Fills.inverse.ignoresSafeArea()
                }
            }
        }
    }
}
