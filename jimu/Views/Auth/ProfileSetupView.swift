//
//  ProfileSetupView.swift
//  jimu
//
//  Created by Jimu Team on 17/1/2026.
//

import SwiftUI
import PhotosUI

struct ProfileSetupView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    
    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var location: String = ""
    @State private var birthDate: Date = Date()
    @State private var showDatePicker = false
    
    // Profile image states
    @State private var profileImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var showImageSourcePicker = false
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var showImageCropper = false
    @State private var pickedImage: UIImage?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Fixed Header
                    VStack(spacing: 16) {
                        // Progress indicator
                        HStack(spacing: 8) {
                            Capsule()
                                .fill(Color.green)
                                .frame(height: 4)
                            Capsule()
                                .fill(Color.green)
                                .frame(height: 4)
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 16)
                        
                        VStack(spacing: 8) {
                            Text("プロフィールを設定")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("後からいつでも変更できます")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.bottom, 24)
                    .background(Color(.systemBackground))
                    
                    // Scrollable Content
                    ScrollView {
                        VStack(spacing: 0) {
                            // Profile Image
                            profileImageView
                                .padding(.bottom, 32)
                        
                        // Form Fields
                        VStack(spacing: 24) {
                            // Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text("名前")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                TextField("表示名を入力", text: $name)
                                    .font(.system(size: 17))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                            
                            // Bio
                            VStack(alignment: .leading, spacing: 8) {
                                Text("自己紹介")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                TextField("自己紹介を入力", text: $bio, axis: .vertical)
                                    .font(.system(size: 17))
                                    .lineLimit(3...6)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                            
                            // Location
                            VStack(alignment: .leading, spacing: 8) {
                                Text("場所")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                TextField("場所を入力", text: $location)
                                    .font(.system(size: 17))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                            
                            // Birth Date
                            VStack(alignment: .leading, spacing: 8) {
                                Text("生年月日")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    showDatePicker = true
                                }) {
                                    HStack {
                                        Text(dateFormatter.string(from: birthDate))
                                            .font(.system(size: 17))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "calendar")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal, 32)
                    }
                    // Bottom padding to ensure content is visible above the floating buttons
                    .padding(.bottom, 160)
                }
                .scrollIndicators(.hidden)
                }
                
                // Bottom buttons
                VStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        // Complete Button
                        Button(action: {
                            saveAndComplete()
                        }) {
                            HStack {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("完了")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.green)
                            .cornerRadius(14)
                        }
                        .disabled(authViewModel.isLoading)
                        
                        // Skip Button
                        Button(action: {
                            authViewModel.skipProfileSetup()
                        }) {
                            Text("スキップ")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .disabled(authViewModel.isLoading)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 8)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground).opacity(0),
                                Color(.systemBackground)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 80)
                        .offset(y: -40)
                    )
                }
            }
            .sheet(isPresented: $showDatePicker) {
                DatePickerSheet(
                    selectedDate: $birthDate,
                    isPresented: $showDatePicker
                )
            }
            .sheet(isPresented: $showImageSourcePicker) {
                ProfileImageSourcePickerSheet(
                    isPresented: $showImageSourcePicker,
                    onSelectAlbum: {
                        showPhotoPicker = true
                    },
                    onSelectCamera: {
                        showCamera = true
                    }
                )
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { _, newValue in
                loadPickedImage(newValue)
            }
            .fullScreenCover(isPresented: $showCamera) {
                ImagePickerCamera(image: $pickedImage, isPresented: $showCamera)
                    .ignoresSafeArea()
                    .onDisappear {
                        if pickedImage != nil {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showImageCropper = true
                            }
                        }
                    }
            }
            .fullScreenCover(isPresented: $showImageCropper) {
                if let image = pickedImage {
                    ProfileImageCropperView(inputImage: image, croppedImage: $profileImage)
                }
            }
        }
    }
    
    // MARK: - Profile Image View
    
    private var profileImageView: some View {
        Button(action: {
            showImageSourcePicker = true
        }) {
            ZStack(alignment: .bottomTrailing) {
                // Profile image or placeholder
                Group {
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        // Default gradient avatar
                        ZStack {
                            LinearGradient(
                                colors: [.green, .mint, .teal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 48, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                
                // Camera badge
                ZStack {
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: 40, height: 40)
                    
                    Circle()
                        .fill(Color.green)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .offset(x: 4, y: 4)
            }
        }
        .buttonStyle(.plain)
    }
    
    private func loadPickedImage(_ item: PhotosPickerItem?) {
        guard let item = item else { return }
        
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data = data, let image = UIImage(data: data) {
                        self.pickedImage = image
                        self.selectedItem = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.showImageCropper = true
                        }
                    }
                case .failure:
                    break
                }
            }
        }
    }
    
    private func saveAndComplete() {
        authViewModel.newName = name
        authViewModel.newBio = bio
        authViewModel.newLocation = location
        authViewModel.newBirthDate = birthDate
        authViewModel.profileImage = profileImage
        authViewModel.completeProfileSetup()
    }
}

// MARK: - Date Picker Sheet

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    @State private var tempDate: Date = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "生年月日",
                    selection: $tempDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
            }
            .padding()
            .navigationTitle("生年月日")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        selectedDate = tempDate
                        isPresented = false
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                tempDate = selectedDate
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Image Source Picker Sheet

struct ProfileImageSourcePickerSheet: View {
    @Binding var isPresented: Bool
    var onSelectAlbum: () -> Void
    var onSelectCamera: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(.systemGray3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 20)
            
            // Album button
            Button(action: {
                isPresented = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onSelectAlbum()
                }
            }) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title3)
                        .frame(width: 28)
                    Text("画像アルバム")
                        .font(.body)
                    Spacer()
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            
            Divider()
                .padding(.leading, 60)
            
            // Camera button
            Button(action: {
                isPresented = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onSelectCamera()
                }
            }) {
                HStack {
                    Image(systemName: "camera")
                        .font(.title3)
                        .frame(width: 28)
                    Text("カメラ")
                        .font(.body)
                    Spacer()
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            
            Spacer()
                .frame(height: 24)
            
            // Cancel button
            Button(action: {
                isPresented = false
            }) {
                Text("キャンセル")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.hidden)
    }
}

#Preview {
    ProfileSetupView()
        .environment(AuthViewModel())
}

