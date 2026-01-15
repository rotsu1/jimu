//
//  WorkoutRecorderView.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import SwiftUI

/// トレーニング記録画面
struct WorkoutRecorderView: View {
    @State private var viewModel = WorkoutRecorderViewModel()
    @State private var showCancelConfirmation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.showCompletionAnimation {
                    completionView
                } else if viewModel.isWorkoutActive {
                    activeWorkoutView
                } else {
                    startView
                }
            }
            .navigationTitle("記録")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showExercisePicker) {
                ExercisePickerView { exercise in
                    viewModel.addExercise(exercise)
                }
            }
            .confirmationDialog("トレーニングを中止しますか？", isPresented: $showCancelConfirmation, titleVisibility: .visible) {
                Button("中止する", role: .destructive) {
                    viewModel.cancelWorkout()
                }
                Button("続ける", role: .cancel) {}
            }
        }
    }
    
    // MARK: - Start View
    
    private var startView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("トレーニングを始めよう")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("種目を追加してトレーニングを記録しましょう")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.startWorkout()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                    Text("トレーニング開始")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
    
    // MARK: - Active Workout View
    
    private var activeWorkoutView: some View {
        VStack(spacing: 0) {
            // ストップウォッチヘッダー
            stopwatchHeader
            
            if viewModel.selectedExercises.isEmpty {
                emptyExerciseView
            } else {
                exerciseList
            }
            
            // 下部ボタン
            bottomButtons
        }
    }
    
    private var stopwatchHeader: some View {
        VStack(spacing: 8) {
            Text(viewModel.formattedElapsedTime)
                .font(.system(size: 56, weight: .light, design: .monospaced))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            HStack(spacing: 24) {
                Label("\(viewModel.selectedExercises.count)種目", systemImage: "list.bullet")
                Label("\(viewModel.completedSetsCount)/\(viewModel.totalSetsCount)セット", systemImage: "checkmark.circle")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemGray6))
    }
    
    private var emptyExerciseView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "plus.circle.dashed")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("種目を追加しましょう")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button(action: {
                viewModel.showExercisePicker = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("種目を追加")
                }
                .fontWeight(.medium)
                .foregroundColor(.green)
            }
            
            Spacer()
        }
    }
    
    private var exerciseList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.selectedExercises) { exercise in
                    exerciseCard(for: exercise)
                }
            }
            .padding()
        }
    }
    
    private func exerciseCard(for exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // 種目ヘッダー
            HStack {
                Image(systemName: exercise.muscleGroup.iconName)
                    .foregroundColor(.green)
                    .font(.title3)
                
                Text(exercise.nameJa)
                    .font(.headline)
                
                Spacer()
                
                Text(exercise.muscleGroup.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                
                Button(action: {
                    viewModel.removeExercise(exercise)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            // セット入力行
            ForEach(Array(viewModel.sets(for: exercise.id).enumerated()), id: \.element.id) { index, set in
                SetInputRowView(
                    setNumber: set.setNumber,
                    weight: set.weight,
                    reps: set.reps,
                    isCompleted: set.isCompleted,
                    onWeightChange: { weight in
                        viewModel.updateSet(for: exercise.id, at: index, weight: weight)
                    },
                    onRepsChange: { reps in
                        viewModel.updateSet(for: exercise.id, at: index, reps: reps)
                    },
                    onCompletedChange: { completed in
                        viewModel.updateSet(for: exercise.id, at: index, isCompleted: completed)
                    },
                    onDelete: {
                        viewModel.removeSet(for: exercise.id, at: index)
                    }
                )
            }
            
            // セット追加ボタン
            Button(action: {
                viewModel.addSet(for: exercise.id)
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("セットを追加")
                }
                .font(.subheadline)
                .foregroundColor(.green)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var bottomButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                viewModel.showExercisePicker = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("種目を追加")
                }
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(12)
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    showCancelConfirmation = true
                }) {
                    Text("中止")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray5))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    viewModel.finishWorkout()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("トレーニング終了")
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Completion View
    
    private var completionView: some View {
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
        }
        .transition(.opacity.combined(with: .scale))
    }
}

#Preview {
    WorkoutRecorderView()
        .preferredColorScheme(.dark)
}
