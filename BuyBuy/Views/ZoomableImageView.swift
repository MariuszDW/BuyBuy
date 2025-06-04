//
//  ZoomableImageView.swift
//  BuyBuy
//
//  Created by MDW on 01/06/2025.
//

import SwiftUI

struct ZoomableImageView: View {
    let image: UIImage
    var backgroundColor: Color = .black
    var onDismiss: (() -> Void)? = nil
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    @State private var screenSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { proxy in
            backgroundColor
                .onAppear {
                    screenSize = proxy.size
                }
                .overlay(
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: scale)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: offset)
                        .gesture(
                            ExclusiveGesture(
                                doubleTapGesture,
                                combinedGesture(screenSize: screenSize)
                            )
                        )
                )
        }
        .ignoresSafeArea()
    }
    
    func combinedGesture(screenSize: CGSize) -> some Gesture {
        SimultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    scale = lastScale * value
                }
                .onEnded { value in
                    scale = max(1, lastScale * value)
                    lastScale = scale
                    offset = clampedOffset(offset, scale: scale, imageSize: image.size, screenSize: screenSize)
                    lastOffset = offset
                },
            DragGesture()
                .onChanged { value in
                    if scale == 1 {
                        // The image is not moved if it is not zoomed in.
                    } else {
                        let proposedOffset = CGSize(
                            width: lastOffset.width + value.translation.width,
                            height: lastOffset.height + value.translation.height
                        )
                        offset = clampedOffset(proposedOffset, scale: scale, imageSize: image.size, screenSize: screenSize)
                    }
                }
                .onEnded { value in
                    if scale == 1 {
                        if value.translation.height > 100 {
                            // View is dismissed when dragged down more than 100 points.
                            onDismiss?()
                        } else {
                            // Return to the initial position with animation.
                            withAnimation(.spring()) {
                                offset = .zero
                                lastOffset = .zero
                            }
                        }
                    } else {
                        let proposedOffset = CGSize(
                            width: lastOffset.width + value.translation.width,
                            height: lastOffset.height + value.translation.height
                        )
                        offset = clampedOffset(proposedOffset, scale: scale, imageSize: image.size, screenSize: screenSize)
                        lastOffset = offset
                    }
                }
        )
    }
    
    var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                if scale > 1 {
                    scale = 1
                    lastScale = 1
                    offset = .zero
                    lastOffset = .zero
                } else {
                    scale = 2
                    lastScale = 2
                }
                offset = clampedOffset(offset, scale: scale, imageSize: image.size, screenSize: screenSize)
                lastOffset = offset
            }
    }
    
    private func clampedOffset(_ offset: CGSize, scale: CGFloat, imageSize: CGSize, screenSize: CGSize) -> CGSize {
        let bounds = maxOffset(scale: scale, imageSize: imageSize, screenSize: screenSize)
        return CGSize(
            width: max(-bounds.width, min(bounds.width, offset.width)),
            height: max(-bounds.height, min(bounds.height, offset.height))
        )
    }
    
    private func maxOffset(scale: CGFloat, imageSize: CGSize, screenSize: CGSize) -> CGSize {
        let aspectRatio = imageSize.width / imageSize.height
        let fittedWidth: CGFloat
        let fittedHeight: CGFloat
        
        if screenSize.width / screenSize.height > aspectRatio {
            fittedHeight = screenSize.height
            fittedWidth = fittedHeight * aspectRatio
        } else {
            fittedWidth = screenSize.width
            fittedHeight = fittedWidth / aspectRatio
        }
        
        let maxX = max((fittedWidth * scale - screenSize.width) / 2, 0)
        let maxY = max((fittedHeight * scale - screenSize.height) / 2, 0)
        
        return CGSize(width: maxX, height: maxY)
    }
}
