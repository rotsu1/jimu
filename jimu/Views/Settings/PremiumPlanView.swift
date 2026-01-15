//
//  PremiumPlanView.swift
//  jimu
//
//  Created by Jimu Team on 15/1/2026.
//

import SwiftUI

struct PremiumPlanView: View {
    @State private var selectedPlan: PlanType = .yearly
    
    enum PlanType {
        case free
        case monthly
        case yearly
        case lifetime
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // ヘッダー
                VStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                    
                    Text("プレミアムプラン")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("すべての機能制限を解除して、\n最高のトレーニング体験を。")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // プラン選択
                VStack(spacing: 16) {
                    PlanOptionCard(
                        title: "フリープラン",
                        price: "¥0",
                        description: "基本的な機能のみ利用可能",
                        isSelected: selectedPlan == .free,
                        action: { selectedPlan = .free }
                    )
                    
                    Spacer(minLength: 8) // フリーと有料プランを少し離す
                    
                    PlanOptionCard(
                        title: "月額プラン",
                        price: "¥480 / 月",
                        description: "まずは気軽に始めたい方へ",
                        isSelected: selectedPlan == .monthly,
                        action: { selectedPlan = .monthly }
                    )
                    
                    PlanOptionCard(
                        title: "年額プラン",
                        price: "¥3,800 / 年",
                        description: "2ヶ月分お得（月額換算 ¥316）",
                        isBestValue: true,
                        isSelected: selectedPlan == .yearly,
                        action: { selectedPlan = .yearly }
                    )
                    
                    PlanOptionCard(
                        title: "買い切り",
                        price: "¥12,000",
                        description: "一度の支払いでずっと使える",
                        isSelected: selectedPlan == .lifetime,
                        action: { selectedPlan = .lifetime }
                    )
                }
                .padding()
                
                Spacer()
                
                // 登録ボタン
                Button(action: {
                    // 課金処理
                }) {
                    Text("プランに登録する")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .padding()
                
                Text("利用規約とプライバシーポリシー")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
        }
        .navigationTitle("プラン設定")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PlanOptionCard: View {
    let title: String
    let price: String
    let description: String
    var isBestValue: Bool = false
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if isBestValue {
                            Text("おすすめ")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(price)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                        .font(.title3)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color(.systemGray4), lineWidth: 2)
                    .background(Color(.systemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PremiumPlanView()
    }
}

