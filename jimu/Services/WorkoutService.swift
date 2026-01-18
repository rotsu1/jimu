//
//  WorkoutService.swift
//  jimu
//
//  Created by Jimu Team on 18/1/2026.
//

import Foundation
import Supabase

// MARK: - Workout Session Model (for saving)
/// Represents a complete workout session ready to be saved
struct WorkoutSessionModel: Sendable {
    let userId: UUID
    var name: String?
    var comment: String?
    var imageUrl: String?
    var visibility: VisibilityType
    var startedAt: Date
    var endedAt: Date
    var durationSeconds: Int
    
    /// Exercises with their sets, in order
    var exercises: [SessionExerciseData]
    
    struct SessionExerciseData: Sendable {
        let exerciseId: UUID
        var orderIndex: Int
        var restTimerSeconds: Int?
        var memo: String?
        var sets: [SessionSetData]
    }
    
    struct SessionSetData: Sendable {
        var weight: Double // In user's display unit
        var reps: Int
        var isCompleted: Bool
        var orderIndex: Int
    }
}

// MARK: - Workout Service Errors
enum WorkoutServiceError: LocalizedError, Sendable {
    case notAuthenticated
    case workoutInsertFailed(String)
    case exerciseInsertFailed(String)
    case setInsertFailed(String)
    case rollbackFailed(String)
    case noExercisesProvided
    case fetchFailed(String)
    case deleteFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "ユーザーが認証されていません"
        case .workoutInsertFailed(let message):
            return "ワークアウトの保存に失敗しました: \(message)"
        case .exerciseInsertFailed(let message):
            return "エクササイズの保存に失敗しました: \(message)"
        case .setInsertFailed(let message):
            return "セットの保存に失敗しました: \(message)"
        case .rollbackFailed(let message):
            return "ロールバックに失敗しました: \(message)"
        case .noExercisesProvided:
            return "エクササイズが追加されていません"
        case .fetchFailed(let message):
            return "データの取得に失敗しました: \(message)"
        case .deleteFailed(let message):
            return "削除に失敗しました: \(message)"
        }
    }
}

// MARK: - Workout Service
/// Service layer for workout-related database operations
/// Handles the complex multi-table insert logic with error recovery
final class WorkoutService: @unchecked Sendable {
    
    // MARK: - Singleton
    static let shared = WorkoutService()
    
    private let supabase = SupabaseManager.shared
    
    private init() {}
    
    // MARK: - Save Workout (Transactional Chain)
    
