//
//  OnboardingView.swift
//  Cove
//
//  Created by Daniel Cajiao on 2/11/24.
//

import SwiftUI

class ImageLoader: ObservableObject {
//    @Published var image: UIImage? = nil
    private let imageNames: [String] = [
        "onboarding-1",
        "onboarding-2",
        "onboarding-3",
        "onboarding-4",
        "onboarding-5"
    ]
    let imageCache = NSCache<NSString, UIImage>()

    init() {
//        self.imageNames = imageNames
        loadImages()
    }

    private func loadImages() {
        imageNames.forEach { name in
//            if let cachedImage = imageCache.object(forKey: name as NSString) {
//                image = cachedImage
//                return
//            }

            guard let image = UIImage(named: name) else { return }
            
            imageCache.setObject(image, forKey: name as NSString)
//            self.image = image
        }
    }
}

// Custom view
struct OnboardingView: View {
//     View properties
    @State private var items: [Item] = [
        .init(title: "For the conscious shopper", subTitle: "Cove strives to create a marketplace where you can find quality, responsibly sourced products from businesses.", imageName: "onboarding-1"),
        .init(title: "We believe in challenging the status quo", subTitle: "We curate businesses and artists that believe in making a difference within modern day means of production.", imageName: "onboarding-2"),
        .init(title: "Support your community and standouts nationwide", subTitle: "See what people are making and raving about in your area as well as different cities across the nation.", imageName: "onboarding-3"),
        .init(title: "Tailored to your likes and interests", subTitle: "Get recommendations based on your likes and interests for a more personalized shopping experience.", imageName: "onboarding-4"),
        .init(title: "Let’s get to know you!", subTitle: "Tell us a bit of what types of products you’re looking for and the values businesses follow.", imageName: "onboarding-5")
    ]

    @State var activeIndex: Int = 0

    // Customization properties
    @State private var showPagingControl: Bool = true
    @State private var disablePagingInteraction: Bool = false
    @State private var pagingSpacing: CGFloat = 20
    @State private var titleScrollSpeed: CGFloat = 0.6
    @State private var stretchContent: Bool = false
    
    @StateObject private var imageLoader = ImageLoader()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(uiImage: imageLoader.imageCache.object(forKey: items[activeIndex].imageName as NSString) ?? UIImage())
                      .resizable()
                      .aspectRatio(contentMode: .fill)
                      .frame(maxWidth: geo.size.width)
                      .ignoresSafeArea()
//                Image(items[activeIndex].imageName)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(maxWidth: geo.size.width)
//                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    
                    CustomPagingSlider(showPagingControl: showPagingControl,
                                       disablePagingInteraction: disablePagingInteraction,
                                       titleScrollSpeed: titleScrollSpeed,
                                       pagingControlSpacing: pagingSpacing,
                                       data: $items,
                                       activeIndex: $activeIndex
                    ) { $item in
                        // Title view
                        VStack(alignment: .center, spacing: 30) {
                            Text(item.title)
                                .font(.custom("Poppins-SemiBold", size: 25))
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)

                            Text(item.subTitle)
                                .font(.custom("Poppins", size: 18))
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                        }
                    }
                    // Use safe area padding to avoid clipping of ScrollView
                    .safeAreaPadding([.horizontal, .top], 35)
                    .background {
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: .black.opacity(0), location: 0.00),
                                Gradient.Stop(color: .black.opacity(0.5), location: 0.20),
                                Gradient.Stop(color: .black, location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                        )
                        .ignoresSafeArea()
                    }
                    
                    
                    //            List {
                    //                Toggle("Show Paging Control", isOn: $showPagingControl)
                    //                Toggle("Disable Page Interaction", isOn: $disablePagingInteraction)
                    //                Toggle("Stretch Content", isOn: $stretchContent)
                    //                Section("Title Scroll Speed") {
                    //                    Slider(value: $titleScrollSpeed)
                    //                }
                    //                Section("Paging Spacing") {
                    //                    Slider(value: $pagingSpacing, in: 20...40)
                    //                }
                    //            }
                    //            .clipShape(.rect(cornerRadius: 15))
                    //            .padding(15)
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
}
