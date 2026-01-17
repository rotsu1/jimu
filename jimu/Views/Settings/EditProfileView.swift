//
//  EditProfileView.swift
//  jimu
//
//  Created by Jimu Team on 15/1/2026.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Binding var user: Profile
    @Environment(\.dismiss) private var dismiss
    
    // 編集用の一時データ
    @State private var editingName: String = ""
    @State private var editingBio: String = ""
    @State private var editingLocation: String = ""
    @State private var editingBirthDate: Date = Date()
    @State private var showDatePicker = false
    
    // Profile image states
    @State private var profileImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var showImageSourcePicker = false
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var showImageCropper = false
    @State private var pickedImage: UIImage?
    
    var body: some View {
        NavigationStack {
            Form {
                // Profile Image Section
                Section {
                    HStack {
                        Spacer()
                        profileImageView
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
                }
                
                Section(header: Text("基本情報")) {
                    HStack {
                        Text("名前")
                        Spacer()
                        TextField("名前", text: $editingName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("場所")
                        Spacer()
                        TextField("場所", text: $editingLocation)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    DatePicker("生年月日", selection: $editingBirthDate, displayedComponents: .date)
                }
                
                Section(header: Text("自己紹介")) {
                    TextEditor(text: $editingBio)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("プロフィール編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveProfile()
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                loadUserData()
            }
            .sheet(isPresented: $showImageSourcePicker) {
                ImageSourcePickerSheet(
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
    
    private func loadUserData() {
        editingName = user.username
        editingBio = user.bio
        editingLocation = user.location
        editingBirthDate = user.birthDate
    }
    
    private func saveProfile() {
        user.username = editingName
        user.bio = editingBio
        user.location = editingLocation
        user.birthDate = editingBirthDate
        // TODO: Save profile image to storage
        dismiss()
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
                            
                            Text(String(editingName.prefix(1).uppercased()))
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                
                // Edit badge
                ZStack {
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: 36, height: 36)
                    
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .semibold))
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
}

// MARK: - Image Source Picker Sheet

struct ImageSourcePickerSheet: View {
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

// MARK: - Camera Image Picker

struct ImagePickerCamera: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerCamera
        
        init(_ parent: ImagePickerCamera) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

#Preview {
    EditProfileView(user: .constant(MockData.shared.currentUser))
}

