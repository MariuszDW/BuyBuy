//
//  FullscreenImageView.swift
//  BuyBuy
//
//  Created by MDW on 01/06/2025.
//

import SwiftUI

struct FullscreenImageView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: FullscreenImageViewModel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZoomableImageView(image: viewModel.image) {
                dismiss()
            }

            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 3)
                    .padding()
            }
        }
    }
}

// MARK: - Preview

#Preview("Light") {
    let viewModel = FullscreenImageViewModel(image: UIImage())
    FullscreenImageView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let viewModel = FullscreenImageViewModel(image: UIImage())
    FullscreenImageView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