    /// Saves a complete workout session to the database
    /// Implements chained inserts with rollback on failure:
    /// 1. Insert `workouts` -> Get ID
    /// 2. Insert `workout_exercises` (linked to Workout ID) -> Get IDs
    /// 3. Insert `workout_sets` (linked to WorkoutExercise IDs)
    ///
    /// - Parameter session: The workout session data to save
    /// - Returns: The saved workout with its database-assigned ID
    /// - Throws: `WorkoutServiceError` if any step fails
    func saveWorkout(session: WorkoutSessionModel) async throws -> DBWorkout {
        // Validate
        guard !session.exercises.isEmpty else {
            throw WorkoutServiceError.noExercisesProvided
        }
        
        // Get user settings for unit conversion
        let userSettings = try? await fetchUserSettings(userId: session.userId)
        
        // Step 1: Insert the workout
        let workoutPayload = DBWorkout.InsertPayload(
            userId: session.userId,
            name: session.name,
            comment: session.comment,
            imageUrl: session.imageUrl,
            visibility: session.visibility,
            startedAt: session.startedAt,
            endedAt: session.endedAt,
            durationSeconds: session.durationSeconds
        )
        
        let savedWorkout: DBWorkout
        do {
            savedWorkout = try await supabase.from("workouts")
                .insert(workoutPayload)
                .select()
                .single()
                .execute()
                .value
        } catch {
            throw WorkoutServiceError.workoutInsertFailed(error.localizedDescription)
        }
        
        let workoutId = savedWorkout.id
        
        // Step 2: Insert workout exercises
        var exercisePayloads: [DBWorkoutExercise.InsertPayload] = []
        for (index, exerciseData) in session.exercises.enumerated() {
            exercisePayloads.append(DBWorkoutExercise.InsertPayload(
                workoutId: workoutId,
                exerciseId: exerciseData.exerciseId,
                orderIndex: index,
                restTimerSeconds: exerciseData.restTimerSeconds,
                memo: exerciseData.memo
            ))
        }
        
        let savedExercises: [DBWorkoutExercise]
        do {
            savedExercises = try await supabase.from("workout_exercises")
                .insert(exercisePayloads)
                .select()
                .execute()
                .value
        } catch {
            // Rollback: Delete the orphaned workout
            await rollbackWorkout(id: workoutId)
            throw WorkoutServiceError.exerciseInsertFailed(error.localizedDescription)
        }
        
        // Step 3: Insert workout sets for each exercise
        var allSetPayloads: [DBWorkoutSet.InsertPayload] = []
        
        // Sort saved exercises by order_index to match our session data
        let sortedSavedExercises = savedExercises.sorted { $0.orderIndex < $1.orderIndex }
        
        for (index, savedExercise) in sortedSavedExercises.enumerated() {
            guard index < session.exercises.count else { continue }
            let exerciseData = session.exercises[index]
            
            for (setIndex, setData) in exerciseData.sets.enumerated() {
                // Convert weight to kg if user is using lbs
                var weightInKg = setData.weight
                if let settings = userSettings, settings.unitWeight == .lbs {
                    weightInKg = setData.weight * WeightUnit.lbs.toKgFactor
                }
                
                allSetPayloads.append(DBWorkoutSet.InsertPayload(
                    workoutExerciseId: savedExercise.id,
                    weight: weightInKg,
                    reps: setData.reps,
                    isCompleted: setData.isCompleted,
                    orderIndex: setIndex
                ))
            }
        }
        
        if !allSetPayloads.isEmpty {
            do {
                try await supabase.from("workout_sets")
                    .insert(allSetPayloads)
                    .execute()
            } catch {
                // Rollback: Delete the orphaned workout (cascade will handle exercises)
                await rollbackWorkout(id: workoutId)
                throw WorkoutServiceError.setInsertFailed(error.localizedDescription)
            }
        }
        
        return savedWorkout
    }
    
    // MARK: - Rollback Helper
    
    /// Attempts to delete a workout (for rollback purposes)
    /// Assumes ON DELETE CASCADE is set up for workout_exercises and workout_sets
    private func rollbackWorkout(id: UUID) async {
        do {
            try await supabase.from("workouts")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
        } catch {
            // Log error but don't throw - this is best-effort cleanup
            print("⚠️ Rollback failed for workout \(id): \(error)")
        }
    }
    
    // MARK: - Fetch Operations
    
