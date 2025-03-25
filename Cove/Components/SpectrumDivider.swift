//
//  SpectrumDivider.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/23/25.
//

import SwiftUI

struct SpectrumDivider: View {
    @State private var animateGradient = false

    let spectrum: [Color] = [
        .spectrumRed,
        .spectrumOrange,
        .spectrumYellow,
        .spectrumGreen,
        .spectrumBlue,
        .spectrumViolet,
        .spectrumRed,
        .spectrumOrange,
        .spectrumYellow,
        .spectrumGreen,
        .spectrumBlue,
        .spectrumViolet,
        .spectrumRed
    ]
    
    var body: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: spectrum,
                    startPoint: UnitPoint(x: animateGradient ? -1 : 0, y: 0.5),
                    endPoint: UnitPoint(x: animateGradient ? 1 : 2, y: 0.5)
                )
            )
            .frame(height: 4)
            .onAppear {
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
            }
    }
}

#Preview {
    SpectrumDivider()
}
