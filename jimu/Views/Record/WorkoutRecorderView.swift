//
//  WorkoutRecorderView.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import SwiftUI

/// トレーニング記録画面
struct WorkoutRecorderView: View {
    @Binding var selectedTab: MainTabView.Tab // MainTabViewから受け取るBinding
    @Environment(WorkoutRecorderViewModel.self) private var viewModel
    @State private var showCancelConfirmation = false
    @State private var showAddRoutineSheet = false // 追加
    @State private var showExerciseMenu = false // 追加
    @State private var showReorderSheet = false // 追加
    @State private var activeExerciseForMenu: Exercise? // 追加
    
    // プレビュー用イニシャライザ（Bindingを使わない場合用）
    init(selectedTab: Binding<MainTabView.Tab>? = nil) {
        if let selectedTab = selectedTab {
            self._selectedTab = selectedTab
        } else {
            self._selectedTab = .constant(.record)
        }
    }
    
    var body: some View {
        NavigationStack {
            startView
                .sheet(isPresented: $showAddRoutineSheet) {
                    RoutineCreatorView()
                }
                .fullScreenCover(isPresented: Bindable(viewModel).isWorkoutExpanded) {
                    NavigationStack {
                        ZStack {
                            if viewModel.showCompletionAnimation {
                                completionView
                            } else {
                                activeWorkoutView
                            }
                        }
                        .toolbar {
                            // トレーニング中のみ（完了画面以外）表示
                            if !viewModel.showCompletionAnimation {
                                ToolbarItem(placement: .topBarLeading) {
                                    Button(action: {
                                        viewModel.isWorkoutExpanded = false
                                        // 最小化して他のタブを見たい場合はここで切り替えることも可能
                                        // selectedTab = .home 
                                    }) {
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.primary)
                                            .font(.system(size: 16, weight: .semibold))
                                            .frame(width: 32, height: 32)
                                            .contentShape(Rectangle()) // タップ領域を広げる
                                    }
                                }
                                
                                ToolbarItem(placement: .principal) {
                                    VStack(spacing: 2) {
                                        Text(viewModel.formattedElapsedTime)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .monospacedDigit()
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.green, .mint],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                        
                                        Text("\(viewModel.selectedExercises.count)種目 • \(viewModel.completedSetsCount)/\(viewModel.totalSetsCount)セット")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .sheet(isPresented: Bindable(viewModel).showExercisePicker) {
                            ExercisePickerView { exercise in
                                viewModel.addExercise(exercise)
                            }
                        }
                        .sheet(isPresented: Bindable(viewModel).showRestTimerPicker) {
                            // 休憩タイマー設定シート
                            RestTimerPickerSheet(duration: Bindable(viewModel).restTimerDuration)
                                .presentationDetents([.height(300)])
                        }
                        .sheet(isPresented: $showReorderSheet) {
                            ExerciseReorderView(exercises: Bindable(viewModel).selectedExercises)
                        }
                        .sheet(isPresented: $showExerciseMenu) {
                            // 種目メニューシート（ハーフモーダル）
                            VStack(spacing: 0) {
                                Text("種目メニュー")
                                    .font(.headline)
                                    .padding(.top)
                                    .padding(.bottom, 20)
                                
                                VStack(spacing: 0) {
                                    Button(action: {
                                        showExerciseMenu = false
                                        // シートが閉じてから次のシートを開くために少し遅延させる
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            showReorderSheet = true
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.up.arrow.down")
                                                .frame(width: 24)
                                                Text("並び替え・削除")
                                                Spacer()
                                        }
                                        .padding()
                                        .foregroundColor(.primary)
                                    }
                                    
                                    Divider()
                                        .padding(.leading)
                                    
                                    if let exercise = activeExerciseForMenu {
                                        Button(action: {
                                            withAnimation {
                                                viewModel.removeExercise(exercise)
                                            }
                                            showExerciseMenu = false
                                        }) {
                                            HStack {
                                                Image(systemName: "trash")
                                                .frame(width: 24)
                                                Text("この種目を削除")
                                                Spacer()
                                            }
                                            .padding()
                                            .foregroundColor(.red)
                                        }
                                    }
                                }
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                                
                                Button(action: {
                                    showExerciseMenu = false
                                }) {
                                    Text("キャンセル")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color(.systemGray5))
                                        .foregroundColor(.primary)
                                        .cornerRadius(12)
                                }
                                .padding()
                            }
                            .presentationDetents([.height(250)])
                            .presentationDragIndicator(.visible)
                            .background(Color(.systemGroupedBackground))
                        }
                        .confirmationDialog("トレーニングを中止しますか？", isPresented: $showCancelConfirmation, titleVisibility: .visible) {
                            Button("中止する", role: .destructive) {
                                viewModel.cancelWorkout()
                            }
                            Button("続ける", role: .cancel) {}
                        }
                    }
                }
        }
    }
    
    // MARK: - Start View
    
    private var startView: some View {
        VStack(spacing: 0) {
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
            
            // ルーティンリスト（ボタンの上に表示）
            if !viewModel.savedRoutines.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("マイ・ルーティン")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        ForEach(viewModel.savedRoutines) { routine in
                            Button(action: {
                                viewModel.startWorkout(from: routine)
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(routine.name)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        
                                        Text("\(routine.exercises.count)種目")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(.tertiaryLabel))
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
            }

            Spacer()
            
            Button(action: {
                showAddRoutineSheet = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.square.on.square")
                    Text("ルーティンを追加")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
            
            Button(action: {
                if viewModel.isWorkoutActive {
                    viewModel.isWorkoutExpanded = true
                } else {
                    viewModel.startWorkout()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: viewModel.isWorkoutActive ? "arrow.triangle.2.circlepath" : "play.fill")
                    Text(viewModel.isWorkoutActive ? "トレーニングに戻る" : "トレーニング開始")
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
            .padding(.bottom, 100) // タブバーに隠れないようにパディングを増やす
        }
    }
    
    // MARK: - Active Workout View
    
    private var activeWorkoutView: some View {
        VStack(spacing: 0) {
            // ストップウォッチヘッダーはナビゲーションバーに移動したため削除
            
            // 休憩タイマーオーバーレイ (アクティブ時のみ表示)
            if viewModel.isRestTimerActive {
                restTimerOverlay
            }
            
            if viewModel.selectedExercises.isEmpty {
                emptyExerciseView
            } else {
                exerciseList
            }
            
            // 下部ボタン
            bottomButtons
        }
    }
    
    private var restTimerOverlay: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundColor(.white)
                .font(.headline)
            Text("休憩: \(viewModel.formattedRestTime)")
                .font(.headline)
                .foregroundColor(.white)
                .monospacedDigit()
            
            Spacer()
            
            Button(action: {
                viewModel.stopRestTimer()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color.orange)
        .transition(.move(edge: .top))
    }
    
    // stopwatchHeaderは削除（ナビゲーションバーに移動したため）
    
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
        List {
            ForEach(viewModel.selectedExercises) { exercise in
                Section {
                    ForEach(Array(viewModel.sets(for: exercise.id).enumerated()), id: \.element.id) { index, set in
                        SetInputRowView(
                            setNumber: set.setNumber,
                            weight: set.weight,
                            reps: set.reps,
                            isCompleted: set.isCompleted,
                            previousWeight: nil, // TODO: 実際の前回の値を取得して渡す
                            previousReps: nil,   // TODO: 実際の前回の値を取得して渡す
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
                                // SetInputRowView内のonDeleteは使用しない（swipeActionsで削除するため）
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    viewModel.removeSet(for: exercise.id, at: index)
                                }
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
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
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                    }
                } header: {
                    VStack(spacing: 0) {
                        // 種目ヘッダー
                        VStack {
                            HStack {
                                Image(systemName: exercise.muscleGroup.iconName)
                                    .foregroundColor(.green)
                                    .font(.title3)
                                
                                Text(exercise.nameJa)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text(exercise.muscleGroup.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                                
                                Button(action: {
                                    activeExerciseForMenu = exercise
                                    showExerciseMenu = true
                                }) {
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 20))
                                        .foregroundColor(.secondary)
                                        .padding(8)
                                }
                            }
                            .padding(.vertical, 8)
                            
                            // 休憩タイマー設定ボタン
                            Button(action: {
                                viewModel.activeExerciseIdForRestTimer = exercise.id
                                viewModel.showRestTimerPicker = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "timer")
                                        .font(.caption)
                                    Text("休憩タイマー: \(viewModel.formattedRestDuration)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Image(systemName: "chevron.down")
                                        .font(.caption2)
                                }
                                .foregroundColor(.orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .padding(.bottom, 8)
                        }
                        .padding(.horizontal)
                        
                        // カラムヘッダー
                        HStack(spacing: 0) {
                            Text("セット")
                                .frame(width: 44, alignment: .center)
                            Text("前回")
                                .frame(width: 80, alignment: .center)
                            Text("kg")
                                .frame(width: 90, alignment: .center)
                            Text("reps")
                                .frame(width: 80, alignment: .center)
                            Spacer()
                            Text("完了")
                                .frame(width: 40, alignment: .center)
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 14) // 行のパディング(4) + インセット調整(10)
                        .padding(.bottom, 8)
                    }
                    .textCase(nil) // デフォルトの大文字変換を無効化
                    .listRowInsets(EdgeInsets()) // ヘッダーのインセットをリセット
                    .background(Color(.systemGroupedBackground))
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // exerciseCard関数は不要になったため削除
    // (exerciseList内でSectionを使って直接構築しているため)
    
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
        .environment(WorkoutRecorderViewModel())
}

