//
//  InterestOnboardingView.swift
//  Cove
//

import SwiftUI

struct InterestOnboardingView: View {
    @StateObject private var viewModel: InterestOnboardingViewModel

    init(appState: AppState) {
        _viewModel = StateObject(wrappedValue: InterestOnboardingViewModel(appState: appState))
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            contentSection
            bottomSection
        }
        .background(Color.Colors.Backgrounds.primary.ignoresSafeArea(.all))
        .task { await viewModel.fetchCategories() }
    }

    private var headerSection: some View {
        VStack(spacing: Spacing.xl) {
            Text("Cove.")
                .font(.custom("Gazpacho-Heavy", size: 40))
                .foregroundStyle(Color.Colors.Text.primary)

            SpectrumDivider()

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("What are you into?")
                    .font(.custom("Lato-Bold", size: 28))
                    .foregroundStyle(Color.Colors.Text.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Pick categories that match your style. We'll use them to personalize your home feed.")
                    .font(.custom("Lato-Regular", size: 14))
                    .foregroundStyle(Color.Colors.Text.tertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.xl)
        .padding(.bottom, Spacing.lg)
    }

    @ViewBuilder
    private var contentSection: some View {
        if viewModel.isLoading {
            Spacer()
            ProgressView()
            Spacer()
        } else if viewModel.sections.isEmpty {
            Spacer()
            Text("Couldn't load categories.")
                .font(.custom("Lato-Regular", size: 14))
                .foregroundStyle(Color.Colors.Text.tertiary)
            Button("Try again") {
                Task { await viewModel.fetchCategories() }
            }
            .font(.custom("Lato-Bold", size: 14))
            .foregroundStyle(Color.Colors.Brand.accent)
            Spacer()
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: Spacing.xl) {
                    ForEach(viewModel.sections) { section in
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text(section.name)
                                .font(.custom("Lato-Bold", size: 16))
                                .foregroundStyle(Color.Colors.Text.primary)

                            ChipGrid(
                                leaves: section.leaves,
                                selectedIDs: viewModel.selectedIDs,
                                selectedFill: section.selectedFill,
                                selectedText: section.selectedText
                            ) { id in
                                viewModel.toggle(id: id)
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.md)
            }
        }
    }

    private var bottomSection: some View {
        VStack(spacing: Spacing.md) {
            if let error = viewModel.serverError {
                Text(error)
                    .font(.custom("Lato-Regular", size: 12))
                    .foregroundStyle(Color.Colors.Support.Error.fg)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            Button {
                Task { await viewModel.submit() }
            } label: {
                if viewModel.isSubmitting {
                    ProgressView().tint(.white)
                } else {
                    Text("Continue")
                }
            }
            .buttonStyle(PrimaryButton())
            .disabled(!viewModel.canSubmit)

            Button {
                Task { await viewModel.skip() }
            } label: {
                Text("Skip for now")
                    .font(.custom("Lato-Regular", size: 14))
                    .foregroundStyle(Color.Colors.Text.tertiary)
            }

            Text("Don't worry, you can change this later.")
                .font(.custom("Lato-Regular", size: 12))
                .foregroundStyle(Color.Colors.Text.quaternary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.xl)
    }
}

// MARK: - ChipGrid

private struct ChipGrid: View {
    let leaves: [LeafCategory]
    let selectedIDs: Set<String>
    let selectedFill: Color
    let selectedText: Color
    let onTap: (String) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: Spacing.sm)], spacing: Spacing.sm) {
            ForEach(leaves) { leaf in
                CategoryChip(
                    name: leaf.name,
                    isSelected: selectedIDs.contains(leaf.id),
                    selectedFill: selectedFill,
                    selectedText: selectedText
                )
                .onTapGesture { onTap(leaf.id) }
            }
        }
    }
}

// MARK: - CategoryChip

private struct CategoryChip: View {
    let name: String
    let isSelected: Bool
    let selectedFill: Color
    let selectedText: Color

    var body: some View {
        Text(name)
            .font(.custom("Lato-Regular", size: 14))
            .foregroundStyle(isSelected ? selectedText : Color.Colors.Text.primary)
            .lineLimit(1)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(isSelected ? selectedFill : Color.Colors.Fills.quinary)
            .clipShape(Capsule())
            .overlay {
                if !isSelected {
                    Capsule().stroke(Color.Colors.Strokes.primary.opacity(0.3), lineWidth: 1)
                }
            }
            .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

#Preview {
    InterestOnboardingView(appState: AppState())
}
