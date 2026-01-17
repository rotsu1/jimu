//
//  NotificationSettingsView.swift
//  jimu
//
//  Created by Jimu Team on 15/1/2026.
//

import SwiftUI

struct NotificationSettingsView: View {
    @AppStorage("dailyReminder") private var dailyReminder = false
    @AppStorage("reminderTime") private var reminderTime = Date()
    @AppStorage("newFollowerNotification") private var newFollowerNotification = true
    @AppStorage("likeNotification") private var likeNotification = true
    @AppStorage("commentNotification") private var commentNotification = true
    
    var body: some View {
        List {
            Section(header: Text("リマインダー")) {
                Toggle("デイリーリマインダー", isOn: $dailyReminder)
                
                if dailyReminder {
                    DatePicker("通知時間", selection: $reminderTime, displayedComponents: .hourAndMinute)
                }
            }
            
            Section(header: Text("その他")) {
                Toggle("新しいフォロワー", isOn: $newFollowerNotification)
                Toggle("「いいね」", isOn: $likeNotification)
                Toggle("コメント", isOn: $commentNotification)
            }
        }
        .navigationTitle("通知設定")
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}

