//
//  WorkoutCongratsView.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import SwiftUI

struct WorkoutCongratsView: View {
    @Environment(WorkoutRecorderViewModel.self) private var viewModel
    var onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.01) // Invisible background to catch taps
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Lottie代用の祝福表示
                Text("🎉")
                    .font(.system(size: 120))
                
                Text("お疲れ様でした！")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("トレーニング完了")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 8) {
                    Text("トレーニング時間: \(viewModel.formattedElapsedTime)")
                        .font(.headline)
                    
                    Text("\(viewModel.selectedExercises.count)種目 / \(viewModel.completedSetsCount)セット完了")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 16)
                
                Spacer()
                
                Text("画面をタップして終了")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 40)
            }
        }
        .transition(.opacity.combined(with: .scale))
        .onTapGesture {
            onDismiss()
        }
    }
}

#Preview {
    WorkoutCongratsView(onDismiss: {})
        .environment(WorkoutRecorderViewModel())
}

