//
//  RestTimerPickerSheet.swift
//  jimu
//
//  Created by Jimu Team on 15/1/2026.
//

import SwiftUI

struct RestTimerPickerSheet: View {
    @Binding var duration: Int
    @Environment(\.dismiss) private var dismiss
    
    // 5秒〜2分(120秒)は5秒刻み
    // 2分〜5分(300秒)は15秒刻み
    private var timerOptions: [Int] {
        var options: [Int] = [0] // 0秒を追加 (「なし」用)
        // 5秒から120秒まで5秒刻み
        for i in stride(from: 5, through: 120, by: 5) {
            options.append(i)
        }
        // 135秒から300秒まで15秒刻み
        for i in stride(from: 135, through: 300, by: 15) {
            options.append(i)
        }
        return options
    }
    
    var body: some View {
        VStack {
            Text("休憩タイマー設定")
                .font(.headline)
                .padding(.top)
            
            Picker("時間", selection: $duration) {
                ForEach(timerOptions, id: \.self) { seconds in
                    Text(formatDuration(seconds))
                        .tag(seconds)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            
            Button(action: {
                dismiss()
            }) {
                Text("完了")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        if seconds == 0 {
            return "なし"
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
    RestTimerPickerSheet(duration: .constant(60))
}

