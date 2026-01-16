//
//  WorkoutEditView.swift
//  jimu
//
//  Created by Jimu Team on 16/1/2026.
//

import SwiftUI

/// 編集用のセットデータ
struct EditableSet: Identifiable {
    let id = UUID()
    var weight: Double
    var reps: Int
    var setNumber: Int
}

/// 編集用の種目データ
struct EditableExercise: Identifiable {
    let id = UUID()
    let exercise: Exercise
    var sets: [EditableSet]
}

/// ワークアウト編集画面
struct WorkoutEditView: View {
    @Environment(\.dismiss) private var dismiss
    
    let item: MockData.TimelineItem
    
    // 編集状態
    @State private var workoutDate: Date
    @State private var workoutNote: String
    @State private var editableExercises: [EditableExercise]
    
    // UI状態
    @State private var showExercisePicker = false
    @State private var showSaveAlert = false
    @State private var activeExerciseForMenu: EditableExercise?
    @State private var showImagePicker = false
    
    init(item: MockData.TimelineItem) {
        self.item = item
        
        // 初期値を設定
        _workoutDate = State(initialValue: item.workout.startedAt)
        _workoutNote = State(initialValue: item.workout.note)
        
        // 既存のセットから編集用データを構築
        var exercises: [EditableExercise] = []
        for exercise in item.exercises {
            let sets = item.sets.filter { $0.exerciseId == exercise.id }
                .sorted { $0.setNumber < $1.setNumber }
                .map { EditableSet(weight: $0.weight, reps: $0.reps, setNumber: $0.setNumber) }
            exercises.append(EditableExercise(exercise: exercise, sets: sets))
        }
        _editableExercises = State(initialValue: exercises)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if editableExercises.isEmpty {
                emptyExerciseView
            } else {
                exerciseList
            }
            
            bottomButtons
        }
        .navigationTitle("投稿を編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    saveChanges()
                }
                .fontWeight(.semibold)
                .foregroundColor(.green)
            }
        }
        .sheet(isPresented: $showExercisePicker) {
            ExercisePickerView { exercises in
                for exercise in exercises {
                    addExercise(exercise)
                }
            }
        }
        .sheet(item: $activeExerciseForMenu) { editableExercise in
            exerciseMenuSheet(for: editableExercise)
        }
        .alert("保存しました", isPresented: $showSaveAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("投稿の変更が保存されました。")
        }
    }
    
    // MARK: - Empty View
    
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
                showExercisePicker = true
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
    
    // MARK: - Exercise List
    
    private var exerciseList: some View {
        List {
            // 日時セクション
            Section {
                DatePicker(
                    "日時",
                    selection: $workoutDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .environment(\.locale, Locale(identifier: "ja_JP"))
            } header: {
                Text("日時")
            }
            
            // コメントセクション
            Section {
                ZStack(alignment: .topLeading) {
                    if workoutNote.isEmpty {
                        Text("コメントを入力...")
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                    }
                    
                    TextEditor(text: $workoutNote)
                        .frame(minHeight: 80)
                        .scrollContentBackground(.hidden)
                }
            } header: {
                Text("コメント")
            }
            
            // 画像セクション
            Section {
                if item.hasImages {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(item.images) { image in
                                ZStack(alignment: .topTrailing) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray5))
                                        .frame(width: 80, height: 80)
                                        .overlay(
                                            Image(systemName: "photo.fill")
                                                .foregroundColor(.secondary)
                                        )
                                    
                                    Button(action: {
                                        // 画像削除（モック）
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .background(Circle().fill(.white))
                                    }
                                    .offset(x: 6, y: -6)
                                }
                            }
                            
                            // 画像追加ボタン
                            Button(action: {
                                showImagePicker = true
                            }) {
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                    .foregroundColor(.secondary)
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Image(systemName: "plus")
                                            .font(.title2)
                                            .foregroundColor(.secondary)
                                    )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                } else {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo.badge.plus")
                            Text("写真を追加")
                        }
                        .foregroundColor(.green)
                    }
                }
            } header: {
                Text("写真")
            }
            
            // 種目セクション
            ForEach($editableExercises) { $editableExercise in
                Section {
                    ForEach($editableExercise.sets) { $set in
                        EditSetInputRow(
                            setNumber: set.setNumber,
                            weight: $set.weight,
                            reps: $set.reps
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    removeSet(from: editableExercise, set: set)
                                }
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                    
                    // セット追加ボタン
                    Button(action: {
                        addSet(to: editableExercise)
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
                    exerciseHeader(for: editableExercise)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Exercise Header
    
    private func exerciseHeader(for editableExercise: EditableExercise) -> some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: editableExercise.exercise.muscleGroup.iconName)
                    .foregroundColor(.green)
                    .font(.title3)
                
                Text(editableExercise.exercise.nameJa)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(editableExercise.exercise.muscleGroup.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                
                Button(action: {
                    activeExerciseForMenu = editableExercise
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                        .padding(8)
                }
            }
            .padding(.vertical, 8)
            
            // カラムヘッダー
            HStack(spacing: 0) {
                Text("セット")
                    .frame(width: 50, alignment: .center)
                Spacer()
                Text("kg")
                    .frame(width: 100, alignment: .center)
                Text("reps")
                    .frame(width: 100, alignment: .center)
            }
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
            .padding(.bottom, 8)
        }
        .textCase(nil)
        .listRowInsets(EdgeInsets())
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Exercise Menu Sheet
    
    private func exerciseMenuSheet(for editableExercise: EditableExercise) -> some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 20)
            
            VStack(spacing: 0) {
                Button(action: {
                    activeExerciseForMenu = nil
                    withAnimation {
                        removeExercise(editableExercise)
                    }
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
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Button(action: {
                activeExerciseForMenu = nil
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
            
            Spacer()
        }
        .presentationDetents([.height(180)])
        .presentationDragIndicator(.visible)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Bottom Buttons
    
    private var bottomButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                showExercisePicker = true
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
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Actions
    
    private func addExercise(_ exercise: Exercise) {
        let newExercise = EditableExercise(
            exercise: exercise,
            sets: [EditableSet(weight: 0, reps: 0, setNumber: 1)]
        )
        editableExercises.append(newExercise)
    }
    
    private func removeExercise(_ editableExercise: EditableExercise) {
        editableExercises.removeAll { $0.id == editableExercise.id }
    }
    
    private func addSet(to editableExercise: EditableExercise) {
        guard let index = editableExercises.firstIndex(where: { $0.id == editableExercise.id }) else { return }
        
        let lastSet = editableExercises[index].sets.last
        let newSetNumber = (lastSet?.setNumber ?? 0) + 1
        let newWeight = lastSet?.weight ?? 0
        let newReps = lastSet?.reps ?? 0
        
        editableExercises[index].sets.append(
            EditableSet(weight: newWeight, reps: newReps, setNumber: newSetNumber)
        )
    }
    
    private func removeSet(from editableExercise: EditableExercise, set: EditableSet) {
        guard let exerciseIndex = editableExercises.firstIndex(where: { $0.id == editableExercise.id }) else { return }
        editableExercises[exerciseIndex].sets.removeAll { $0.id == set.id }
        
        // セット番号を振り直し
        for i in editableExercises[exerciseIndex].sets.indices {
            editableExercises[exerciseIndex].sets[i].setNumber = i + 1
        }
    }
    
    private func saveChanges() {
        // TODO: 実際のデータ保存処理
        // MockDataの場合はここで保存をシミュレート
        showSaveAlert = true
    }
}

// MARK: - Edit Set Input Row

/// 編集用のセット入力行（チェックボックスなし）
struct EditSetInputRow: View {
    let setNumber: Int
    @Binding var weight: Double
    @Binding var reps: Int
    
    var body: some View {
        HStack(spacing: 0) {
            // セット番号
            Text("\(setNumber)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .center)
            
            Spacer()
            
            // 重量入力
            HStack(spacing: 4) {
                TextField("0", value: $weight, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .fontWeight(.medium)
                    .frame(width: 60, height: 36)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                
                Text("kg")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 100, alignment: .center)
            
            // 回数入力
            HStack(spacing: 4) {
                TextField("0", value: $reps, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .fontWeight(.medium)
                    .frame(width: 60, height: 36)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                
                Text("回")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 100, alignment: .center)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    WorkoutEditView(item: MockData.shared.timelineItems[0])
        .preferredColorScheme(.dark)
}

