//
//  ExercisePickerView.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import SwiftUI

/// 種目選択シート
struct ExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedMuscleGroup: MuscleGroup?
    @State private var showCreateExercise = false
    @State private var allExercises: [Exercise] = []
    
    @State private var selectedExercises: [Exercise] = []
    
    let onSelect: ([Exercise]) -> Void
    
    private var filteredExercises: [Exercise] {
        var exercises = allExercises
        
        if let muscleGroup = selectedMuscleGroup {
            exercises = exercises.filter { $0.muscleGroups.contains(muscleGroup) }
        }
        
        if !searchText.isEmpty {
            exercises = exercises.filter { $0.nameJa.localizedCaseInsensitiveContains(searchText) }
        }
        
        return exercises
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 筋肉グループフィルター
                muscleGroupFilter
                
                // 種目リスト
                List {
                    ForEach(filteredExercises) { exercise in
                        Button(action: {
                            toggleSelection(exercise)
                        }) {
                            HStack(spacing: 12) {
                                if let imageData = exercise.customImageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 32, height: 32)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: exercise.muscleGroup.iconName)
                                        .foregroundColor(.green)
                                        .font(.title3)
                                        .frame(width: 32)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(exercise.nameJa)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    HStack(spacing: 4) {
                                        Text(exercise.muscleGroups.map(\.rawValue).joined(separator: ", "))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        if !exercise.tools.isEmpty {
                                            Text("•")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text(exercise.tools.map(\.rawValue).joined(separator: ", "))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                if let index = selectedExercises.firstIndex(where: { $0.id == exercise.id }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 24, height: 24)
                                        Text("\(index + 1)")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.secondary)
                                        .font(.title3)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(.plain)
                
                // 追加ボタン
                if !selectedExercises.isEmpty {
                    VStack {
                        Button(action: {
                            onSelect(selectedExercises)
                            dismiss()
                        }) {
                            Text("\(selectedExercises.count)種目を追加")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .accessibilityIdentifier("addSelectedExercisesButton")
                        .padding()
                    }
                    .background(Color(.systemBackground))
                    .shadow(radius: 2)
                }
            }
            .navigationTitle("種目を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showCreateExercise = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("種目を追加")
                        }
                    }
                    .accessibilityIdentifier("createExerciseButton")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "種目を検索")
            .sheet(isPresented: $showCreateExercise) {
                CreateExerciseView { newExercise in
                    allExercises.append(newExercise)
                    MockData.shared.exercises.append(newExercise)
                    toggleSelection(newExercise) // Automatically select the new exercise
                }
            }
            .onAppear {
                if allExercises.isEmpty {
                    allExercises = MockData.shared.exercises
                }
            }
        }
    }
    
    private func toggleSelection(_ exercise: Exercise) {
        if let index = selectedExercises.firstIndex(where: { $0.id == exercise.id }) {
            selectedExercises.remove(at: index)
        } else {
            selectedExercises.append(exercise)
        }
    }
    
    private var muscleGroupFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "すべて",
                    isSelected: selectedMuscleGroup == nil,
                    action: { selectedMuscleGroup = nil }
                )
                
                ForEach(MuscleGroup.allCases) { muscleGroup in
                    FilterChip(
                        title: muscleGroup.rawValue,
                        icon: muscleGroup.iconName,
                        isSelected: selectedMuscleGroup == muscleGroup,
                        action: { selectedMuscleGroup = muscleGroup }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemGray6))
    }
}

/// フィルターチップ
struct FilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.green : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

#Preview {
    ExercisePickerView { exercises in
        print("Selected: \(exercises.map(\.nameJa).joined(separator: ", "))")
    }
    .preferredColorScheme(.dark)
}
