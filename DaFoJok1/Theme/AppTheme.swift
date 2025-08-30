//
//  AppTheme.swift
//  DaFoJok1
//
//  Created by IGOR on 29/08/2025.
//

import SwiftUI

// MARK: - App Colors
struct AppColors {
    // Main poker theme colors
    static let feltGreen = Color(red: 0.04, green: 0.24, blue: 0.18) // #0A3D2E
    static let tableDark = Color(red: 0.055, green: 0.055, blue: 0.055) // #0E0E0E
    static let cardWhite = Color(red: 0.96, green: 0.96, blue: 0.96) // #F5F5F5
    static let cardBackBurgundy = Color(red: 0.48, green: 0.06, blue: 0.13) // #7A1022
    static let goldAccent = Color(red: 0.78, green: 0.65, blue: 0.32) // #C7A552
    
    // Card colors
    static let heartDiamondRed = Color(red: 0.85, green: 0.23, blue: 0.18) // #D93A2E
    static let clubSpadeBlack = Color(red: 0.11, green: 0.11, blue: 0.12) // #1C1C1E
    
    // Status colors
    static let successGreen = Color(red: 0.09, green: 0.65, blue: 0.35) // #18A558
    static let warningAmber = Color(red: 1.0, green: 0.69, blue: 0.13) // #FFB020
    
    // Gradients
    static let tableGradient = RadialGradient(
        colors: [feltGreen, tableDark],
        center: .center,
        startRadius: 50,
        endRadius: 400
    )
    
    static let goldButtonGradient = LinearGradient(
        colors: [goldAccent, goldAccent.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Text colors with opacity
    static let primaryText = cardWhite
    static let secondaryText = cardWhite.opacity(0.8)
    static let tertiaryText = cardWhite.opacity(0.7)
}

// MARK: - Typography
struct AppTypography {
    // Title styles
    static let largeTitle = Font.system(size: 28, weight: .semibold, design: .default)
    static let title = Font.system(size: 24, weight: .semibold, design: .default)
    static let subtitle = Font.system(size: 20, weight: .medium, design: .default)
    
    // Body styles
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 17, weight: .medium, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let caption = Font.system(size: 15, weight: .regular, design: .default)
    
    // Button styles
    static let buttonLarge = Font.system(size: 18, weight: .semibold, design: .default)
    static let buttonMedium = Font.system(size: 16, weight: .medium, design: .default)
    static let buttonSmall = Font.system(size: 14, weight: .medium, design: .default)
    
    // Card text
    static let cardRank = Font.system(size: 20, weight: .bold, design: .default)
    static let cardSuit = Font.system(size: 24, weight: .regular, design: .default)
}

// MARK: - Layout Constants
struct AppLayout {
    static let cornerRadius: CGFloat = 12
    static let cardCornerRadius: CGFloat = 12
    static let buttonHeight: CGFloat = 50
    static let cardAspectRatio: CGFloat = 0.714 // Standard playing card ratio
    
    // Spacing
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24
    static let paddingXLarge: CGFloat = 32
    
    // Shadows
    static let cardShadow = Shadow(
        color: .black.opacity(0.2),
        radius: 4,
        x: 0,
        y: 2
    )
    
    static let buttonShadow = Shadow(
        color: .black.opacity(0.3),
        radius: 6,
        x: 0,
        y: 3
    )
}

// MARK: - Shadow Helper
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions for Theme
extension View {
    func appBackground() -> some View {
        self.background(AppColors.tableGradient)
    }
    
    func cardShadow() -> some View {
        self.shadow(
            color: AppLayout.cardShadow.color,
            radius: AppLayout.cardShadow.radius,
            x: AppLayout.cardShadow.x,
            y: AppLayout.cardShadow.y
        )
    }
    
    func buttonShadow() -> some View {
        self.shadow(
            color: AppLayout.buttonShadow.color,
            radius: AppLayout.buttonShadow.radius,
            x: AppLayout.buttonShadow.x,
            y: AppLayout.buttonShadow.y
        )
    }
    
    func goldButton() -> some View {
        self
            .background(AppColors.goldButtonGradient)
            .foregroundColor(AppColors.tableDark)
            .cornerRadius(AppLayout.cornerRadius)
            .buttonShadow()
    }
    
    func primaryButton() -> some View {
        self
            .frame(height: AppLayout.buttonHeight)
            .frame(maxWidth: .infinity)
            .goldButton()
    }
}

