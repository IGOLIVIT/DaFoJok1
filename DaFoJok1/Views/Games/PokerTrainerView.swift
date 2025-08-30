//
//  PokerTrainerView.swift
//  DaFoJok1
//
//  Created by IGOR on 29/08/2025.
//

import SwiftUI

struct PokerTrainerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PokerTrainerViewModel()
    @State private var showingModeSelection = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                AppColors.tableGradient
                    .ignoresSafeArea()
                
                if showingModeSelection {
                    modeSelectionView
                } else {
                    gameView
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    if showingModeSelection {
                        dismiss()
                    } else {
                        showingModeSelection = true
                        viewModel.resetGame()
                    }
                }
                .foregroundColor(AppColors.primaryText)
            }
        }
    }
    
    // MARK: - Mode Selection View
    private var modeSelectionView: some View {
        VStack(spacing: AppLayout.paddingLarge) {
            // Header
            VStack(spacing: AppLayout.paddingSmall) {
                Text("Poker Rank Trainer")
                    .font(AppTypography.largeTitle)
                    .foregroundColor(AppColors.primaryText)
                
                Text("Choose your training mode")
                    .font(AppTypography.callout)
                    .foregroundColor(AppColors.secondaryText)
            }
            .padding(.top, AppLayout.paddingXLarge)
            
            Spacer()
            
            // Mode cards
            VStack(spacing: AppLayout.paddingMedium) {
                ModeCardView(
                    title: "Quick Training",
                    description: "Infinite rounds until you make a mistake",
                    icon: "bolt.fill",
                    color: AppColors.warningAmber
                ) {
                    viewModel.startGame(mode: .quickTraining)
                    showingModeSelection = false
                }
                
                ModeCardView(
                    title: "10-Round Session",
                    description: "Answer 10 hands and get your final score",
                    icon: "target",
                    color: AppColors.successGreen
                ) {
                    viewModel.startGame(mode: .tenRounds)
                    showingModeSelection = false
                }
            }
            
            Spacer()
            
            // Stats preview
            VStack(alignment: .leading, spacing: AppLayout.paddingMedium) {
                Text("Your Best")
                    .font(AppTypography.subtitle)
                    .foregroundColor(AppColors.primaryText)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Best Streak")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.secondaryText)
                        Text("\(UserDefaultsManager.shared.pokerTrainerBestStreak)")
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(AppColors.warningAmber)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Accuracy")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.secondaryText)
                        Text(UserDefaultsManager.shared.formattedAccuracy(UserDefaultsManager.shared.pokerTrainerAccuracy))
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(AppColors.successGreen)
                    }
                }
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
            .padding(.bottom, AppLayout.paddingXLarge)
        }
        .padding(.horizontal, AppLayout.paddingLarge)
    }
    
    // MARK: - Game View
    private var gameView: some View {
        VStack(spacing: 0) {
            // Header with stats
            gameHeaderView
            
            // Cards display
            cardsDisplayView
            
            // Answer options
            answerOptionsView
            
            // Result display
            if viewModel.showingResult {
                resultView
            }
            
            // Game over overlay
            if viewModel.gameState == .gameOver {
                gameOverOverlay
            }
        }
    }
    
    // MARK: - Game Header View
    private var gameHeaderView: some View {
        HStack {
            // Current streak
            VStack(alignment: .leading, spacing: 2) {
                Text("Streak")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.secondaryText)
                Text("\(viewModel.currentStreak)")
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(AppColors.warningAmber)
            }
            
            Spacer()
            
            // Round counter (for 10-round mode)
            if viewModel.gameMode == .tenRounds {
                VStack(spacing: 2) {
                    Text("Round")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                    Text("\(viewModel.currentRound)/10")
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(AppColors.primaryText)
                }
            }
            
            Spacer()
            
            // Score (for 10-round mode)
            if viewModel.gameMode == .tenRounds {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Score")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                    Text("\(viewModel.correctAnswers)/\(viewModel.totalAnswers)")
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(AppColors.successGreen)
                }
            }
        }
        .padding(.horizontal, AppLayout.paddingLarge)
        .padding(.vertical, AppLayout.paddingMedium)
        .background(
            Rectangle()
                .fill(AppColors.tableDark.opacity(0.8))
                .blur(radius: 10)
        )
    }
    
    // MARK: - Cards Display View
    private var cardsDisplayView: some View {
        VStack(spacing: AppLayout.paddingMedium) {
            Text("What poker hand is this?")
                .font(AppTypography.subtitle)
                .foregroundColor(AppColors.primaryText)
                .padding(.top, AppLayout.paddingLarge)
            
            // Cards in hand
            HStack(spacing: AppLayout.paddingSmall) {
                ForEach(viewModel.currentHand, id: \.id) { card in
                    AnimatedCardView(card: card, size: .medium)
                }
            }
            .padding(.horizontal, AppLayout.paddingMedium)
        }
    }
    
    // MARK: - Answer Options View
    private var answerOptionsView: some View {
        VStack(spacing: AppLayout.paddingMedium) {
            Text("Select the correct hand ranking:")
                .font(AppTypography.callout)
                .foregroundColor(AppColors.secondaryText)
                .padding(.top, AppLayout.paddingLarge)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: AppLayout.paddingSmall), count: 2), spacing: AppLayout.paddingSmall) {
                ForEach(PokerHandType.allCases, id: \.self) { handType in
                    Button(handType.rawValue) {
                        viewModel.selectAnswer(handType)
                    }
                    .font(AppTypography.buttonSmall)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                            .fill(buttonBackgroundColor(for: handType))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                                    .stroke(buttonBorderColor(for: handType), lineWidth: 1)
                            )
                    )
                    .foregroundColor(buttonTextColor(for: handType))
                    .disabled(viewModel.showingResult)
                }
            }
            .padding(.horizontal, AppLayout.paddingLarge)
        }
    }
    
    // MARK: - Result View
    private var resultView: some View {
        VStack(spacing: AppLayout.paddingMedium) {
            // Result indicator
            HStack {
                Image(systemName: viewModel.lastAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(viewModel.lastAnswerCorrect ? AppColors.successGreen : AppColors.heartDiamondRed)
                
                Text(viewModel.lastAnswerCorrect ? "Correct!" : "Incorrect")
                    .font(AppTypography.subtitle)
                    .foregroundColor(viewModel.lastAnswerCorrect ? AppColors.successGreen : AppColors.heartDiamondRed)
            }
            
            // Explanation
            VStack(spacing: AppLayout.paddingSmall) {
                Text("Correct Answer: \(viewModel.correctHandType.rawValue)")
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(AppColors.primaryText)
                
                Text(viewModel.correctHandType.description)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            // Next button
            Button(viewModel.gameState == .gameOver ? "View Results" : "Next Hand") {
                if viewModel.gameState == .gameOver {
                    // Results are shown in overlay
                } else {
                    viewModel.nextHand()
                }
            }
            .font(AppTypography.buttonMedium)
            .primaryButton()
            .padding(.horizontal, AppLayout.paddingLarge)
        }
        .padding(AppLayout.paddingMedium)
        .background(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .fill(AppColors.tableDark.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                        .stroke(AppColors.goldAccent.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, AppLayout.paddingLarge)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    // MARK: - Game Over Overlay
    private var gameOverOverlay: some View {
        ZStack {
            // Background blur
            Rectangle()
                .fill(AppColors.tableDark.opacity(0.9))
                .ignoresSafeArea()
            
            VStack(spacing: AppLayout.paddingLarge) {
                // Title
                Text(viewModel.gameMode == .quickTraining ? "Training Complete" : "Session Complete")
                    .font(AppTypography.largeTitle)
                    .foregroundColor(AppColors.primaryText)
                
                // Stats
                VStack(spacing: AppLayout.paddingMedium) {
                    if viewModel.gameMode == .quickTraining {
                        StatItemView(
                            title: "Final Streak",
                            value: "\(viewModel.currentStreak)",
                            color: AppColors.warningAmber
                        )
                    } else {
                        StatItemView(
                            title: "Correct Answers",
                            value: "\(viewModel.correctAnswers)/10",
                            color: AppColors.successGreen
                        )
                        
                        StatItemView(
                            title: "Accuracy",
                            value: String(format: "%.1f%%", Double(viewModel.correctAnswers) / 10.0 * 100),
                            color: AppColors.goldAccent
                        )
                    }
                    
                    if viewModel.isNewRecord {
                        Text("🏆 New Record!")
                            .font(AppTypography.subtitle)
                            .foregroundColor(AppColors.goldAccent)
                            .padding(.top, AppLayout.paddingSmall)
                    }
                }
                .padding(AppLayout.paddingLarge)
                .background(
                    RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                        .fill(AppColors.tableDark.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                                .stroke(AppColors.goldAccent.opacity(0.3), lineWidth: 1)
                        )
                )
                
                // Buttons
                HStack(spacing: AppLayout.paddingMedium) {
                    Button("Back to Menu") {
                        showingModeSelection = true
                        viewModel.resetGame()
                    }
                    .font(AppTypography.buttonMedium)
                    .frame(height: AppLayout.buttonHeight)
                    .frame(maxWidth: .infinity)
                    .background(AppColors.tableDark)
                    .foregroundColor(AppColors.primaryText)
                    .cornerRadius(AppLayout.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                            .stroke(AppColors.goldAccent.opacity(0.5), lineWidth: 1)
                    )
                    
                    Button("Play Again") {
                        viewModel.restartGame()
                    }
                    .font(AppTypography.buttonMedium)
                    .primaryButton()
                }
            }
            .padding(AppLayout.paddingLarge)
        }
        .transition(.opacity.combined(with: .scale))
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.gameState)
    }
    
    // MARK: - Helper Methods
    private func buttonBackgroundColor(for handType: PokerHandType) -> Color {
        if !viewModel.showingResult {
            return AppColors.tableDark.opacity(0.8)
        }
        
        if handType == viewModel.correctHandType {
            return AppColors.successGreen.opacity(0.3)
        } else if handType == viewModel.selectedAnswer && !viewModel.lastAnswerCorrect {
            return AppColors.heartDiamondRed.opacity(0.3)
        } else {
            return AppColors.tableDark.opacity(0.8)
        }
    }
    
    private func buttonBorderColor(for handType: PokerHandType) -> Color {
        if !viewModel.showingResult {
            return AppColors.goldAccent.opacity(0.3)
        }
        
        if handType == viewModel.correctHandType {
            return AppColors.successGreen
        } else if handType == viewModel.selectedAnswer && !viewModel.lastAnswerCorrect {
            return AppColors.heartDiamondRed
        } else {
            return AppColors.goldAccent.opacity(0.3)
        }
    }
    
    private func buttonTextColor(for handType: PokerHandType) -> Color {
        if !viewModel.showingResult {
            return AppColors.primaryText
        }
        
        if handType == viewModel.correctHandType {
            return AppColors.successGreen
        } else if handType == viewModel.selectedAnswer && !viewModel.lastAnswerCorrect {
            return AppColors.heartDiamondRed
        } else {
            return AppColors.secondaryText
        }
    }
}

// MARK: - Mode Card View
struct ModeCardView: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppLayout.paddingMedium) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 50, height: 50)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTypography.subtitle)
                        .foregroundColor(AppColors.primaryText)
                        .multilineTextAlignment(.leading)
                    
                    Text(description)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.goldAccent)
            }
            .padding(AppLayout.paddingMedium)
            .background(
                RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                    .fill(AppColors.tableDark.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
            .buttonShadow()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        PokerTrainerView()
    }
}
