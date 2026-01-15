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
    let previousWeight: Double? // 前回の重量
    let previousReps: Int? // 前回の回数
    
    let onWeightChange: (Double) -> Void
    let onRepsChange: (Int) -> Void
    let onCompletedChange: (Bool) -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // セット番号 (44pt)
            Text("\(setNumber)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 44, alignment: .center)
            
            // 前回記録 (80pt)
            VStack(alignment: .center, spacing: 2) {
                if let prevWeight = previousWeight, let prevReps = previousReps {
                    Text("\(prevWeight.formatted())kg")
                    Text("x \(prevReps)")
                } else {
                    Text("-")
                }
            }
            .font(.caption2)
            .foregroundColor(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(width: 80, alignment: .center)
            
            // 重量入力 (90pt)
            HStack(spacing: 0) {
                Spacer() // 中央揃えのためのSpacer
                TextField("0", value: $weight, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .fontWeight(.medium)
                    .frame(width: 60, height: 32) // 幅を制限して中央に寄せる
                    .cornerRadius(6)
                    .onChange(of: weight) { _, newValue in
                        onWeightChange(newValue)
                    }
                Spacer() // 中央揃えのためのSpacer
            }
            .frame(width: 90, alignment: .center)
            
            // 回数入力 (80pt)
            HStack(spacing: 0) {
                Spacer() // 中央揃えのためのSpacer
                TextField("0", value: $reps, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .fontWeight(.medium)
                    .frame(width: 60, height: 32) // 幅を制限して中央に寄せる
                    .cornerRadius(6)
                    .onChange(of: reps) { _, newValue in
                        onRepsChange(newValue)
                    }
                Spacer() // 中央揃えのためのSpacer
            }
            .frame(width: 80, alignment: .center)
            
            Spacer()
            
            // 完了チェックボックス (40pt)
            Button(action: {
                isCompleted.toggle()
                onCompletedChange(isCompleted)
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isCompleted ? .green : .secondary)
            }
            .frame(width: 40, alignment: .center)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 4)
    }
}

#Preview {
    VStack {
        SetInputRowView(
            setNumber: 1,
            weight: 60,
            reps: 10,
            isCompleted: true,
            previousWeight: 55,
            previousReps: 10,
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
            previousWeight: 60,
            previousReps: 8,
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
