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
    
    var body: some View {
        Form {
            Section {
                TextField("ワークアウト名", text: Bindable(viewModel).completionName, prompt: Text(viewModel.defaultWorkoutName))
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
                DatePicker("日時", selection: Bindable(viewModel).completionDate, displayedComponents: [.date, .hourAndMinute])
            } header: {
                Text("日時")
            }
            
            Section {
                Toggle("非公開にする", isOn: Bindable(viewModel).isPrivate)
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
    }
}

#Preview {
    WorkoutCompletionView()
        .environment(WorkoutRecorderViewModel())
}

