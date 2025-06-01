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
    private let presentationHeight = 200
    
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
        VStack(spacing: 36) {
            HStack {
                Spacer()
                
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
                            .foregroundColor(.bb.text.primary)
                    }
                    .padding(.vertical, buttonPadding)
                    .padding(.horizontal, buttonPadding + buttonPadding)
                    .background(Color.bb.sheet.background)
                    .cornerRadius(8)
                }
                .disabled(isSimulator)
                
                Spacer()
                
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    VStack {
                        Image(systemName: "photo.on.rectangle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: buttonSize, height: buttonSize)
                            .foregroundColor(.bb.accent)
                        Text("Library")
                            .foregroundColor(.bb.text.primary)
                    }
                    .padding(.vertical, buttonPadding)
                    .padding(.horizontal, buttonPadding + buttonPadding)
                    .background(Color.bb.sheet.background)
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding(.top, 32)
            
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(.bb.accent)
            .padding(.bottom, 12)
        }
        .background(Color.bb.sheet.section.background)
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraPickerView { image in
                onImagePicked(image)
                dismiss()
            }
            .ignoresSafeArea()
        }
        .onChange(of: selectedPhotoItem) { newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    onImagePicked(image)
                }
                dismiss()
            }
        }
        .presentationDetents([.height(180)])
        .presentationDragIndicator(.visible)
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
