//
//  EditUsernameView.swift
//  jimu
//
//  Created by Jimu Team on 15/1/2026.
//

import SwiftUI

struct EditUsernameView: View {
    @Binding var username: String
    @Environment(\.dismiss) private var dismiss
    @State private var editingUsername: String = ""
    
    var body: some View {
        Form {
            Section {
                TextField("ユーザー名", text: $editingUsername)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } header: {
                Text("ユーザー名")
            } footer: {
                Text("ユーザー名は公開されます。")
            }
            
            Section {
                Button(action: {
                    saveUsername()
                }) {
                    Text("更新")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.accentColor)
                .disabled(editingUsername.isEmpty || editingUsername == username)
            }
        }
        .navigationTitle("ユーザー名を変更")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            editingUsername = username
        }
    }
    
    private func saveUsername() {
        // TODO: Validate and save to backend
        username = editingUsername
        dismiss()
    }
}

#Preview {
    NavigationStack {
        EditUsernameView(username: .constant("Ryunosuke"))
    }
}

