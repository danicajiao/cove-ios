//
//  ProductCardView.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/6/22.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct ProductCardView: View {
    var product: any Product
    var headerStr: String = "Header"
    var bodyStr: String = "Body"
    var price: Float = 9
    
    @State var favorited: Bool
    @State private var uiImage: UIImage? = nil
    @State private var averageColor: Color = .white // Default background color

    init(product: any Product) {
        self.product = product

//        print("ProductCardView init: \(String(describing: product.id)) favorite: \(String(describing: product.isFavorite))")
 
        self._favorited = State(initialValue: product.isFavorite ?? false)

        if let coffeeProduct = product as? CoffeeProduct {
            // product is a CoffeeProduct
            self.headerStr = coffeeProduct.info.roastery
            self.bodyStr = coffeeProduct.info.name
            self.price = coffeeProduct.defaultPrice
        } else if let musicProduct = product as? MusicProduct {
            // product is a MusicProduct
            self.headerStr = musicProduct.info.artist
            self.bodyStr = musicProduct.info.album
            self.price = musicProduct.defaultPrice
        } else if let apparelProduct = product as? ApparelProduct {
            // product is a ApparelProduct
            self.headerStr = apparelProduct.info.brand
            self.bodyStr = apparelProduct.info.name
            self.price = apparelProduct.defaultPrice
        }
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink(value: Path.product(product)) {
                VStack(spacing: 0) {
                    if let uiImage = uiImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit) // Maintain aspect ratio
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 150)
                            .onAppear {
                                fetchImage()
                            }
                    }
                    
                    VStack (spacing: 6) {
                        VStack (spacing: 0) {
                            Text(headerStr)
                                .font(Font.custom("Lato-Bold", size: 10))
                                .foregroundColor(.grey)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(bodyStr)
                                .font(Font.custom("Lato-Regular", size: 12))
                                .foregroundColor(.grey)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Text("$\(Int(self.price))")
                            .font(Font.custom("Lato-Regular", size: 14))
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(8)
                    .background(.white)
                }
                .frame(maxWidth: .infinity) // Take up the full width of the column
                .frame(height: 235)
                .background(averageColor)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .customShadow()
            }
            .buttonStyle(PlainButtonStyle())
            
            LikeButton(enabled: self.favorited)
                // .shadow(color: .dropShadow, radius: 20)
                .padding(10)
        }
    }

    private func fetchImage() {
        guard let imageURL = URL(string: product.defaultImageURL) else { return }
        let storageRef = Storage.storage().reference(forURL: imageURL.absoluteString)

        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error fetching image: \(error.localizedDescription)")
                return
            }

            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.uiImage = image
                    if let uiColor = image.averageColor {
                        print("✅ Got average color: \(uiColor)")
                        self.averageColor = Color(uiColor) // Convert UIColor to SwiftUI Color
                    } else {
                        print("❌ averageColor returned nil")
                    }
                }
            }
        }
    }
}

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else {
            print("❌ Failed to create CIImage")
            return nil
        }
        
        // Calculate average color for the entire image
        guard let color = averageColor(for: inputImage, in: inputImage.extent) else {
            return nil
        }
        
        // Convert RGB to HSB to boost vibrancy
        let averageUIColor = UIColor(red: color.red, green: color.green, blue: color.blue, alpha: 1.0)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        averageUIColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        // Boost saturation and brightness for vibrant pastels
        let boostedSaturation: CGFloat = 0.1 // Fixed moderate saturation for vibrancy
        let boostedBrightness: CGFloat = 0.98 // Very light brightness for pastel look
        
        return UIColor(hue: hue, saturation: boostedSaturation, brightness: boostedBrightness, alpha: 1.0)
    }
    
    private func averageColor(for inputImage: CIImage, in rect: CGRect) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        let extentVector = CIVector(x: rect.origin.x, y: rect.origin.y, z: rect.size.width, w: rect.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]),
              let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        let red = CGFloat(bitmap[0]) / 255
        let green = CGFloat(bitmap[1]) / 255
        let blue = CGFloat(bitmap[2]) / 255
        let alpha = CGFloat(bitmap[3]) / 255
        
        return (red, green, blue, alpha)
    }
}

struct ProductCardView_Previews: PreviewProvider {
    static let product = ApparelProduct(
        id: "12345aaa",
        createdAt: Timestamp.init(),
        categoryID: "apparel category id",
        defaultPrice: 23,
        defaultImageURL: "some url",
        info: ApparelProduct.ApparelInfo(brand: "Some brand", name: "Some name", colors: []),
        isFavorite: true,
        productDetailsID: "12345"
    )

    static var previews: some View {
        ProductCardView(product: product)
    }
}
