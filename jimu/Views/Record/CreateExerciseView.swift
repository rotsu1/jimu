//
//  CreateExerciseView.swift
//  jimu
//
//  Created by Jimu Team on 16/1/2026.
//

import SwiftUI
import PhotosUI

struct CreateExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var selectedMuscleGroups: Set<MuscleGroup> = []
    @State private var selectedTools: Set<ExerciseTool> = []
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    var onSave: (Exercise) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("種目名 (例: ベンチプレス)", text: $name)
                        .accessibilityIdentifier("exerciseNameField")
                } header: {
                    Text("種目名")
                }
                
                Section {
                    // Image Picker
                    HStack {
                        Spacer()
                        VStack {
                            if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray5))
                                        .frame(width: 120, height: 120)
                                    
                                    Image(systemName: "camera.fill")
                                        .font(.title)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                Text(selectedImageData == nil ? "画像を選択" : "画像を変更")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                            .onChange(of: selectedItem) { _, newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        selectedImageData = data
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                } header: {
                    Text("画像 (任意)")
                }
                
                Section {
                    NavigationLink(destination: MuscleGroupSelectionView(selectedMuscleGroups: $selectedMuscleGroups)) {
                        HStack {
                            Text("部位を選択")
                            Spacer()
                            if !selectedMuscleGroups.isEmpty {
                                Text("\(selectedMuscleGroups.count)件選択中")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .accessibilityIdentifier("muscleGroupSelector")
                } header: {
                    Text("部位 (複数選択可)")
                }
                
                Section {
                    NavigationLink(destination: ToolSelectionView(selectedTools: $selectedTools)) {
                        HStack {
                            Text("使用器具を選択")
                            Spacer()
                            if !selectedTools.isEmpty {
                                Text("\(selectedTools.count)件選択中")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("使用器具 (複数選択可)")
                }
            }
            .navigationTitle("オリジナル種目を作成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveExercise()
                    }
                    .disabled(name.isEmpty || selectedMuscleGroups.isEmpty)
                    .accessibilityIdentifier("saveExerciseButton")
                }
            }
        }
    }
    
    private func saveExercise() {
        let newExercise = Exercise(
            nameJa: name,
            muscleGroups: Array(selectedMuscleGroups),
            tools: Array(selectedTools),
            customImageData: selectedImageData
        )
        onSave(newExercise)
        dismiss()
    }
}

struct MuscleGroupSelectionView: View {
    @Binding var selectedMuscleGroups: Set<MuscleGroup>
    
    var body: some View {
        List {
            ForEach(MuscleGroup.allCases) { muscle in
                Button(action: {
                    if selectedMuscleGroups.contains(muscle) {
                        selectedMuscleGroups.remove(muscle)
                    } else {
                        selectedMuscleGroups.insert(muscle)
                    }
                }) {
                    HStack {
                        Image(systemName: muscle.iconName)
                        
                        Text(muscle.rawValue)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedMuscleGroups.contains(muscle) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                }
                .accessibilityIdentifier("muscleGroup_\(muscle.rawValue)")
            }
        }
        .navigationTitle("部位を選択")
    }
}

struct ToolSelectionView: View {
    @Binding var selectedTools: Set<ExerciseTool>
    
    var body: some View {
        List {
            ForEach(ExerciseTool.allCases) { tool in
                Button(action: {
                    if selectedTools.contains(tool) {
                        selectedTools.remove(tool)
                    } else {
                        selectedTools.insert(tool)
                    }
                }) {
                    HStack {
                        Image(systemName: tool.iconName)
                        Text(tool.rawValue)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedTools.contains(tool) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
        }
        .navigationTitle("使用器具を選択")
    }
}

#Preview {
    CreateExerciseView { exercise in
        print(exercise)
    }
}
