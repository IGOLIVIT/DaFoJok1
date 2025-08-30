//
//  CardView.swift
//  DaFoJok1
//
//  Created by IGOR on 29/08/2025.
//

import SwiftUI

struct CardView: View {
    let card: Card
    let size: CardSize
    let isFlipped: Bool
    
    init(card: Card, size: CardSize = .medium, isFlipped: Bool = false) {
        self.card = card
        self.size = size
        self.isFlipped = isFlipped
    }
    
    var body: some View {
        ZStack {
            if isFlipped {
                CardBackView(size: size)
            } else {
                CardFaceView(card: card, size: size)
            }
        }
        .aspectRatio(AppLayout.cardAspectRatio, contentMode: .fit)
        .frame(width: size.width, height: size.height)
    }
}

// MARK: - Card Face View
struct CardFaceView: View {
    let card: Card
    let size: CardSize
    
    var suitColor: Color {
        switch card.suit.color {
        case .red:
            return AppColors.heartDiamondRed
        case .black:
            return AppColors.clubSpadeBlack
        }
    }
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: AppLayout.cardCornerRadius)
                .fill(AppColors.cardWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: AppLayout.cardCornerRadius)
                        .stroke(AppColors.goldAccent, lineWidth: 1)
                )
            
            VStack(spacing: 0) {
                // Top rank and suit
                HStack {
                    VStack(spacing: 2) {
                        Text(card.rank.rawValue)
                            .font(size.rankFont)
                            .foregroundColor(suitColor)
                        Text(card.suit.rawValue)
                            .font(size.suitFont)
                            .foregroundColor(suitColor)
                    }
                    Spacer()
                }
                .padding(.top, size.padding)
                .padding(.leading, size.padding)
                
                Spacer()
                
                // Center suit symbol
                Text(card.suit.rawValue)
                    .font(size.centerSuitFont)
                    .foregroundColor(suitColor)
                
                Spacer()
                
                // Bottom rank and suit (rotated)
                HStack {
                    Spacer()
                    VStack(spacing: 2) {
                        Text(card.suit.rawValue)
                            .font(size.suitFont)
                            .foregroundColor(suitColor)
                        Text(card.rank.rawValue)
                            .font(size.rankFont)
                            .foregroundColor(suitColor)
                    }
                    .rotationEffect(.degrees(180))
                }
                .padding(.bottom, size.padding)
                .padding(.trailing, size.padding)
            }
        }
        .cardShadow()
    }
}

// MARK: - Card Back View
struct CardBackView: View {
    let size: CardSize
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: AppLayout.cardCornerRadius)
                .fill(AppColors.cardBackBurgundy)
            
            // Pattern overlay using Canvas
            Canvas { context, canvasSize in
                let patternSize: CGFloat = 20
                let rows = Int(canvasSize.height / patternSize) + 1
                let cols = Int(canvasSize.width / patternSize) + 1
                
                for row in 0..<rows {
                    for col in 0..<cols {
                        let x = CGFloat(col) * patternSize
                        let y = CGFloat(row) * patternSize
                        
                        // Create diamond pattern
                        let path = Path { path in
                            path.move(to: CGPoint(x: x + patternSize/2, y: y))
                            path.addLine(to: CGPoint(x: x + patternSize, y: y + patternSize/2))
                            path.addLine(to: CGPoint(x: x + patternSize/2, y: y + patternSize))
                            path.addLine(to: CGPoint(x: x, y: y + patternSize/2))
                            path.closeSubpath()
                        }
                        
                        context.fill(path, with: .color(AppColors.goldAccent.opacity(0.2)))
                    }
                }
            }
            
            // Border
            RoundedRectangle(cornerRadius: AppLayout.cardCornerRadius)
                .stroke(AppColors.goldAccent, lineWidth: 1)
        }
        .cardShadow()
    }
}

// MARK: - Card Size Enum
enum CardSize {
    case small
    case medium
    case large
    
    var width: CGFloat {
        switch self {
        case .small: return 60
        case .medium: return 80
        case .large: return 120
        }
    }
    
    var height: CGFloat {
        return width / AppLayout.cardAspectRatio
    }
    
    var padding: CGFloat {
        switch self {
        case .small: return 4
        case .medium: return 6
        case .large: return 8
        }
    }
    
    var rankFont: Font {
        switch self {
        case .small: return .system(size: 12, weight: .bold)
        case .medium: return .system(size: 16, weight: .bold)
        case .large: return .system(size: 20, weight: .bold)
        }
    }
    
    var suitFont: Font {
        switch self {
        case .small: return .system(size: 14, weight: .regular)
        case .medium: return .system(size: 18, weight: .regular)
        case .large: return .system(size: 24, weight: .regular)
        }
    }
    
    var centerSuitFont: Font {
        switch self {
        case .small: return .system(size: 24, weight: .regular)
        case .medium: return .system(size: 32, weight: .regular)
        case .large: return .system(size: 48, weight: .regular)
        }
    }
}

// MARK: - Animated Card View
struct AnimatedCardView: View {
    let card: Card
    let size: CardSize
    @State private var isFlipped = true
    @State private var rotation: Double = 0
    
    var body: some View {
        CardView(card: card, size: size, isFlipped: isFlipped)
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0, y: 1, z: 0)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6)) {
                    rotation = 180
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isFlipped = false
                }
            }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 16) {
            CardView(card: Card(suit: .hearts, rank: .ace), size: .small)
            CardView(card: Card(suit: .spades, rank: .king), size: .medium)
            CardView(card: Card(suit: .diamonds, rank: .queen), size: .large)
        }
        
        HStack(spacing: 16) {
            CardView(card: Card(suit: .clubs, rank: .jack), size: .medium, isFlipped: true)
            AnimatedCardView(card: Card(suit: .hearts, rank: .ten), size: .medium)
        }
    }
    .padding()
    .appBackground()
}

