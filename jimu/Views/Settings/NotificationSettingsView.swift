//
//  NotificationSettingsView.swift
//  jimu
//
//  Created by Jimu Team on 15/1/2026.
//

import SwiftUI

struct NotificationSettingsView: View {
    @AppStorage("notificationEnabled") private var notificationEnabled = true
    @AppStorage("dailyReminder") private var dailyReminder = false
    @AppStorage("reminderTime") private var reminderTime = Date()
    
    var body: some View {
        List {
            Section {
                Toggle("通知を許可", isOn: $notificationEnabled)
            }
            
            if notificationEnabled {
                Section(header: Text("リマインダー")) {
                    Toggle("デイリーリマインダー", isOn: $dailyReminder)
                    
                    if dailyReminder {
                        DatePicker("通知時間", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section(header: Text("その他")) {
                    Toggle("新しいフォロワー", isOn: .constant(true))
                    Toggle("「いいね」", isOn: .constant(true))
                }
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

