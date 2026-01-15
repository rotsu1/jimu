//
//  TrainingSettingsView.swift
//  jimu
//
//  Created by Jimu Team on 15/1/2026.
//

import SwiftUI
import UIKit // Import UIKit for UIColor

struct TrainingSettingsView: View {
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("defaultTimerDuration") private var defaultTimerDuration = 120 // seconds
    @AppStorage("usePreviousWorkoutValues") private var usePreviousWorkoutValues = true
    @AppStorage("appLanguage") private var appLanguage = "ja"
    @AppStorage("weightUnit") private var weightUnit = "kg"
    @AppStorage("distanceUnit") private var distanceUnit = "km"
    @AppStorage("lengthUnit") private var lengthUnit = "cm"
    
    @State private var showTimerSheet = false
    
    // 0秒(オフ)から5分(300秒)まで5秒刻み
    private let timerOptions = Array(stride(from: 0, through: 300, by: 5))
    
    var body: some View {
        List {
            Section(header: Text("全般")) {
                NavigationLink(destination: SoundSettingsView()) {
                    HStack {
                        Text("サウンド効果")
                        Spacer()
                        Text(soundEnabled ? "オン" : "オフ")
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: {
                    showTimerSheet = true
                }) {
                    HStack {
                        Text("デフォルトタイマー")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(formatDuration(defaultTimerDuration))
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(uiColor: .tertiaryLabel))
                    }
                }
                .foregroundColor(.primary) // Ensure button text doesn't turn blue
            }
            
            Section(header: Text("入力設定"), footer: Text("「前回の値を使用」をオンにすると、同じ種目の前回の記録が自動的に入力されます。オフの場合はルーティンのデフォルト値または空欄になります。")) {
                Toggle("前回の値を使用", isOn: $usePreviousWorkoutValues)
            }
            
            Section(header: Text("言語と単位")) {
                Picker("言語", selection: $appLanguage) {
                    Text("日本語").tag("ja")
                    Text("English").tag("en")
                }
                
                Picker("重量単位", selection: $weightUnit) {
                    Text("kg").tag("kg")
                    Text("lbs").tag("lbs")
                }
                
                Picker("距離単位", selection: $distanceUnit) {
                    Text("km").tag("km")
                    Text("miles").tag("miles")
                }
                
                Picker("長さ単位", selection: $lengthUnit) {
                    Text("cm").tag("cm")
                    Text("in").tag("in")
                }
            }
        }
        .navigationTitle("トレーニング設定")
        .sheet(isPresented: $showTimerSheet) {
            VStack {
                Text("デフォルトタイマー時間")
                    .font(.headline)
                    .padding(.top)
                
                Picker("時間", selection: $defaultTimerDuration) {
                    ForEach(timerOptions, id: \.self) { seconds in
                        Text(formatDuration(seconds))
                            .tag(seconds)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                
                Button(action: {
                    showTimerSheet = false
                }) {
                    Text("完了")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .presentationDetents([.height(360)]) // Slightly taller for button
            .presentationDragIndicator(.visible)
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        if seconds == 0 {
            return "オフ"
        }
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        if minutes > 0 {
            if remainingSeconds > 0 {
                return "\(minutes)分 \(remainingSeconds)秒"
            } else {
                return "\(minutes)分"
            }
        } else {
            return "\(remainingSeconds)秒"
        }
    }
}

#Preview {
    NavigationStack {
        TrainingSettingsView()
    }
}
