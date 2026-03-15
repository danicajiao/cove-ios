//
//  ProfileHeaderView.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/15/26.
//

import SwiftUI

struct ProfileHeaderView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(Color.Colors.Fills.secondary)
                .frame(width: 90, height: 90)
                .overlay {
                    if let url = viewModel.photoURL {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                        } placeholder: {
                            initialsView
                        }
                    } else {
                        initialsView
                    }
                }

            VStack(spacing: 4) {
                Text(viewModel.displayName)
                    .font(Font.custom("Gazpacho-Black", size: 22))
                    .foregroundStyle(Color.Colors.Fills.primary)

                Text(viewModel.username)
                    .font(Font.custom("Lato-Regular", size: 14))
                    .foregroundStyle(Color.Colors.Fills.primary)

                if !viewModel.memberSinceText.isEmpty {
                    Text(viewModel.memberSinceText)
                        .font(Font.custom("Lato-Regular", size: 12))
                        .foregroundStyle(Color.Colors.Fills.tertiary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private var initialsView: some View {
        Text(viewModel.initials)
            .font(Font.custom("Gazpacho-Black", size: 30))
            .foregroundStyle(Color.Colors.Fills.primary)
    }
}

struct ProfileHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileHeaderView(viewModel: ProfileViewModel())
            .padding(.horizontal, 20)
            .background(Color.Colors.Backgrounds.primary)
    }
}
