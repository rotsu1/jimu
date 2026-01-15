//
//  AccountSettingsView.swift
//  jimu
//
//  Created by Jimu Team on 15/1/2026.
//

import SwiftUI

struct AccountSettingsView: View {
    @State private var username: String = "Ryunosuke"
    @State private var email: String = "ryu@example.com"
    @State private var isGoogleLinked = false
    @State private var isAppleLinked = true
    @State private var showDeleteAlert = false
    
    var body: some View {
        List {
            Section(header: Text("プロフィール情報")) {
                HStack {
                    Text("ユーザー名")
                    Spacer()
                    TextField("ユーザー名", text: $username)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("メールアドレス")
                    Spacer()
                    TextField("メールアドレス", text: $email)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.emailAddress)
                }
            }
            
            Section(header: Text("セキュリティ")) {
                NavigationLink("パスワード変更") {
                    Text("パスワード変更画面") // TODO: Implement password change view
                }
            }
            
            Section(header: Text("外部アカウント連携")) {
                Toggle(isOn: $isGoogleLinked) {
                    Label("Google", systemImage: "g.circle")
                }
                
                Toggle(isOn: $isAppleLinked) {
                    Label("Apple", systemImage: "apple.logo")
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

