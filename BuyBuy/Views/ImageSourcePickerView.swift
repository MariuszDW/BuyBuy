//
//  ImageSourcePickerView.swift
//  BuyBuy
//
//  Created by MDW on 28/05/2025.
//

import SwiftUI
import PhotosUI

struct ImageSourcePickerView: View {
    var onImagePicked: (UIImage?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    private let buttonSize = 50.0
    private let buttonPadding = 8.0
    
    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    @State private var isCameraPresented = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 32) {
            HStack(spacing: 32) {
                Button {
                    isCameraPresented = true
                } label: {
                    VStack {
                        Image(systemName: "camera")
                            .resizable()
                            .scaledToFit()
                            .frame(width: buttonSize, height: buttonSize)
                            .foregroundColor(isSimulator ? Color.gray : .bb.accent)
                        Text("Camera")
                            .font(.regularDynamic(style:.body))
                            .foregroundColor(.bb.text.primary)
                    }
                    .padding(buttonPadding)
                    .background(Color.bb.sheet.background)
                    .cornerRadius(8)
                }
                .disabled(isSimulator)
                
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    VStack {
                        Image(systemName: "photo.on.rectangle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: buttonSize, height: buttonSize)
                            .foregroundColor(.bb.accent)
                        Text("Library")
                            .font(.regularDynamic(style:.body))
                            .foregroundColor(.bb.text.primary)
                    }
                    .padding(buttonPadding)
                    .background(Color.bb.sheet.background)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.bb.sheet.section.background)
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraPickerView { image in
                onImagePicked(image)
                dismiss()
            }
            .ignoresSafeArea()
        }
        .onChange(of: selectedPhotoItem) { newItem in
            guard let item = newItem else {
                dismiss()
                return
            }

            Task {
                defer {
                    Task { @MainActor in dismiss() }
                }

                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        onImagePicked(image)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Light") {
    ImageSourcePickerView { image in
        if let image = image {
            print("Selected image: \(image)")
        } else {
            print("No image selected")
        }
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    ImageSourcePickerView { image in
        if let image = image {
            print("Selected image: \(image)")
        } else {
            print("No image selected")
        }
    }
    .preferredColorScheme(.dark)
}
