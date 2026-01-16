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
    @State private var selectedTab = 0 // 0: フォロー中, 1: おすすめ
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // タブ切り替えヘッダー
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        TabButton(title: "フォロー中", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        
                        TabButton(title: "おすすめ", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                    }
                    .frame(height: 44)
                    
                    Divider()
                }
                .background(.regularMaterial)
                .zIndex(1)
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredItems) { item in
                            NavigationLink(value: item) {
                                TimelineCardView(item: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                        }
                    }
                }
                .refreshable {
                    // Pull to refresh (mock)
                    try? await Task.sleep(nanoseconds: 500_000_000)
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
        }
    }
    
    private var filteredItems: [MockData.TimelineItem] {
        if selectedTab == 0 {
            // フォロー中: 全てのモックデータを表示（仮）
            return timelineItems
        } else {
            // おすすめ: ランダムにシャッフルして表示（仮）
            return timelineItems.shuffled()
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottom) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if isSelected {
                    Rectangle()
                        .fill(Color.green)
                        .frame(height: 3)
                        .cornerRadius(1.5)
                }
            }
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    TimelineView()
        .preferredColorScheme(.dark)
}
