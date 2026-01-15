//
//  EditProfileView.swift
//  jimu
//
//  Created by Jimu Team on 15/1/2026.
//

import SwiftUI

struct EditProfileView: View {
    @Binding var user: Profile
    @Environment(\.dismiss) private var dismiss
    
    // 編集用の一時データ
    @State private var editingName: String = ""
    @State private var editingBio: String = ""
    @State private var editingLocation: String = ""
    @State private var editingBirthDate: Date = Date()
    @State private var showDatePicker = false
    
    var body: some View {
        NavigationStack {
            Form {
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
        dismiss()
    }
}

#Preview {
    EditProfileView(user: .constant(MockData.shared.currentUser))
}

