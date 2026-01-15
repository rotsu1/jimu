//
//  SetInputRowView.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import SwiftUI

/// セット入力行（重量・回数・完了チェック）
struct SetInputRowView: View {
    let setNumber: Int
    @State var weight: Double
    @State var reps: Int
    @State var isCompleted: Bool
    
    let onWeightChange: (Double) -> Void
    let onRepsChange: (Int) -> Void
    let onCompletedChange: (Bool) -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // セット番号
            Text("\(setNumber)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            // 重量入力
            HStack(spacing: 4) {
                TextField("0", value: $weight, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .fontWeight(.medium)
                    .frame(width: 56)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .onChange(of: weight) { _, newValue in
                        onWeightChange(newValue)
                    }
                
                Text("kg")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 回数入力
            HStack(spacing: 4) {
                TextField("0", value: $reps, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .fontWeight(.medium)
                    .frame(width: 48)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .onChange(of: reps) { _, newValue in
                        onRepsChange(newValue)
                    }
                
                Text("回")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 完了チェックボックス
            Button(action: {
                isCompleted.toggle()
                onCompletedChange(isCompleted)
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isCompleted ? .green : .secondary)
            }
            
            // 削除ボタン
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .foregroundColor(.red.opacity(0.7))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    VStack(spacing: 8) {
        SetInputRowView(
            setNumber: 1,
            weight: 60,
            reps: 10,
            isCompleted: true,
            onWeightChange: { _ in },
            onRepsChange: { _ in },
            onCompletedChange: { _ in },
            onDelete: {}
        )
        SetInputRowView(
            setNumber: 2,
            weight: 65,
            reps: 8,
            isCompleted: false,
            onWeightChange: { _ in },
            onRepsChange: { _ in },
            onCompletedChange: { _ in },
            onDelete: {}
        )
        SetInputRowView(
            setNumber: 3,
            weight: 70,
            reps: 6,
            isCompleted: false,
            onWeightChange: { _ in },
            onRepsChange: { _ in },
            onCompletedChange: { _ in },
            onDelete: {}
        )
    }
    .padding()
    .background(Color(.systemGray6))
    .preferredColorScheme(.dark)
}
