//
//  TimelineCardView.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import SwiftUI

/// タイムラインカード（画像やコメント付きの投稿）
struct TimelineCardView: View {
    let item: MockData.TimelineItem
    @State private var currentImageIndex = 0
    @State private var showingActionSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingPrivacyAlert = false
    @State private var pendingPrivacyState = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ユーザーヘッダー
            HStack(spacing: 12) {
                // アバター
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text(String(item.user.username.prefix(1)))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(item.user.username)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        if item.user.isPremium {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                    
                    Text(relativeTimeString(from: item.workout.startedAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // メニューボタン
                Button(action: {
                    showingActionSheet = true
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
                .sheet(isPresented: $showingActionSheet) {
                    VStack(spacing: 0) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 40, height: 4)
                            .padding(.top, 10)
                            .padding(.bottom, 20)
                        
                        if item.user.id == MockData.shared.currentUser.id {
                            // 編集ボタン
                            Button(action: {
                                showingActionSheet = false
                                // 編集アクション
                            }) {
                                HStack {
                                    Image(systemName: "pencil")
                                        .frame(width: 24)
                                    Text("編集")
                                    Spacer()
                                }
                                .padding()
                                .foregroundColor(.primary)
                            }
                            
                            Divider()
                            
                            // 非公開設定
                            Button(action: {
                                pendingPrivacyState = !item.user.isPrivate
                                showingPrivacyAlert = true
                            }) {
                                HStack {
                                    Image(systemName: item.user.isPrivate ? "lock.open" : "lock")
                                        .frame(width: 24)
                                    Text(item.user.isPrivate ? "公開にする" : "非公開にする")
                                    Spacer()
                                    Toggle("", isOn: Binding(
                                        get: { item.user.isPrivate },
                                        set: { newValue in
                                            pendingPrivacyState = newValue
                                            showingPrivacyAlert = true
                                        }
                                    ))
                                    .labelsHidden()
                                    .allowsHitTesting(false) // ボタンアクションを優先
                                }
                                .padding()
                                .foregroundColor(.primary)
                            }
                            
                            Divider()
                            
                            // 削除ボタン
                            Button(action: {
                                showingDeleteAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .frame(width: 24)
                                    Text("削除")
                                    Spacer()
                                }
                                .padding()
                                .foregroundColor(.red)
                            }
                        } else {
                            // 通報ボタン
                            Button(action: {
                                showingActionSheet = false
                                // 通報アクション
                            }) {
                                HStack {
                                    Image(systemName: "exclamationmark.bubble")
                                        .frame(width: 24)
                                    Text("通報する")
                                    Spacer()
                                }
                                .padding()
                                .foregroundColor(.red)
                            }
                        }
                        
                        Spacer()
                    }
                    .presentationDetents([.height(item.user.id == MockData.shared.currentUser.id ? 220 : 120)])
                    .alert("確認", isPresented: $showingDeleteAlert) {
                        Button("削除", role: .destructive) {
                            showingActionSheet = false
                            // 削除実行
                        }
                        Button("キャンセル", role: .cancel) { }
                    } message: {
                        Text("本当にこの投稿を削除しますか？この操作は取り消せません。")
                    }
                    .alert("公開設定の変更", isPresented: $showingPrivacyAlert) {
                        Button("変更する") {
                            // showingActionSheet = false // モーダルを閉じないように変更
                            // 公開設定変更実行
                        }
                        Button("キャンセル", role: .cancel) { }
                    } message: {
                        Text(pendingPrivacyState ? "この投稿を非公開にしますか？フォロワー以外は見られなくなります。" : "この投稿を公開にしますか？誰でも見られるようになります。")
                    }
                }
            }
            
            // コメント
            if !item.workout.note.isEmpty {
                Text(item.workout.note)
                    .font(.body)
                    .lineLimit(4)
                    .truncationMode(.tail)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // 画像プレースホルダー（Kingfisher代用）
            if item.hasImages {
                VStack(spacing: 8) {
                    TabView(selection: $currentImageIndex) {
                        ForEach(Array(item.images.enumerated()), id: \.element.id) { index, image in
                            RoundedRectangle(cornerRadius: 12)
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
                                            .font(.largeTitle)
                                            .foregroundColor(.secondary)
                                        Text("ワークアウト写真 \(index + 1)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                )
                                .tag(index)
                        }
                    }
                    .frame(height: 200)
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
            
            // トレーニング要約
            HStack(spacing: 16) {
                Label("\(item.workout.durationMinutes)分", systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label("\(item.exercises.count)種目", systemImage: "list.bullet")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label("\(item.sets.count)セット", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // トレーニング内容サマリー
            VStack(alignment: .leading, spacing: 6) {
                ForEach(groupedSets.prefix(5), id: \.exercise.id) { group in
                    HStack(spacing: 8) {
                        Image(systemName: group.exercise.muscleGroup.iconName)
                            .foregroundColor(.green)
                            .font(.caption)
                            .frame(width: 20)
                        
                        Text(group.exercise.nameJa)
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(group.sets.count)セット")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if groupedSets.count > 5 {
                    Text("他\(groupedSets.count - 5)種目")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 28)
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // アクションボタン
            HStack(spacing: 0) {
                ActionButton(icon: "heart", count: Int.random(in: 0...50))
                ActionButton(icon: "bubble.right", count: Int.random(in: 0...10))
                ActionButton(icon: "arrow.2.squarepath", count: Int.random(in: 0...5))
                ActionButton(icon: "square.and.arrow.up", count: nil)
            }
        }
        .padding(16)
        .frame(maxHeight: UIScreen.main.bounds.height * 0.66, alignment: .top)
        .clipped()
    }
    
    private var groupedSets: [(exercise: Exercise, sets: [WorkoutSet], bestSet: WorkoutSet)] {
        var result: [(exercise: Exercise, sets: [WorkoutSet], bestSet: WorkoutSet)] = []
        
        for exercise in item.exercises {
            let sets = item.sets.filter { $0.exerciseId == exercise.id }
            if let bestSet = sets.max(by: { $0.weight < $1.weight }) {
                result.append((exercise: exercise, sets: sets, bestSet: bestSet))
            }
        }
        
        return result
    }
    
    private func relativeTimeString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

/// アクションボタン
struct ActionButton: View {
    let icon: String
    let count: Int?
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.subheadline)
                
                if let count = count, count > 0 {
                    Text("\(count)")
                        .font(.caption)
                }
            }
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    TimelineCardView(item: MockData.shared.timelineItems[0])
        .preferredColorScheme(.dark)
}
