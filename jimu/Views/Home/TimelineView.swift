//
//  TimelineView.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import SwiftUI

/// ホームタイムライン（X/Twitter風）
struct TimelineView: View {
    @State private var timelineItems = MockData.shared.timelineItems
    @State private var selectedItem: MockData.TimelineItem?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(timelineItems) { item in
                        if item.hasImages || item.hasNote {
                            TimelineCardView(item: item)
                                .onTapGesture {
                                    selectedItem = item
                                }
                        } else {
                            TimelineCompactView(item: item)
                                .onTapGesture {
                                    selectedItem = item
                                }
                        }
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                    }
                }
            }
            .navigationTitle("タイムライン")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            .sheet(item: $selectedItem) { item in
                WorkoutDetailView(item: item)
            }
            .refreshable {
                // Pull to refresh (mock)
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
        }
    }
}

#Preview {
    TimelineView()
        .preferredColorScheme(.dark)
}
