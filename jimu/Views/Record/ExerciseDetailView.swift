//
//  ExerciseDetailView.swift
//  jimu
//
//  Created by Jimu Team on 16/1/2026.
//

import SwiftUI
import Charts

struct ExerciseDetailView: View {
    let exercise: Exercise
    @State private var selectedPeriod: StatsPeriod = .month
    @State private var showPeriodSelection = false
    @State private var showCalendar = false
    @State private var customStartDate = Date().addingTimeInterval(-86400 * 30)
    @State private var customEndDate = Date()
    @State private var selectedTab: DetailTab = .analysis
    
    // Stats
    @State private var history: [WorkoutHistoryItem] = []
    
    enum StatsPeriod: String, CaseIterable, Identifiable {
        case week = "1週間"
        case month = "1ヶ月"
        case threeMonths = "3ヶ月"
        case sixMonths = "6ヶ月"
        case year = "1年"
        case custom = "期間指定"
        
        var id: String { rawValue }
    }
    
    enum DetailTab: String, CaseIterable, Identifiable {
        case analysis = "分析"
        case history = "履歴"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Header
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(DetailTab.allCases) { tab in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                            }
                        }) {
                            VStack(spacing: 8) {
                                Text(tab.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(selectedTab == tab ? .semibold : .regular)
                                    .foregroundColor(selectedTab == tab ? .green : .secondary)
                                
                                Rectangle()
                                    .fill(selectedTab == tab ? Color.green : Color.clear)
                                    .frame(height: 2)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.top, 8)
                
                Divider()
            }
            .background(Color(.systemBackground))
            
            // Content
            TabView(selection: $selectedTab) {
                analysisView
                    .tag(DetailTab.analysis)
                
                historyView
                    .tag(DetailTab.history)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(exercise.nameJa)
        .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPeriodSelection) {
            PeriodSelectionView(
                selectedPeriod: $selectedPeriod,
                customStartDate: $customStartDate,
                customEndDate: $customEndDate,
                showCalendar: $showCalendar
            ) {
                showPeriodSelection = false
                updateHistory()
            }
            .presentationDetents([.large])
        }
            .sheet(isPresented: $showCalendar) {
            NavigationStack {
                VStack {
                    DatePicker("開始日", selection: $customStartDate, displayedComponents: .date)
                        .padding()
                    DatePicker("終了日", selection: $customEndDate, displayedComponents: .date)
                        .padding()
                    Spacer()
                }
                .navigationTitle("期間を選択")
                .toolbar {
                    Button("完了") {
                        showCalendar = false
                        // The updateHistory() will be called when PeriodSelectionView is dismissed or updated?
                        // Actually, if we change dates here, we should update.
                        // Ideally we update state and let the parent view react or call update.
                        // Let's call updateHistory() when sheet closes if needed, or binding updates automatically.
                        // Since customStartDate/EndDate are bindings, they update immediately.
                        // We need to trigger updateHistory() after this sheet closes if we want to reflect changes.
                        updateHistory()
                    }
                }
            }
            .presentationDetents([.large])
        }
        .onAppear {
            updateHistory()
        }
    }
    
    private var analysisView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Stats
                statsHeader
                
                // Chart Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("推移グラフ")
                            .font(.headline)
                        Spacer()
                        
                        Button(action: {
                            showPeriodSelection = true
                        }) {
                            HStack(spacing: 4) {
                                Text(selectedPeriod.rawValue)
                                    .fontWeight(.medium)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    
                    if selectedPeriod == .custom {
                        HStack {
                            Text("\(customStartDate.formatted(date: .numeric, time: .omitted)) 〜 \(customEndDate.formatted(date: .numeric, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    
                    if history.isEmpty {
                        ContentUnavailableView("データがありません", systemImage: "chart.xyaxis.line", description: Text("この期間のトレーニング記録が見つかりませんでした"))
                            .frame(height: 250)
                    } else {
                        let filteredHistory = history.filter { isDateInPeriod($0.date) }
                        if filteredHistory.isEmpty {
                             ContentUnavailableView("データがありません", systemImage: "chart.xyaxis.line", description: Text("この期間のトレーニング記録が見つかりませんでした"))
                                .frame(height: 250)
                        } else {
                            Chart(filteredHistory) { item in
                                LineMark(
                                    x: .value("日付", item.date),
                                    y: .value("最大重量", item.maxWeight)
                                )
                                .foregroundStyle(Color.green)
                                .symbol(Circle())
                                
                                PointMark(
                                    x: .value("日付", item.date),
                                    y: .value("最大重量", item.maxWeight)
                                )
                                .foregroundStyle(Color.green)
                            }
                            .frame(height: 250)
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
            }
            .padding()
        }
    }
    
    private var historyView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if history.isEmpty {
                    ContentUnavailableView("履歴がありません", systemImage: "clock", description: Text("トレーニングを記録するとここに表示されます"))
                        .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(history.sorted(by: { $0.date > $1.date })) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(item.date.formatted(date: .numeric, time: .omitted))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Text("\(item.maxWeight.formatted())kg")
                                        .font(.headline)
                                    Text("× \(item.maxReps)回")
                                        .font(.subheadline)
                                    Spacer()
                                    Text("1RM: \(Int(item.estimatedOneRM))kg")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.orange.opacity(0.1))
                                        .foregroundColor(.orange)
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            
                            if item.id != history.last?.id {
                                Divider()
                                    .padding(.leading)
                            }
                        }
                    }
                    .cornerRadius(16)
                    .padding()
                }
            }
        }
    }
    
    private var statsHeader: some View {
        HStack(spacing: 16) {
            DetailStatCard(title: "最高重量", value: "\(Int(history.map(\.maxWeight).max() ?? 0))", unit: "kg")
            DetailStatCard(title: "推定1RM", value: "\(Int(history.map(\.estimatedOneRM).max() ?? 0))", unit: "kg")
        }
    }
    
    private func updateHistory() {
        // Fetch real data from MockData based on exercise ID
        // Note: In a real app this would be an async DB call
        let allSets = MockData.shared.sampleWorkoutSets.filter { $0.exerciseId == exercise.id }
        let allWorkouts = MockData.shared.sampleWorkouts
        
        var historyItems: [WorkoutHistoryItem] = []
        
        // Group by workout
        let groupedSets = Dictionary(grouping: allSets) { set in
            set.workoutId
        }
        
        for (workoutId, sets) in groupedSets {
            guard let workout = allWorkouts.first(where: { $0.id == workoutId }),
                  let maxSet = sets.max(by: { $0.weight < $1.weight }) else { continue }
            
            // For Analysis tab, we filter by period. For History tab, we might want all.
            // But since 'history' state is used for both, let's keep it simple:
            // If we are in Analysis tab, the graph uses 'history'.
            // If we are in History tab, we might want to show everything.
            // Let's modify this to store ALL history in one var, and filtered in another, or just filter in view.
            
            // For now, I'll just load ALL history here, and filter it in the Analysis view for the chart.
            let item = WorkoutHistoryItem(
                id: workoutId,
                date: workout.startedAt,
                maxWeight: maxSet.weight,
                maxReps: maxSet.reps
            )
            historyItems.append(item)
        }
        
        self.history = historyItems.sorted(by: { $0.date < $1.date })
    }
    
    private func isDateInPeriod(_ date: Date) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        
        switch selectedPeriod {
        case .week:
            return calendar.date(byAdding: .day, value: -7, to: now)! <= date
        case .month:
            return calendar.date(byAdding: .month, value: -1, to: now)! <= date
        case .threeMonths:
            return calendar.date(byAdding: .month, value: -3, to: now)! <= date
        case .sixMonths:
            return calendar.date(byAdding: .month, value: -6, to: now)! <= date
        case .year:
            return calendar.date(byAdding: .year, value: -1, to: now)! <= date
        case .custom:
            return date >= customStartDate && date <= customEndDate
        }
    }
}

struct WorkoutHistoryItem: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let maxWeight: Double
    let maxReps: Int
    
    var estimatedOneRM: Double {
        // Epley Formula: Weight * (1 + Reps/30)
        return maxWeight * (1 + Double(maxReps) / 30.0)
    }
}

struct DetailStatCard: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(unit)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct PeriodSelectionView: View {
    @Binding var selectedPeriod: ExerciseDetailView.StatsPeriod
    @Binding var customStartDate: Date
    @Binding var customEndDate: Date
    @Binding var showCalendar: Bool
    @Environment(\.dismiss) private var dismiss
    
    var onSelect: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(ExerciseDetailView.StatsPeriod.allCases) { period in
                        Button(action: {
                            selectedPeriod = period
                        }) {
                            HStack {
                                Text(period.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedPeriod == period {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
                
                if selectedPeriod == .custom {
                    Section {
                        Button(action: {
                            showCalendar = true
                        }) {
                            HStack {
                                Text("期間設定")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(customStartDate.formatted(date: .numeric, time: .omitted)) 〜 \(customEndDate.formatted(date: .numeric, time: .omitted))")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationTitle("期間を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        onSelect()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(exercise: MockData.shared.exercises[0])
    }
}
