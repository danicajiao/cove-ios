//
//  Color+Extensions.swift
//  Cove
//
//  Created by GitHub Copilot on 2/1/26.
//

import SwiftUI

// MARK: - Color Extension
extension Color {
    // Brand
    static let accent = Color("accent")
    
    // Text
    static let textPrimary = Color("textPrimary")
    static let textSecondary = Color("textSecondary")
    static let textTertiary = Color("textTertiary")
    
    // Background
    static let backgroundPrimary = Color("backgroundPrimary")
    static let backgroundSecondary = Color("backgroundSecondary")
    
    // Interactive
    static let buttonPrimary = Color("buttonPrimary")
    static let buttonSecondary = Color("buttonSecondary")
    
    // Borders & Shadows
    static let borderPrimary = Color("borderPrimary")
    static let borderSecondary = Color("borderSecondary")
    static let shadow = Color("shadow")
    
    // Feedback
    static let star = Color("star")
    
    // Categories
    static let categoryFruity = Color("categoryFruity")
    static let categoryChoco = Color("categoryChoco")
    static let categoryCitrus = Color("categoryCitrus")
    static let categoryEarthy = Color("categoryEarthy")
    static let categoryFloral = Color("categoryFloral")
    
    // Spectrum
    static let spectrumRed = Color("spectrumRed")
    static let spectrumOrange = Color("spectrumOrange")
    static let spectrumYellow = Color("spectrumYellow")
    static let spectrumGreen = Color("spectrumGreen")
    static let spectrumBlue = Color("spectrumBlue")
    static let spectrumViolet = Color("spectrumViolet")
}

// MARK: - ShapeStyle Extension
// Enables dot syntax like .fill(.textPrimary) instead of .fill(Color.textPrimary)
extension ShapeStyle where Self == Color {
    static var accent: Color { .accent }
    
    static var textPrimary: Color { .textPrimary }
    static var textSecondary: Color { .textSecondary }
    static var textTertiary: Color { .textTertiary }
    
    static var backgroundPrimary: Color { .backgroundPrimary }
    static var backgroundSecondary: Color { .backgroundSecondary }
    
    static var buttonPrimary: Color { .buttonPrimary }
    static var buttonSecondary: Color { .buttonSecondary }
    
    static var borderPrimary: Color { .borderPrimary }
    static var borderSecondary: Color { .borderSecondary }
    static var shadow: Color { .shadow }
    
    static var star: Color { .star }
    
    static var categoryFruity: Color { .categoryFruity }
    static var categoryChoco: Color { .categoryChoco }
    static var categoryCitrus: Color { .categoryCitrus }
    static var categoryEarthy: Color { .categoryEarthy }
    static var categoryFloral: Color { .categoryFloral }
    
    static var spectrumRed: Color { .spectrumRed }
    static var spectrumOrange: Color { .spectrumOrange }
    static var spectrumYellow: Color { .spectrumYellow }
    static var spectrumGreen: Color { .spectrumGreen }
    static var spectrumBlue: Color { .spectrumBlue }
    static var spectrumViolet: Color { .spectrumViolet }
}

// MARK: - Legacy Aliases
// Backward compatibility for old naming conventions
extension Color {
    static var primaryText: Color { .textPrimary }
    static var grey: Color { .textSecondary }
    static var background: Color { .backgroundPrimary }
    static var backdrop: Color { .backgroundSecondary }
    static var dropShadow: Color { .shadow }
    static var fruityGradient: Color { .categoryFruity }
    static var chocoGradient: Color { .categoryChoco }
    static var citrusGradient: Color { .categoryCitrus }
    static var earthyGradient: Color { .categoryEarthy }
    static var floralGradient: Color { .categoryFloral }
}

extension ShapeStyle where Self == Color {
    static var primaryText: Color { .textPrimary }
    static var grey: Color { .textSecondary }
    static var background: Color { .backgroundPrimary }
    static var backdrop: Color { .backgroundSecondary }
    static var dropShadow: Color { .shadow }
    static var fruityGradient: Color { .categoryFruity }
    static var chocoGradient: Color { .categoryChoco }
    static var citrusGradient: Color { .categoryCitrus }
    static var earthyGradient: Color { .categoryEarthy }
    static var floralGradient: Color { .categoryFloral }
}
