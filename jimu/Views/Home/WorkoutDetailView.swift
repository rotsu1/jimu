//
//  WorkoutDetailView.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import SwiftUI

/// ワークアウト詳細モーダル
struct WorkoutDetailView: View {
    let item: MockData.TimelineItem
    @State private var currentImageIndex = 0
    
    /// 自分の投稿かどうか
    private var isMyWorkout: Bool {
        item.user.id == MockData.shared.currentUser.id
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // ヘッダー
                headerSection
                
                // コメント
                if !item.workout.note.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("コメント")
                            .font(.headline)
                        
                        Text(item.workout.note)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 画像
                if item.hasImages {
                    imageSection
                }
                
                // トレーニング内容
                exercisesSection
            }
            .padding()
        }
        .navigationTitle("ワークアウト詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isMyWorkout {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: WorkoutEditView(item: item)) {
                        Text("編集")
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 56, height: 56)
                .overlay(
                    Text(String(item.user.username.prefix(1)))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(item.user.username)
                        .font(.headline)
                    
                    if item.user.isPremium {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                
                Text(item.workout.formattedDate + " " + item.workout.formattedTime)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 統計
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.green)
                    Text("\(item.workout.durationMinutes)分")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                
                Text("\(item.sets.count)セット完了")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var imageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("写真")
                .font(.headline)
            
            VStack(spacing: 8) {
                TabView(selection: $currentImageIndex) {
                    ForEach(Array(item.images.enumerated()), id: \.element.id) { index, image in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [.gray.opacity(0.3), .gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(.secondary)
                                    Text("ワークアウト写真 \(index + 1)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            )
                            .tag(index)
                    }
                }
                .frame(height: 250)
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                if item.images.count > 1 {
                    HStack(spacing: 6) {
                        ForEach(0..<item.images.count, id: \.self) { index in
                            Circle()
                                .fill(currentImageIndex == index ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
        }
    }
    
    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("トレーニング内容")
                .font(.headline)
            
            ForEach(groupedSets, id: \.exercise.id) { group in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: group.exercise.muscleGroup.iconName)
                            .foregroundColor(.green)
                            .font(.title3)
                            .frame(width: 24)
                        
                        Text(group.exercise.nameJa)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text(group.exercise.muscleGroup.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                    
                    // セット一覧
                    ForEach(group.sets.sorted { $0.setNumber < $1.setNumber }) { set in
                        HStack {
                            Text("セット \(set.setNumber)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 60, alignment: .leading)
                            
                            Text(set.formattedString)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            if set.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.leading, 32)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
    
    private var groupedSets: [(exercise: Exercise, sets: [WorkoutSet])] {
        var result: [(exercise: Exercise, sets: [WorkoutSet])] = []
        
        for exercise in item.exercises {
            let sets = item.sets.filter { $0.exerciseId == exercise.id }
            if !sets.isEmpty {
                result.append((exercise: exercise, sets: sets))
            }
        }
        
        return result
    }
}

#Preview {
    WorkoutDetailView(item: MockData.shared.timelineItems[0])
        .preferredColorScheme(.dark)
}
