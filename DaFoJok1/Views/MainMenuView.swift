import SwiftUI

struct MainMenuView: View {
    @ObservedObject private var userDefaults = UserDefaultsManager.shared
    @State private var showingHelp = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AppColors.tableGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 40) {
                        // Top spacing
                        Spacer(minLength: 20)
                        
                        // Header
                        VStack(spacing: 10) {
                            Text("CardForge")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primaryText)
                            
                            Text("Poker Academy")
                                .font(.title2)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        .padding(.top, 20)
                        
                        // Game buttons
                        VStack(spacing: 20) {
                            NavigationLink(destination: DeckCatchView()) {
                                GameButton(
                                    title: "Deck Catch",
                                    description: "Catch falling cards to complete the deck",
                                    icon: "suit.club.fill"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: PokerTrainerView()) {
                                GameButton(
                                    title: "Poker Trainer",
                                    description: "Learn poker hands and build streaks",
                                    icon: "brain.head.profile"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Quick stats
                        VStack(spacing: 8) {
                            Text("Your Progress")
                                .font(.headline)
                                .foregroundColor(AppColors.primaryText)
                            
                            HStack(spacing: 20) {
                                StatItem(
                                    title: "Best Streak",
                                    value: "\(userDefaults.pokerTrainerBestStreak)"
                                )
                                
                                StatItem(
                                    title: "Games Played",
                                    value: "\(userDefaults.totalSessions)"
                                )
                            }
                        }
                        .padding()
                        .background(AppColors.tableDark.opacity(0.6))
                        .cornerRadius(12)
                        
                        // Action buttons
                        HStack(spacing: 20) {
                            Button("Help") {
                                showingHelp = true
                            }
                            .font(.title3)
                            .foregroundColor(AppColors.primaryText)
                            .padding()
                            .background(AppColors.cardBackBurgundy.opacity(0.3))
                            .cornerRadius(10)
                            
                            Button("Settings") {
                                showingSettings = true
                            }
                            .font(.title3)
                            .foregroundColor(AppColors.primaryText)
                            .padding()
                            .background(AppColors.cardBackBurgundy.opacity(0.3))
                            .cornerRadius(10)
                        }
                        
                        // Bottom spacing
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingHelp) {
            HelpView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onAppear {
            NSLog("🎯 MainMenuView: onAppear called")
        }
    }
}

// Simple GameButton component
struct GameButton: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppColors.goldAccent)
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(description)
                    .font(.callout)
                    .foregroundColor(AppColors.secondaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
            }
            
            Spacer(minLength: 8)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.goldAccent)
        }
        .padding()
        .background(AppColors.cardWhite.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.goldAccent.opacity(0.3), lineWidth: 1)
        )
    }
}

// Simple StatItem component
struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.goldAccent)
            
            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.secondaryText)
        }
    }
}

#Preview {
    MainMenuView()
}