//
//  RootView.swift
//  DaFoJok1
//
//  Created by IGOR on 29/08/2025.
//

import SwiftUI

extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
}

struct RootView: View {
    @State private var hasOnboarded = UserDefaults.standard.bool(forKey: "hasOnboarded")
    
    var body: some View {
        ZStack {
            // Ensure we have a background
            AppColors.tableGradient
                .ignoresSafeArea()
            
            Group {
                if hasOnboarded {
                    MainMenuView()
                } else {
                                            OnboardingView(onComplete: {
                            NSLog("🎯 RootView: Onboarding completed")
                            UserDefaults.standard.set(true, forKey: "hasOnboarded")
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                hasOnboarded = true
                            }
                        })
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            NSLog("🎯 RootView: onAppear - hasOnboarded = \(hasOnboarded)")
            NSLog("🎯 RootView: UserDefaults value = \(UserDefaults.standard.bool(forKey: "hasOnboarded"))")
            NSLog("🎯 RootView: Will show \(hasOnboarded ? "MainMenu" : "Onboarding")")
        }
    }
}

#Preview {
    RootView()
}
