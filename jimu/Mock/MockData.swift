//
//  MockData.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import Foundation

/// アプリ全体で使用するダミーデータ
final class MockData {
    static let shared = MockData()
    
    private init() {}
    
    // MARK: - Users
    
    let currentUser = Profile(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        username: "筋トレ太郎",
        bio: "週5でジムに通ってます💪 目標はベンチ100kg！",
        isPrivate: false,
        isPremium: true,
        avatarUrl: nil
    )
    
    lazy var sampleUsers: [Profile] = [
        currentUser,
        Profile(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            username: "マッスル花子",
            bio: "筋トレ女子🏋️‍♀️ 美尻を目指して頑張ってます",
            isPrivate: false,
            isPremium: false
        ),
        Profile(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            username: "プロテイン次郎",
            bio: "タンパク質は裏切らない 🥛",
            isPrivate: false,
            isPremium: true
        ),
        Profile(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            username: "ゴリラジム男",
            bio: "デッドリフト200kg達成！次は220kgへ",
            isPrivate: false,
            isPremium: false
        ),
        Profile(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
            username: "初心者ゆき",
            bio: "筋トレ始めて3ヶ月目🔰 まずは続けることが目標",
            isPrivate: false,
            isPremium: false
        )
    ]
    
    // MARK: - Exercises (種目マスタ)
    
    lazy var exercises: [Exercise] = [
        // 胸
        Exercise(nameJa: "ベンチプレス", muscleGroup: .chest),
        Exercise(nameJa: "インクラインベンチプレス", muscleGroup: .chest),
        Exercise(nameJa: "ダンベルフライ", muscleGroup: .chest),
        Exercise(nameJa: "チェストプレス", muscleGroup: .chest),
        Exercise(nameJa: "ケーブルクロスオーバー", muscleGroup: .chest),
        Exercise(nameJa: "プッシュアップ", muscleGroup: .chest),
        
        // 背中
        Exercise(nameJa: "デッドリフト", muscleGroup: .back),
        Exercise(nameJa: "ラットプルダウン", muscleGroup: .back),
        Exercise(nameJa: "ベントオーバーロウ", muscleGroup: .back),
        Exercise(nameJa: "シーテッドロウ", muscleGroup: .back),
        Exercise(nameJa: "懸垂（チンニング）", muscleGroup: .back),
        Exercise(nameJa: "ワンハンドロウ", muscleGroup: .back),
        
        // 脚
        Exercise(nameJa: "スクワット", muscleGroup: .legs),
        Exercise(nameJa: "レッグプレス", muscleGroup: .legs),
        Exercise(nameJa: "レッグエクステンション", muscleGroup: .legs),
        Exercise(nameJa: "レッグカール", muscleGroup: .legs),
        Exercise(nameJa: "ランジ", muscleGroup: .legs),
        Exercise(nameJa: "ヒップスラスト", muscleGroup: .legs),
        Exercise(nameJa: "カーフレイズ", muscleGroup: .legs),
        
        // 肩
        Exercise(nameJa: "ショルダープレス", muscleGroup: .shoulders),
        Exercise(nameJa: "サイドレイズ", muscleGroup: .shoulders),
        Exercise(nameJa: "フロントレイズ", muscleGroup: .shoulders),
        Exercise(nameJa: "リアデルトフライ", muscleGroup: .shoulders),
        Exercise(nameJa: "アップライトロウ", muscleGroup: .shoulders),
        
        // 腕
        Exercise(nameJa: "バーベルカール", muscleGroup: .arms),
        Exercise(nameJa: "ダンベルカール", muscleGroup: .arms),
        Exercise(nameJa: "ハンマーカール", muscleGroup: .arms),
        Exercise(nameJa: "トライセプスプッシュダウン", muscleGroup: .arms),
        Exercise(nameJa: "フレンチプレス", muscleGroup: .arms),
        Exercise(nameJa: "ディップス", muscleGroup: .arms),
        
        // 腹筋
        Exercise(nameJa: "クランチ", muscleGroup: .abs),
        Exercise(nameJa: "レッグレイズ", muscleGroup: .abs),
        Exercise(nameJa: "プランク", muscleGroup: .abs),
        Exercise(nameJa: "アブローラー", muscleGroup: .abs),
        Exercise(nameJa: "ケーブルクランチ", muscleGroup: .abs),
        
        // 有酸素
        Exercise(nameJa: "トレッドミル", muscleGroup: .cardio),
        Exercise(nameJa: "エアロバイク", muscleGroup: .cardio),
        Exercise(nameJa: "ローイングマシン", muscleGroup: .cardio)
    ]
    