    /// Fetches a complete workout with all exercises and sets
    func fetchWorkoutWithDetails(id: UUID) async throws -> DBWorkout.WithExercises {
        do {
            let workout: DBWorkout.WithExercises = try await supabase.from("workouts")
                .select("""
                    *,
                    workout_exercises (
                        *,
                        workout_sets (*),
                        exercises (*)
                    )
                """)
                .eq("id", value: id.uuidString)
                .single()
                .execute()
                .value
            
            return workout
        } catch {
            throw WorkoutServiceError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// Fetches workouts for a user's timeline
    func fetchUserWorkouts(
        userId: UUID,
        limit: Int = 20,
        offset: Int = 0
    ) async throws -> [DBWorkout] {
        do {
            let workouts: [DBWorkout] = try await supabase.from("workouts")
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("started_at", ascending: false)
                .range(from: offset, to: offset + limit - 1)
                .execute()
                .value
            
            return workouts
        } catch {
            throw WorkoutServiceError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// Fetches public/visible workouts for the home timeline
    func fetchTimelineWorkouts(
        currentUserId: UUID?,
        limit: Int = 20,
        offset: Int = 0
    ) async throws -> [DBWorkout.WithExercises] {
        do {
            // For now, fetch only public workouts
            // TODO: Add followers_only logic with proper join
            let workouts: [DBWorkout.WithExercises] = try await supabase.from("workouts")
                .select("""
                    *,
                    workout_exercises (
                        *,
                        workout_sets (*),
                        exercises (*)
                    )
                """)
                .eq("visibility", value: VisibilityType.public.rawValue)
                .order("started_at", ascending: false)
                .range(from: offset, to: offset + limit - 1)
                .execute()
                .value
            
            return workouts
        } catch {
            throw WorkoutServiceError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// Fetches the last performed workout data for an exercise
    /// Used for auto-filling previous values
    func fetchLastPerformedData(
        exerciseId: UUID,
        userId: UUID
    ) async throws -> [DBWorkoutSet]? {
        do {
            // Find the most recent workout_exercise for this exercise by this user
            let workoutExercises: [DBWorkoutExercise.WithSets] = try await supabase.from("workout_exercises")
                .select("""
                    *,
                    workout_sets (*),
                    workouts!inner (user_id, ended_at)
                """)
                .eq("exercise_id", value: exerciseId.uuidString)
                .order("created_at", ascending: false)
                .limit(1)
                .execute()
                .value
            
            return workoutExercises.first?.workoutSets.sorted { $0.orderIndex < $1.orderIndex }
        } catch {
            throw WorkoutServiceError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// Deletes a workout
    func deleteWorkout(id: UUID) async throws {
        do {
            try await supabase.from("workouts")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
        } catch {
            throw WorkoutServiceError.deleteFailed(error.localizedDescription)
        }
    }
    
    // MARK: - User Settings
    
    private func fetchUserSettings(userId: UUID) async throws -> DBUserSettings? {
        do {
            let settings: DBUserSettings = try await supabase.from("user_settings")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value
            
            return settings
        } catch {
            return nil
        }
    }
}

// MARK: - Exercise Service Extension
extension WorkoutService {
    
    /// Fetches all system exercises (where created_by is NULL)
    func fetchSystemExercises() async throws -> [DBExercise] {
        do {
            let exercises: [DBExercise] = try await supabase.from("exercises")
                .select()
                .is("created_by", value: nil)
                .order("name")
                .execute()
                .value
            
            return exercises
        } catch {
            throw WorkoutServiceError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// Fetches user's custom exercises
    func fetchUserExercises(userId: UUID) async throws -> [DBExercise] {
        do {
            let exercises: [DBExercise] = try await supabase.from("exercises")
                .select()
                .eq("created_by", value: userId.uuidString)
                .order("name")
                .execute()
                .value
            
            return exercises
        } catch {
            throw WorkoutServiceError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// Fetches all available exercises (system + user's custom)
    func fetchAllAvailableExercises(userId: UUID) async throws -> [DBExercise] {
        do {
            let exercises: [DBExercise] = try await supabase.from("exercises")
                .select()
                .or("created_by.is.null,created_by.eq.\(userId.uuidString)")
                .order("name")
                .execute()
                .value
            
            return exercises
        } catch {
            throw WorkoutServiceError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// Creates a custom exercise
    func createExercise(payload: DBExercise.InsertPayload) async throws -> DBExercise {
        do {
            let exercise: DBExercise = try await supabase.from("exercises")
                .insert(payload)
                .select()
                .single()
                .execute()
                .value
            
            return exercise
        } catch {
            throw WorkoutServiceError.workoutInsertFailed(error.localizedDescription)
        }
    }
    
    /// Searches exercises by name, muscle group, or equipment
    func searchExercises(
        query: String,
        muscleGroups: [String]? = nil,
        equipment: [String]? = nil,
        userId: UUID? = nil
    ) async throws -> [DBExercise] {
        do {
            var request = supabase.from("exercises")
                .select()
            
            // Text search on name
            if !query.isEmpty {
                request = request.or("name.ilike.%\(query)%,name_ja.ilike.%\(query)%")
            }
            
            // Filter by muscle groups (contains any)
            if let muscles = muscleGroups, !muscles.isEmpty {
                request = request.contains("target_muscles", value: muscles)
            }
            
            // Filter by equipment (contains any)
            if let equip = equipment, !equip.isEmpty {
                request = request.contains("equipment_used", value: equip)
            }
            
            // Filter by visibility (system or user's own)
            if let userId = userId {
                request = request.or("created_by.is.null,created_by.eq.\(userId.uuidString)")
            } else {
                request = request.is("created_by", value: nil)
            }
            
            let exercises: [DBExercise] = try await request
                .order("name")
                .execute()
                .value
            
            return exercises
        } catch {
            throw WorkoutServiceError.fetchFailed(error.localizedDescription)
        }
    }
}
