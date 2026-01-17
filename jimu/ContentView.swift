//
//  ContentView.swift
//  jimu
//
//  Created by 乙津　龍　 on 14/1/2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    
    var body: some View {
        Group {
            switch authViewModel.authState {
            case .unauthenticated:
                LoginView()
                    .transition(.opacity)
                
            case .usernameSetup:
                UsernameSetupView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                
            case .profileSetup:
                ProfileSetupView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                
            case .authenticated:
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.authState)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
        .environment(AuthViewModel())
        .environment(WorkoutRecorderViewModel())
}
