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
        TabView(selection: $selectedTab) {
            TimelineView()
                .tabItem {
                    Label(Tab.home.rawValue, systemImage: Tab.home.iconName)
                }
                .tag(Tab.home)
            
            WorkoutRecorderView()
                .tabItem {
                    Label(Tab.record.rawValue, systemImage: Tab.record.iconName)
                }
                .tag(Tab.record)
            
            ProfileView()
                .tabItem {
                    Label(Tab.profile.rawValue, systemImage: Tab.profile.iconName)
                }
                .tag(Tab.profile)
        }
        .tint(.green)
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
}
