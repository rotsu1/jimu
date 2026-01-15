//
//  HealthSyncView.swift
//  jimu
//
//  Created by Jimu Team on 15/1/2026.
//

import SwiftUI

struct HealthSyncView: View {
    @AppStorage("isAppleHealthSyncEnabled") private var isAppleHealthSyncEnabled = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Apple Health Icon Simulation
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60)
                    .foregroundColor(.pink)
            }
            .padding(.bottom, 20)
            
            Text("Appleヘルスケア連携")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("トレーニングの記録をAppleヘルスケアに\n自動的に同期します。")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .lineSpacing(4)
            
            Spacer()
            
            Button(action: {
                isAppleHealthSyncEnabled.toggle()
            }) {
                Text(isAppleHealthSyncEnabled ? "連携を解除" : "ヘルスケアと連携")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isAppleHealthSyncEnabled ? Color(.systemGray5) : Color.accentColor)
                    .foregroundColor(isAppleHealthSyncEnabled ? .red : .white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .padding()
        .navigationTitle("ヘルスケア連携")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HealthSyncView()
    }
}

