//
//  OnboardingView.swift
//  DaFoJok1
//
//  Created by IGOR on 29/08/2025.
//

import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    
    @State private var currentPage = 0
    @State private var animateCards = false
    @State private var animateButton = false
    
    let pages = [
        OnboardingPage(
            title: "Welcome to CardForge",
            subtitle: "Poker Academy",
            description: "Master the art of poker through engaging mini-games and training exercises.",
            systemImage: "suit.heart.fill"
        ),
        OnboardingPage(
            title: "Deck Catch",
            subtitle: "Collect All 52 Cards",
            description: "Tap falling cards to complete the deck. Test your reflexes and build combos!",
            systemImage: "hand.tap.fill"
        ),
        OnboardingPage(
            title: "Poker Rank Trainer",
            subtitle: "Master Hand Rankings",
            description: "Train to recognize poker hands instantly and build your winning streak.",
            systemImage: "brain.head.profile"
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                AppColors.tableGradient
                    .ignoresSafeArea()
                

                VStack(spacing: 0) {
                    // Skip button
                    HStack {
                        Spacer()
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .font(AppTypography.buttonMedium)
                        .foregroundColor(AppColors.secondaryText)
                        .padding()
                    }
                    
                    // Page content
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            OnboardingPageView(
                                page: pages[index],
                                animateCards: animateCards,
                                geometry: geometry
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.5), value: currentPage)
                    
                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? AppColors.goldAccent : AppColors.secondaryText)
                                .frame(width: 10, height: 10)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                    .padding(.vertical, AppLayout.paddingLarge)
                    
                    // Action buttons
                    VStack(spacing: AppLayout.paddingMedium) {
                        if currentPage < pages.count - 1 {
                            Button("Next") {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    currentPage += 1
                                }
                                HapticsManager.shared.lightImpact()
                                SoundManager.shared.playTap()
                            }
                            .font(AppTypography.buttonLarge)
                            .primaryButton()
                            .scaleEffect(animateButton ? 1.05 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6).repeatForever(autoreverses: true), value: animateButton)
                        } else {
                            Button("Start Playing") {
                                completeOnboarding()
                            }
                            .font(AppTypography.buttonLarge)
                            .primaryButton()
                            .scaleEffect(animateButton ? 1.05 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6).repeatForever(autoreverses: true), value: animateButton)
                        }
                    }
                    .padding(.horizontal, AppLayout.paddingLarge)
                    .padding(.bottom, AppLayout.paddingXLarge)
                }
            }
        }
        .onAppear {
            NSLog("🎯 OnboardingView: onAppear called")
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
            animateCards = true
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.0)) {
            animateButton = true
        }
    }
    
    private func completeOnboarding() {
        NSLog("🎯 OnboardingView: completeOnboarding called")
        
        HapticsManager.shared.success()
        SoundManager.shared.playSuccess()
        
        // Update UserDefaults for consistency
        UserDefaultsManager.shared.hasOnboarded = true
        
        // Call completion callback
        onComplete()
        
        NSLog("🎯 OnboardingView: onComplete called")
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let systemImage: String
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    let animateCards: Bool
    let geometry: GeometryProxy
    
    @State private var floatingOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: AppLayout.paddingLarge) {
            Spacer()
            
            // Animated card decoration
            ZStack {
                // Background cards with fan spread
                ForEach(0..<5, id: \.self) { index in
                    CardView(
                        card: Card(suit: Suit.allCases[index % 4], rank: Rank.allCases[index * 2]),
                        size: .medium,
                        isFlipped: true
                    )
                    .rotationEffect(.degrees(Double(index - 2) * 15))
                    .offset(
                        x: CGFloat(index - 2) * 20,
                        y: CGFloat(abs(index - 2)) * -10
                    )
                    .scaleEffect(animateCards ? 1.0 : 0.5)
                    .opacity(animateCards ? 0.8 : 0.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(Double(index) * 0.1), value: animateCards)
                }
                
                // Floating card pips
                TimelineView(.animation(minimumInterval: 2.0)) { timeline in
                    ZStack {
                        ForEach(0..<3, id: \.self) { index in
                            Text(Suit.allCases[index].rawValue)
                                .font(.system(size: 24))
                                .foregroundColor(Suit.allCases[index].color == .red ? AppColors.heartDiamondRed : AppColors.clubSpadeBlack)
                                .offset(
                                    x: sin(timeline.date.timeIntervalSince1970 + Double(index)) * 30,
                                    y: cos(timeline.date.timeIntervalSince1970 + Double(index) * 1.5) * 20
                                )
                                .opacity(0.6)
                        }
                    }
                }
                .opacity(animateCards ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 1.0), value: animateCards)
            }
            .frame(height: 200)
            
            Spacer()
            
            // Content
            VStack(spacing: AppLayout.paddingMedium) {
                // System icon
                Image(systemName: page.systemImage)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(AppColors.goldAccent)
                    .scaleEffect(animateCards ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateCards)
                
                // Title
                Text(page.title)
                    .font(AppTypography.largeTitle)
                    .foregroundColor(AppColors.primaryText)
                    .multilineTextAlignment(.center)
                    .opacity(animateCards ? 1.0 : 0.0)
                    .offset(y: animateCards ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: animateCards)
                
                // Subtitle
                Text(page.subtitle)
                    .font(AppTypography.subtitle)
                    .foregroundColor(AppColors.goldAccent)
                    .multilineTextAlignment(.center)
                    .opacity(animateCards ? 1.0 : 0.0)
                    .offset(y: animateCards ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.5), value: animateCards)
                
                // Description
                Text(page.description)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppLayout.paddingLarge)
                    .opacity(animateCards ? 1.0 : 0.0)
                    .offset(y: animateCards ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.6), value: animateCards)
            }
            
            Spacer()
        }
        .padding(.horizontal, AppLayout.paddingLarge)
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
