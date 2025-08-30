//
//  DeckCatchView.swift
//  DaFoJok1
//
//  Created by IGOR on 29/08/2025.
//

import SwiftUI

struct DeckCatchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = DeckCatchViewModel()
    @StateObject private var userDefaults = UserDefaultsManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with parallax effect
                AppColors.tableGradient
                    .ignoresSafeArea()
                
                // Parallax background pattern
                ParallaxBackgroundView(offset: viewModel.backgroundOffset)
                
                VStack(spacing: 0) {
                    // Header with stats
                    headerView
                    
                    // Game area
                    gameAreaView(geometry: geometry)
                    
                    // Game over overlay
                    if viewModel.gameState == .gameOver {
                        gameOverOverlay
                    }
                    
                    // Pause overlay
                    if viewModel.gameState == .paused {
                        pauseOverlay
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    viewModel.pauseGame()
                    dismiss()
                }
                .foregroundColor(AppColors.primaryText)
            }
        }
        .onAppear {
            viewModel.startGame()
        }
        .onDisappear {
            viewModel.pauseGame()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: AppLayout.paddingSmall) {
            // Top row: Record and game controls
            HStack {
                // Best Record
                VStack(alignment: .leading, spacing: 2) {
                    Text("Best Record")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                    Text(viewModel.bestRecordText)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.goldAccent)
                }
                
                Spacer()
                
                // Game controls
                HStack(spacing: AppLayout.paddingSmall) {
                    // Pause/Resume button
                    Button(action: {
                        if viewModel.gameState == .playing {
                            viewModel.pauseGame()
                        } else if viewModel.gameState == .paused {
                            viewModel.resumeGame()
                        }
                    }) {
                        Image(systemName: viewModel.gameState == .playing ? "pause.fill" : "play.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.primaryText)
                            .frame(width: 32, height: 32)
                            .background(AppColors.tableDark.opacity(0.8))
                            .cornerRadius(8)
                    }
                    .disabled(viewModel.gameState == .gameOver)
                    
                    // Restart button
                    Button(action: {
                        viewModel.restartGame()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.primaryText)
                            .frame(width: 32, height: 32)
                            .background(AppColors.tableDark.opacity(0.8))
                            .cornerRadius(8)
                    }
                }
            }
            
            // Bottom row: Game stats
            HStack {
                // Collected count
                VStack(alignment: .leading, spacing: 2) {
                    Text("Collected")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                    Text("\(viewModel.collectedCount)/52")
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(AppColors.successGreen)
                }
                
                Spacer()
                
                // Timer
                VStack(spacing: 2) {
                    Text("Time")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                    Text(viewModel.formattedTime)
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(AppColors.primaryText)
                }
                
                Spacer()
                
                // Combo
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Combo")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                    Text("\(viewModel.comboCount)")
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(viewModel.comboCount > 0 ? AppColors.warningAmber : AppColors.primaryText)
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
    
    // MARK: - Game Area View
    private func gameAreaView(geometry: GeometryProxy) -> some View {
        ZStack {
            // Falling cards
            ForEach(viewModel.fallingCards) { fallingCard in
                FallingCardView(
                    fallingCard: fallingCard,
                    onTap: { card in
                        viewModel.catchCard(card)
                    }
                )
            }
            
            // Miss line indicator
            Rectangle()
                .fill(AppColors.heartDiamondRed.opacity(0.3))
                .frame(height: 2)
                .position(x: geometry.size.width / 2, y: geometry.size.height - 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
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
                Text(viewModel.collectedCount == 52 ? "Deck Complete!" : "Game Over")
                    .font(AppTypography.largeTitle)
                    .foregroundColor(viewModel.collectedCount == 52 ? AppColors.successGreen : AppColors.primaryText)
                
                // Stats
                VStack(spacing: AppLayout.paddingMedium) {
                    StatItemView(
                        title: "Cards Collected",
                        value: "\(viewModel.collectedCount)/52",
                        color: AppColors.successGreen
                    )
                    
                    StatItemView(
                        title: "Cards Missed",
                        value: "\(viewModel.missedCount)",
                        color: AppColors.heartDiamondRed
                    )
                    
                    StatItemView(
                        title: "Accuracy",
                        value: viewModel.formattedAccuracy,
                        color: AppColors.goldAccent
                    )
                    
                    StatItemView(
                        title: "Time",
                        value: viewModel.formattedTime,
                        color: AppColors.primaryText
                    )
                    
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
                        dismiss()
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
    
    // MARK: - Pause Overlay
    private var pauseOverlay: some View {
        ZStack {
            // Background blur
            Rectangle()
                .fill(AppColors.tableDark.opacity(0.8))
                .ignoresSafeArea()
            
            VStack(spacing: AppLayout.paddingLarge) {
                // Pause icon
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppColors.goldAccent)
                
                // Title
                Text("Game Paused")
                    .font(AppTypography.largeTitle)
                    .foregroundColor(AppColors.primaryText)
                
                // Buttons
                VStack(spacing: AppLayout.paddingMedium) {
                    Button("Resume") {
                        viewModel.resumeGame()
                        HapticsManager.shared.lightImpact()
                        SoundManager.shared.playTap()
                    }
                    .font(AppTypography.buttonMedium)
                    .primaryButton()
                    
                    HStack(spacing: AppLayout.paddingMedium) {
                        Button("Restart") {
                            viewModel.restartGame()
                            HapticsManager.shared.lightImpact()
                            SoundManager.shared.playTap()
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
                        
                        Button("Exit") {
                            dismiss()
                        }
                        .font(AppTypography.buttonMedium)
                        .frame(height: AppLayout.buttonHeight)
                        .frame(maxWidth: .infinity)
                        .background(AppColors.heartDiamondRed.opacity(0.8))
                        .foregroundColor(AppColors.primaryText)
                        .cornerRadius(AppLayout.cornerRadius)
                    }
                }
            }
            .padding(AppLayout.paddingLarge)
        }
        .transition(.opacity.combined(with: .scale))
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.gameState)
    }
}

// MARK: - Falling Card View
struct FallingCardView: View {
    let fallingCard: FallingCard
    let onTap: (Card) -> Void
    
    var body: some View {
        CardView(card: fallingCard.card, size: .medium)
            .position(fallingCard.position)
            .rotationEffect(.degrees(fallingCard.rotation))
            .scaleEffect(fallingCard.scale)
            .onTapGesture {
                onTap(fallingCard.card)
            }
            .animation(.none, value: fallingCard.position)
    }
}

// MARK: - Parallax Background View
struct ParallaxBackgroundView: View {
    let offset: CGFloat
    
    var body: some View {
        ZStack {
            // Floating suit symbols
            ForEach(0..<20, id: \.self) { index in
                Text(Suit.allCases[index % 4].rawValue)
                    .font(.system(size: CGFloat.random(in: 20...40)))
                    .foregroundColor(
                        Suit.allCases[index % 4].color == .red ?
                        AppColors.heartDiamondRed.opacity(0.1) :
                        AppColors.clubSpadeBlack.opacity(0.1)
                    )
                    .position(
                        x: CGFloat.random(in: 0...400),
                        y: CGFloat(index * 50) + offset * 0.3
                    )
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Stat Item View
struct StatItemView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppTypography.body)
                .foregroundColor(AppColors.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(AppTypography.bodyMedium)
                .foregroundColor(color)
        }
    }
}

#Preview {
    NavigationView {
        DeckCatchView()
    }
}
