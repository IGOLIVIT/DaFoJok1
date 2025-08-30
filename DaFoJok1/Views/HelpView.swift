//
//  HelpView.swift
//  DaFoJok1
//
//  Created by IGOR on 29/08/2025.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AppColors.tableGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Tab selector
                    tabSelector
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        gameRulesView
                            .tag(0)
                        
                        pokerHandsView
                            .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.goldAccent)
                }
            }
        }
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            Button("Game Rules") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 0
                }
            }
            .font(AppTypography.buttonMedium)
            .foregroundColor(selectedTab == 0 ? AppColors.tableDark : AppColors.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppLayout.paddingMedium)
            .background(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .fill(selectedTab == 0 ? AppColors.goldAccent : Color.clear)
            )
            
            Button("Poker Hands") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 1
                }
            }
            .font(AppTypography.buttonMedium)
            .foregroundColor(selectedTab == 1 ? AppColors.tableDark : AppColors.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppLayout.paddingMedium)
            .background(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .fill(selectedTab == 1 ? AppColors.goldAccent : Color.clear)
            )
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .fill(AppColors.tableDark.opacity(0.8))
        )
        .padding(.horizontal, AppLayout.paddingLarge)
        .padding(.vertical, AppLayout.paddingMedium)
    }
    
    // MARK: - Game Rules View
    private var gameRulesView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppLayout.paddingLarge) {
                // Deck Catch Rules
                gameRuleSection(
                    title: "Deck Catch",
                    icon: "hand.tap.fill",
                    color: AppColors.successGreen,
                    rules: [
                        "Cards fall from the top of the screen one by one",
                        "Tap each card before it reaches the bottom to collect it",
                        "Collect all 52 unique cards to complete the deck",
                        "Missing cards breaks your combo and adds to missed count",
                        "Game speed increases as you progress",
                        "Aim for the best time and highest accuracy"
                    ]
                )
                
                // Poker Trainer Rules
                gameRuleSection(
                    title: "Poker Rank Trainer",
                    icon: "brain.head.profile",
                    color: AppColors.warningAmber,
                    rules: [
                        "You'll be shown 5 cards forming a poker hand",
                        "Select the correct hand ranking from 10 options",
                        "Quick Training: Play until you make a mistake",
                        "10-Round Session: Answer 10 hands for a final score",
                        "Build streaks by answering correctly in a row",
                        "Learn all poker hand rankings to improve"
                    ]
                )
                
                // Scoring Section
                VStack(alignment: .leading, spacing: AppLayout.paddingMedium) {
                    Text("Scoring & Records")
                        .font(AppTypography.subtitle)
                        .foregroundColor(AppColors.goldAccent)
                    
                    VStack(alignment: .leading, spacing: AppLayout.paddingSmall) {
                        Text("• Your best scores are automatically saved")
                        Text("• Deck Catch: Best time and accuracy are tracked")
                        Text("• Poker Trainer: Best streak and overall accuracy")
                        Text("• All stats are displayed on the main menu")
                        Text("• Reset progress anytime in Settings")
                    }
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.secondaryText)
                }
                .padding(AppLayout.paddingMedium)
                .background(
                    RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                        .fill(AppColors.tableDark.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                                .stroke(AppColors.goldAccent.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, AppLayout.paddingLarge)
            .padding(.bottom, AppLayout.paddingXLarge)
        }
    }
    
    // MARK: - Poker Hands View
    private var pokerHandsView: some View {
        ScrollView {
            VStack(spacing: AppLayout.paddingMedium) {
                Text("Poker Hand Rankings")
                    .font(AppTypography.subtitle)
                    .foregroundColor(AppColors.primaryText)
                    .padding(.top, AppLayout.paddingMedium)
                
                Text("From highest to lowest value:")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.secondaryText)
                
                LazyVStack(spacing: AppLayout.paddingSmall) {
                    ForEach(Array(PokerHandType.allCases.enumerated().reversed()), id: \.element) { index, handType in
                        PokerHandRowView(
                            rank: PokerHandType.allCases.count - index,
                            handType: handType
                        )
                    }
                }
            }
            .padding(.horizontal, AppLayout.paddingLarge)
            .padding(.bottom, AppLayout.paddingXLarge)
        }
    }
    
    // MARK: - Game Rule Section
    private func gameRuleSection(title: String, icon: String, color: Color, rules: [String]) -> some View {
        VStack(alignment: .leading, spacing: AppLayout.paddingMedium) {
            HStack(spacing: AppLayout.paddingMedium) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color)
                
                Text(title)
                    .font(AppTypography.subtitle)
                    .foregroundColor(AppColors.primaryText)
            }
            
            VStack(alignment: .leading, spacing: AppLayout.paddingSmall) {
                ForEach(rules, id: \.self) { rule in
                    Text("• \(rule)")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.secondaryText)
                }
            }
        }
        .padding(AppLayout.paddingMedium)
        .background(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .fill(AppColors.tableDark.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Poker Hand Row View
struct PokerHandRowView: View {
    let rank: Int
    let handType: PokerHandType
    
    var body: some View {
        HStack(spacing: AppLayout.paddingMedium) {
            // Rank number
            Text("\(rank)")
                .font(AppTypography.bodyMedium)
                .foregroundColor(AppColors.goldAccent)
                .frame(width: 24, alignment: .center)
            
            // Hand info
            VStack(alignment: .leading, spacing: 2) {
                Text(handType.rawValue)
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(AppColors.primaryText)
                
                Text(handType.description)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
        }
        .padding(AppLayout.paddingMedium)
        .background(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .fill(AppColors.tableDark.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                        .stroke(AppColors.goldAccent.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    HelpView()
}
