//
//  TrainingSettingsView.swift
//  jimu
//
//  Created by Jimu Team on 15/1/2026.
//

import SwiftUI

struct TrainingSettingsView: View {
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("defaultTimerDuration") private var defaultTimerDuration = 120 // seconds
    @AppStorage("usePreviousWorkoutValues") private var usePreviousWorkoutValues = true
    @AppStorage("appLanguage") private var appLanguage = "ja"
    @AppStorage("weightUnit") private var weightUnit = "kg"
    @AppStorage("distanceUnit") private var distanceUnit = "km"
    @AppStorage("lengthUnit") private var lengthUnit = "cm"
    
    var body: some View {
        List {
            Section(header: Text("全般")) {
                Toggle("サウンド効果", isOn: $soundEnabled)
                
                HStack {
                    Text("デフォルトタイマー")
                    Spacer()
                    // 簡易的にStepperで秒数を変更
                    Stepper("\(defaultTimerDuration)秒", value: $defaultTimerDuration, in: 30...600, step: 30)
                }
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
    }
}

#Preview {
    NavigationStack {
        TrainingSettingsView()
    }
}

