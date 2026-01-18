//
//  WorkoutCompletionView.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import SwiftUI
import PhotosUI

struct WorkoutCompletionView: View {
    @Environment(WorkoutRecorderViewModel.self) private var viewModel
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showDurationPicker = false
    
    var body: some View {
        Form {
            Section {
                TextField("ワークアウト名", text: Bindable(viewModel).completionName, prompt: Text(viewModel.defaultWorkoutName))
                    .accessibilityIdentifier("workoutNameField")
            } header: {
                Text("ワークアウト名")
            }
            
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.completionImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        PhotosPicker(
                            selection: $selectedItems,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            VStack {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                Text("写真を追加")
                                    .font(.caption)
                            }
                            .frame(width: 80, height: 80)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text("写真")
            }
            
            Section {
                TextEditor(text: Bindable(viewModel).completionComment)
                    .frame(minHeight: 100)
            } header: {
                Text("コメント")
            }
            
            Section {
                DatePicker("開始日時", selection: Bindable(viewModel).completionDate, displayedComponents: [.date, .hourAndMinute])
            } header: {
                Text("日時")
            }
            
            Section {
                Button(action: {
                    showDurationPicker = true
                }) {
                    HStack {
                        Text("トレーニング時間")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(formattedDuration)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("トレーニング時間")
            }
            
            Section {
                Toggle("非公開にする", isOn: Bindable(viewModel).isPrivate)
                    .accessibilityIdentifier("privatePostToggle")
            }
            
            Section {
                Button(role: .destructive) {
                    viewModel.cancelWorkout()
                    // dismiss() // ViewModel側でshowCompletionViewをfalseにすることで戻る
                } label: {
                    Text("このワークアウトを削除")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("ワークアウト記録")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    viewModel.saveWorkout()
                }
                .fontWeight(.bold)
                .accessibilityIdentifier("saveWorkoutButton")
            }
        }
        .onChange(of: selectedItems) {
            Task {
                viewModel.completionImages = []
                for item in selectedItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        viewModel.completionImages.append(image)
                    }
                }
            }
        }
        .sheet(isPresented: $showDurationPicker) {
            DurationPickerSheet(
                hours: Bindable(viewModel).completionDurationHours,
                minutes: Bindable(viewModel).completionDurationMinutes,
                onDone: {
                    showDurationPicker = false
                }
            )
            .presentationDetents([.height(320)])
        }
    }
    
    private var formattedDuration: String {
        let hours = viewModel.completionDurationHours
        let minutes = viewModel.completionDurationMinutes
        
        if hours > 0 && minutes > 0 {
            return "\(hours)時間\(minutes)分"
        } else if hours > 0 {
            return "\(hours)時間"
        } else {
            return "\(minutes)分"
        }
    }
}

// MARK: - Duration Picker Sheet

struct DurationPickerSheet: View {
    @Binding var hours: Int
    @Binding var minutes: Int
    let onDone: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Spacer()
                
                Text("トレーニング時間")
                    .font(.headline)
                
                Spacer()
            }
            .overlay(alignment: .trailing) {
                Button("完了") {
                    onDone()
                }
                .fontWeight(.semibold)
                .foregroundColor(.green)
            }
            .padding()
            
            Divider()
            
            // Wheel Pickers
            HStack(spacing: 0) {
                // Hours Picker
                Picker("時間", selection: $hours) {
                    ForEach(0..<24, id: \.self) { hour in
                        Text("\(hour)").tag(hour)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                
                Text("時間")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                // Minutes Picker
                Picker("分", selection: $minutes) {
                    ForEach(0..<60, id: \.self) { minute in
                        Text("\(minute)").tag(minute)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                
                Text("分")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    WorkoutCompletionView()
        .environment(WorkoutRecorderViewModel())
}

