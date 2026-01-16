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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(timelineItems) { item in
                        NavigationLink(value: item) {
                            if item.hasImages || item.hasNote {
                                TimelineCardView(item: item)
                            } else {
                                TimelineCompactView(item: item)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
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
            .navigationDestination(for: MockData.TimelineItem.self) { item in
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
