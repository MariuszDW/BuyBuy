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
            if let image = viewModel.image {
                ZoomableImageView(image: image) {
                    dismiss()
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
            }

            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 3)
                    .padding()
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Preview

#Preview("Light") {
    let dataManager = DataManager(repository: MockDataRepository(lists: []),
                                  imageStorage: MockImageStorage())
    let viewModel = FullscreenImageViewModel(imageID: UUID().uuidString,
                                             dataManager: dataManager)
    FullscreenImageView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let dataManager = DataManager(repository: MockDataRepository(lists: []),
                                  imageStorage: MockImageStorage())
    let viewModel = FullscreenImageViewModel(imageID: UUID().uuidString,
                                             dataManager: dataManager)
    FullscreenImageView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
