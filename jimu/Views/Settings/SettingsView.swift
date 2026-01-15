//
//  SettingsView.swift
//  jimu
//
//  Created by Jimu Team on 15/1/2026.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isPrivateAccount") private var isPrivateAccount = false
    @AppStorage("appearanceMode") private var appearanceMode = 0 // 0: System, 1: Light, 2: Dark
    @AppStorage("isAppleHealthSyncEnabled") private var isAppleHealthSyncEnabled = false
    
    var body: some View {
        List {
            // アカウント設定
            Section(header: Text("アカウント")) {
                NavigationLink(destination: AccountSettingsView()) {
                    Label("アカウント設定", systemImage: "person.circle")
                }
                
                NavigationLink(destination: PremiumPlanView()) {
                    Label {
                        HStack {
                            Text("プレミアムプラン")
                            Spacer()
                            Text("未加入")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } icon: {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            // 通知設定
            Section(header: Text("通知")) {
                NavigationLink(destination: NotificationSettingsView()) {
                    Label("通知設定", systemImage: "bell")
                }
            }
            
            // プライバシー
            Section(header: Text("プライバシー")) {
                Toggle(isOn: $isPrivateAccount) {
                    Label("鍵アカウント", systemImage: "lock")
                }
            }
            
            // トレーニング
            Section(header: Text("トレーニング")) {
                NavigationLink(destination: TrainingSettingsView()) {
                    Label("トレーニング設定", systemImage: "figure.run")
                }
            }
            
            // 外観
            Section(header: Text("外観")) {
                Picker(selection: $appearanceMode, label: Label("テーマ", systemImage: "paintbrush")) {
                    Text("システム").tag(0)
                    Text("ライト").tag(1)
                    Text("ダーク").tag(2)
                }
                .pickerStyle(.menu) // または .navigationLink などお好みで
            }
            
            // その他
            Section(header: Text("その他")) {
                Toggle(isOn: $isAppleHealthSyncEnabled) {
                    Label("ヘルスケア連携", systemImage: "heart.text.square")
                }
                
                Link(destination: URL(string: "https://apps.apple.com/app/id123456789")!) {
                    Label("レビューを書く", systemImage: "star")
                        .foregroundColor(.primary)
                }
            }
            
            // ログアウト
            Section {
                Button(action: {
                    // ログアウト処理
                }) {
                    Text("ログアウト")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#Preview {
    NavigationStack {
        SettingsView()
    }
}

