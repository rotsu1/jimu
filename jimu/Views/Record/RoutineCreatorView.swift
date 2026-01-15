//
//  RoutineCreatorView.swift
//  jimu
//
//  Created by Jimu Team on 15/1/2026.
//

import SwiftUI

struct RoutineCreatorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = RoutineCreatorViewModel()
    @Environment(WorkoutRecorderViewModel.self) private var workoutViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("ルーティン名（例：胸の日）", text: $viewModel.routineName)
                } header: {
                    Text("ルーティン名")
                }
                
                ForEach(viewModel.selectedExercises) { routineExercise in
                    Section {
                        // Column Headers
                        HStack(spacing: 0) {
                            Text("セット")
                                .frame(width: 44, alignment: .center)
                            Spacer()
                            Text("kg")
                                .frame(width: 80, alignment: .center)
                            Spacer()
                            Text("reps")
                                .frame(width: 80, alignment: .center)
                            Spacer()
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .listRowInsets(EdgeInsets())
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                        
                        // Sets
                        ForEach(Array(routineExercise.sets.enumerated()), id: \.element.id) { index, set in
                            RoutineSetInputRowView(
                                setNumber: index + 1,
                                weight: set.weight,
                                reps: set.reps,
                                onWeightChange: { viewModel.updateSet(for: routineExercise.id, at: index, weight: $0) },
                                onRepsChange: { viewModel.updateSet(for: routineExercise.id, at: index, reps: $0) }
                            )
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.removeSet(for: routineExercise.id, at: index)
                                } label: {
                                    Label("削除", systemImage: "trash")
                                }
                            }
                        }
                        
                        // Add Set Button
                        Button(action: {
                            viewModel.addSet(for: routineExercise.id)
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("セットを追加")
                            }
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 4)
                        }
                    } header: {
                        // Header
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: routineExercise.exercise.muscleGroup.iconName)
                                    .foregroundColor(.green)
                                Text(routineExercise.exercise.nameJa)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Button(action: {
                                    viewModel.removeExercise(routineExercise)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            
                            // Rest Timer Setting
                            HStack {
                                Button(action: {
                                    viewModel.activeExerciseIdForRestTimer = routineExercise.id
                                    viewModel.showRestTimerPicker = true
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "timer")
                                            .font(.caption)
                                        Text("休憩タイマー: \(viewModel.formattedRestDuration(for: routineExercise))")
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
                                Spacer()
                            }
                        }
                        .padding(.vertical, 8)
                        .textCase(nil) // デフォルトの大文字変換を無効化
                    }
                }
                
                Section {
                    Button(action: {
                        viewModel.showExercisePicker = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("種目を追加")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    }
                }
            }
            .navigationTitle("ルーティン作成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if let routine = viewModel.createRoutine() {
                            workoutViewModel.savedRoutines.append(routine)
                            dismiss()
                        }
                    }
                    .disabled(viewModel.routineName.isEmpty || viewModel.selectedExercises.isEmpty)
                }
            }
            .sheet(isPresented: $viewModel.showExercisePicker) {
                ExercisePickerView { exercise in
                    viewModel.addExercise(exercise)
                }
            }
            .sheet(isPresented: $viewModel.showRestTimerPicker) {
                RestTimerPickerSheet(duration: Bindable(viewModel).activeRestDuration)
                    .presentationDetents([.height(300)])
            }
        }
    }
}

struct RoutineSetInputRowView: View {
    let setNumber: Int
    @State var weight: Double
    @State var reps: Int
    
    let onWeightChange: (Double) -> Void
    let onRepsChange: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Set Number
            Text("\(setNumber)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 44, alignment: .center)
            
            Spacer()
            
            // Weight
            TextField("0", value: $weight, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .font(.body)
                .fontWeight(.medium)
                .frame(width: 80, height: 32)
                .background(Color(.systemGray6))
                .cornerRadius(6)
                .onChange(of: weight) { _, newValue in
                    onWeightChange(newValue)
                }
            
            Spacer()
            
            // Reps
            TextField("0", value: $reps, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.body)
                .fontWeight(.medium)
                .frame(width: 80, height: 32)
                .background(Color(.systemGray6))
                .cornerRadius(6)
                .onChange(of: reps) { _, newValue in
                    onRepsChange(newValue)
                }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
