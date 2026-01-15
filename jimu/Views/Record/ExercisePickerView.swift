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
    
    let onSelect: (Exercise) -> Void
    
    private var filteredExercises: [Exercise] {
        var exercises = MockData.shared.exercises
        
        if let muscleGroup = selectedMuscleGroup {
            exercises = exercises.filter { $0.muscleGroup == muscleGroup }
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
                            onSelect(exercise)
                            dismiss()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: exercise.muscleGroup.iconName)
                                    .foregroundColor(.green)
                                    .font(.title3)
                                    .frame(width: 32)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(exercise.nameJa)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Text(exercise.muscleGroup.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.green)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("種目を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "種目を検索")
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
    ExercisePickerView { exercise in
        print("Selected: \(exercise.nameJa)")
    }
    .preferredColorScheme(.dark)
}
