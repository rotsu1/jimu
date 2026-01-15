//
//  ExerciseReorderView.swift
//  jimu
//
//  Created by Jimu Team on 15/1/2026.
//

import SwiftUI

struct ExerciseReorderView: View {
    @Binding var exercises: [WorkoutSessionExercise]
    @Environment(\.dismiss) private var dismiss
    @State private var editMode: EditMode = .active
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(exercises) { sessionExercise in
                    HStack {
                        Image(systemName: sessionExercise.exercise.muscleGroup.iconName)
                            .foregroundColor(.green)
                        Text(sessionExercise.exercise.nameJa)
                            .font(.headline)
                        Spacer()
                    }
                }
                .onMove(perform: move)
                .onDelete(perform: delete)
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("種目の並び替え")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        exercises.move(fromOffsets: source, toOffset: destination)
    }
    
    private func delete(at offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
    }
}

#Preview {
    ExerciseReorderView(exercises: .constant([
        WorkoutSessionExercise(exercise: MockData.shared.exercises[0]),
        WorkoutSessionExercise(exercise: MockData.shared.exercises[1])
    ]))
}
