//
//  MainTabView.swift
//  jimu
//
//  Created by Jimu Team on 14/1/2026.
//

import SwiftUI

/// メインタブナビゲーション
struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @Environment(WorkoutRecorderViewModel.self) private var workoutViewModel
    
    enum Tab: String, CaseIterable {
        case home = "ホーム"
        case record = "記録"
        case profile = "マイページ"
        
        var iconName: String {
            switch self {
            case .home: return "house.fill"
            case .record: return "plus.circle.fill"
            case .profile: return "person.fill"
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                TimelineView()
                    .tabItem {
                        Label(Tab.home.rawValue, systemImage: Tab.home.iconName)
                    }
                    .tag(Tab.home)
                    .accessibilityIdentifier("tab_home")
                
                WorkoutRecorderView(selectedTab: $selectedTab)
                    .tabItem {
                        Label(Tab.record.rawValue, systemImage: Tab.record.iconName)
                    }
                    .tag(Tab.record)
                    .accessibilityIdentifier("tab_record")
                
                ProfileView()
                    .tabItem {
                        Label(Tab.profile.rawValue, systemImage: Tab.profile.iconName)
                    }
                    .tag(Tab.profile)
                    .accessibilityIdentifier("tab_profile")
            }
            .tint(.green)
            
            // トレーニング中ミニプレイヤー（記録タブ以外で表示）
            if workoutViewModel.isWorkoutActive && !workoutViewModel.isWorkoutExpanded {
                Button(action: {
                    selectedTab = .record
                    workoutViewModel.isWorkoutExpanded = true
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("トレーニング中")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Text(workoutViewModel.formattedElapsedTime)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .monospacedDigit()
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.up")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 60) // タブバーの上に表示するためのパディング
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
        .environment(WorkoutRecorderViewModel())
}
