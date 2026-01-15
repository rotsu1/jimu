//
//  AccountSettingsView.swift
//  jimu
//
//  Created by Jimu Team on 15/1/2026.
//

import SwiftUI

struct AccountSettingsView: View {
    @State private var username: String = "Ryunosuke"
    @State private var showDeleteAlert = false
    @AppStorage("isFaceIDEnabled") private var isFaceIDEnabled = false
    
    var body: some View {
        List {
            Section(header: Text("プロフィール情報")) {
                NavigationLink(destination: EditUsernameView(username: $username)) {
                    HStack {
                        Text("ユーザー名")
                        Spacer()
                        Text(username)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section(header: Text("セキュリティ")) {
                Toggle(isOn: $isFaceIDEnabled) {
                    Label("Face IDでログイン", systemImage: "faceid")
                }
            }
            
            Section {
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Text("アカウント削除")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("アカウント設定")
        .alert("アカウント削除", isPresented: $showDeleteAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("削除", role: .destructive) {
                // アカウント削除処理
            }
        } message: {
            Text("アカウントを削除すると、すべてのデータが完全に削除されます。この操作は取り消せません。")
        }
    }
}

#Preview {
    NavigationStack {
        AccountSettingsView()
    }
}