    /// 筋肉グループでフィルタリング
    func exercises(for muscleGroup: MuscleGroup) -> [Exercise] {
        exercises.filter { $0.muscleGroup == muscleGroup }
    }
    
    // MARK: - Sample Workouts
    
    lazy var sampleWorkouts: [Workout] = {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            // 今日のワークアウト
            Workout(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
                userId: currentUser.id,
                startedAt: calendar.date(byAdding: .hour, value: -2, to: now)!,
                endedAt: calendar.date(byAdding: .hour, value: -1, to: now)!,
                note: "今日は胸トレ！ベンチプレス自己ベスト更新しました💪",
                status: .completed
            ),
            // 昨日のワークアウト
            Workout(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000002")!,
                userId: sampleUsers[1].id,
                startedAt: calendar.date(byAdding: .day, value: -1, to: now)!,
                endedAt: calendar.date(byAdding: .hour, value: -23, to: now)!,
                note: "脚の日！スクワットきつかった〜でも達成感すごい",
                status: .completed
            ),
            // 2日前
            Workout(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000003")!,
                userId: sampleUsers[2].id,
                startedAt: calendar.date(byAdding: .day, value: -2, to: now)!,
                endedAt: calendar.date(byAdding: .day, value: -2, to: now)!,
                note: "背中トレ完了。ラットプルダウンのフォームを意識した",
                status: .completed
            ),
            // 3日前
            Workout(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000004")!,
                userId: sampleUsers[3].id,
                startedAt: calendar.date(byAdding: .day, value: -3, to: now)!,
                endedAt: calendar.date(byAdding: .day, value: -3, to: now)!,
                note: "デッドリフト200kg成功！！長かった...",
                status: .completed
            ),
            // 4日前（記録のみ、コメントなし）
            Workout(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000005")!,
                userId: currentUser.id,
                startedAt: calendar.date(byAdding: .day, value: -4, to: now)!,
                endedAt: calendar.date(byAdding: .day, value: -4, to: now)!,
                note: "",
                status: .completed
            ),
            // 5日前
            Workout(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000006")!,
                userId: sampleUsers[4].id,
                startedAt: calendar.date(byAdding: .day, value: -5, to: now)!,
                endedAt: calendar.date(byAdding: .day, value: -5, to: now)!,
                note: "初めてのジム！マシンの使い方を教えてもらった🔰",
                status: .completed
            ),
            // 1週間前
            Workout(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000007")!,
                userId: currentUser.id,
                startedAt: calendar.date(byAdding: .day, value: -7, to: now)!,
                endedAt: calendar.date(byAdding: .day, value: -7, to: now)!,
                note: "肩トレ！サイドレイズで追い込んだ",
                status: .completed
            )
        ]
    }()
    
    // MARK: - Sample Workout Sets
    
    lazy var sampleWorkoutSets: [WorkoutSet] = {
        let benchPress = exercises.first { $0.nameJa == "ベンチプレス" }!
        let inclineBench = exercises.first { $0.nameJa == "インクラインベンチプレス" }!
        let dumbellFly = exercises.first { $0.nameJa == "ダンベルフライ" }!
        let squat = exercises.first { $0.nameJa == "スクワット" }!
        let legPress = exercises.first { $0.nameJa == "レッグプレス" }!
        let deadlift = exercises.first { $0.nameJa == "デッドリフト" }!
        let latPulldown = exercises.first { $0.nameJa == "ラットプルダウン" }!
        
        let workout1 = sampleWorkouts[0]
        let workout2 = sampleWorkouts[1]
        let workout3 = sampleWorkouts[2]
        let workout4 = sampleWorkouts[3]
        let workout5 = sampleWorkouts[4]
        
        return [
            // Workout 1 (胸トレ)
            WorkoutSet(workoutId: workout1.id, exerciseId: benchPress.id, weight: 60, reps: 10, setNumber: 1, isCompleted: true),
            WorkoutSet(workoutId: workout1.id, exerciseId: benchPress.id, weight: 70, reps: 8, setNumber: 2, isCompleted: true),
            WorkoutSet(workoutId: workout1.id, exerciseId: benchPress.id, weight: 75, reps: 6, setNumber: 3, isCompleted: true),
            WorkoutSet(workoutId: workout1.id, exerciseId: inclineBench.id, weight: 50, reps: 10, setNumber: 1, isCompleted: true),
            WorkoutSet(workoutId: workout1.id, exerciseId: inclineBench.id, weight: 55, reps: 8, setNumber: 2, isCompleted: true),
            WorkoutSet(workoutId: workout1.id, exerciseId: dumbellFly.id, weight: 16, reps: 12, setNumber: 1, isCompleted: true),
            WorkoutSet(workoutId: workout1.id, exerciseId: dumbellFly.id, weight: 16, reps: 10, setNumber: 2, isCompleted: true),
            
            // Workout 2 (脚トレ)
            WorkoutSet(workoutId: workout2.id, exerciseId: squat.id, weight: 80, reps: 8, setNumber: 1, isCompleted: true),
            WorkoutSet(workoutId: workout2.id, exerciseId: squat.id, weight: 90, reps: 6, setNumber: 2, isCompleted: true),
            WorkoutSet(workoutId: workout2.id, exerciseId: squat.id, weight: 100, reps: 4, setNumber: 3, isCompleted: true),
            WorkoutSet(workoutId: workout2.id, exerciseId: legPress.id, weight: 150, reps: 12, setNumber: 1, isCompleted: true),
            WorkoutSet(workoutId: workout2.id, exerciseId: legPress.id, weight: 170, reps: 10, setNumber: 2, isCompleted: true),
            
            // Workout 3 (背中トレ)
            WorkoutSet(workoutId: workout3.id, exerciseId: latPulldown.id, weight: 50, reps: 12, setNumber: 1, isCompleted: true),
            WorkoutSet(workoutId: workout3.id, exerciseId: latPulldown.id, weight: 55, reps: 10, setNumber: 2, isCompleted: true),
            WorkoutSet(workoutId: workout3.id, exerciseId: latPulldown.id, weight: 60, reps: 8, setNumber: 3, isCompleted: true),
            
            // Workout 4 (デッドリフト)
            WorkoutSet(workoutId: workout4.id, exerciseId: deadlift.id, weight: 150, reps: 5, setNumber: 1, isCompleted: true),
            WorkoutSet(workoutId: workout4.id, exerciseId: deadlift.id, weight: 180, reps: 3, setNumber: 2, isCompleted: true),
            WorkoutSet(workoutId: workout4.id, exerciseId: deadlift.id, weight: 200, reps: 1, setNumber: 3, isCompleted: true),
            
            // Workout 5 (記録のみ)
            WorkoutSet(workoutId: workout5.id, exerciseId: benchPress.id, weight: 65, reps: 10, setNumber: 1, isCompleted: true),
            WorkoutSet(workoutId: workout5.id, exerciseId: benchPress.id, weight: 70, reps: 8, setNumber: 2, isCompleted: true),
            WorkoutSet(workoutId: workout5.id, exerciseId: inclineBench.id, weight: 45, reps: 10, setNumber: 1, isCompleted: true),
            WorkoutSet(workoutId: workout5.id, exerciseId: dumbellFly.id, weight: 14, reps: 12, setNumber: 1, isCompleted: true)
        ]
    }()
    
    /// 特定のワークアウトのセットを取得
    func sets(for workoutId: UUID) -> [WorkoutSet] {
        sampleWorkoutSets.filter { $0.workoutId == workoutId }
    }
    
    /// 特定のワークアウトの種目を取得
    func exercises(for workoutId: UUID) -> [Exercise] {
        let exerciseIds = Set(sets(for: workoutId).map { $0.exerciseId })
        return exercises.filter { exerciseIds.contains($0.id) }
    }
    
    /// 特定ユーザーのワークアウト履歴を取得
    func workouts(for userId: UUID) -> [Workout] {
        sampleWorkouts.filter { $0.userId == userId }.sorted { $0.startedAt > $1.startedAt }
    }
    
    // MARK: - Sample Workout Images
    
    lazy var sampleWorkoutImages: [WorkoutImage] = [
        WorkoutImage(workoutId: sampleWorkouts[0].id, imageUrl: "gym_photo_1"),
        WorkoutImage(workoutId: sampleWorkouts[3].id, imageUrl: "gym_photo_2")
    ]
    
    /// 特定のワークアウトの画像を取得
    func images(for workoutId: UUID) -> [WorkoutImage] {
        sampleWorkoutImages.filter { $0.workoutId == workoutId }
    }
    
    // MARK: - Contribution Data (GitHub草カレンダー用)
    
    /// 過去1年間のトレーニング日を取得（草カレンダー用）
    func contributionData(for userId: UUID) -> [Date: Int] {
        let calendar = Calendar.current
        let now = Date()
        var contributions: [Date: Int] = [:]
        
        // 過去1年間のランダムなトレーニング日を生成
        for dayOffset in 0..<365 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) {
                let dayOfWeek = calendar.component(.weekday, from: date)
                // 週末は休みがち、平日は高確率でトレーニング
                let probability: Double
                if dayOfWeek == 1 || dayOfWeek == 7 {
                    probability = 0.3
                } else {
                    probability = 0.7
                }
                
                if Double.random(in: 0...1) < probability {
                    let normalizedDate = calendar.startOfDay(for: date)
                    contributions[normalizedDate] = Int.random(in: 1...4) // 1-4のトレーニング強度
                }
            }
        }
        
        return contributions
    }
    
    // MARK: - Timeline Data
    
    /// タイムライン表示用のデータ
    struct TimelineItem: Identifiable, Hashable {
        let id = UUID()
        let workout: Workout
        let user: Profile
        let sets: [WorkoutSet]
        let exercises: [Exercise]
        let images: [WorkoutImage]
        
        var hasImages: Bool { !images.isEmpty }
        var hasNote: Bool { !workout.note.isEmpty }
        
        /// 要約テキスト（例: "ベンチプレス 60kg x 10回 他3種目"）
        var summaryText: String {
            guard let firstSet = sets.first,
                  let firstExercise = exercises.first(where: { $0.id == firstSet.exerciseId }) else {
                return "トレーニング記録"
            }
            
            let uniqueExerciseCount = Set(sets.map { $0.exerciseId }).count
            let baseText = "\(firstExercise.nameJa) \(firstSet.formattedString)"
            
            if uniqueExerciseCount > 1 {
                return "\(baseText) 他\(uniqueExerciseCount - 1)種目"
            }
            return baseText
        }
    }
    
    lazy var timelineItems: [TimelineItem] = {
        sampleWorkouts.map { workout in
            let user = sampleUsers.first { $0.id == workout.userId } ?? currentUser
            let sets = self.sets(for: workout.id)
            let exercises = self.exercises(for: workout.id)
            let images = self.images(for: workout.id)
            
            return TimelineItem(
                workout: workout,
                user: user,
                sets: sets,
                exercises: exercises,
                images: images
            )
        }.sorted { $0.workout.startedAt > $1.workout.startedAt }
    }()
}
