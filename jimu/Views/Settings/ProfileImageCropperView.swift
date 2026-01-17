//
//  ProfileImageCropperView.swift
//  jimu
//
//  Created by Jimu Team on 17/1/2026.
//

import SwiftUI

struct ProfileImageCropperView: View {
    let inputImage: UIImage
    @Binding var croppedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private let circleSize: CGFloat = 280
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Crop area
                    ZStack {
                        // Image
                        Image(uiImage: inputImage)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(scale)
                            .offset(offset)
                            .frame(width: circleSize, height: circleSize)
                            .clipShape(Circle())
                            .gesture(
                                SimultaneousGesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            let delta = value / lastScale
                                            lastScale = value
                                            scale = min(max(scale * delta, 1.0), 5.0)
                                        }
                                        .onEnded { _ in
                                            lastScale = 1.0
                                            constrainOffset()
                                        },
                                    DragGesture()
                                        .onChanged { value in
                                            offset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                        }
                                        .onEnded { _ in
                                            lastOffset = offset
                                            constrainOffset()
                                        }
                                )
                            )
                        
                        // Circle overlay border
                        Circle()
                            .strokeBorder(Color.white.opacity(0.8), lineWidth: 2)
                            .frame(width: circleSize, height: circleSize)
                    }
                    
                    Spacer()
                    
                    // Instructions
                    Text("ドラッグで移動、ピンチで拡大縮小")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.bottom, 24)
                    
                    // Zoom slider
                    HStack(spacing: 16) {
                        Image(systemName: "minus.magnifyingglass")
                            .foregroundColor(.white.opacity(0.7))
                        
                        Slider(value: $scale, in: 1.0...5.0)
                            .tint(.white)
                            .onChange(of: scale) { _, _ in
                                constrainOffset()
                            }
                        
                        Image(systemName: "plus.magnifyingglass")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("写真を調整")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        cropImage()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
    
    private func constrainOffset() {
        // Calculate the maximum offset based on scale
        let imageSize = min(inputImage.size.width, inputImage.size.height)
        let scaledImageSize = circleSize * scale
        let maxOffset = (scaledImageSize - circleSize) / 2
        
        withAnimation(.easeOut(duration: 0.2)) {
            offset = CGSize(
                width: min(max(offset.width, -maxOffset), maxOffset),
                height: min(max(offset.height, -maxOffset), maxOffset)
            )
            lastOffset = offset
        }
    }
    
    private func cropImage() {
        let renderer = ImageRenderer(content: croppedImageView)
        renderer.scale = 3.0
        
        if let uiImage = renderer.uiImage {
            croppedImage = uiImage
        }
        dismiss()
    }
    
    private var croppedImageView: some View {
        Image(uiImage: inputImage)
            .resizable()
            .scaledToFill()
            .scaleEffect(scale)
            .offset(offset)
            .frame(width: circleSize, height: circleSize)
            .clipShape(Circle())
    }
}

#Preview {
    ProfileImageCropperView(
        inputImage: UIImage(systemName: "person.fill")!,
        croppedImage: .constant(nil)
    )
}

