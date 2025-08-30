//
//  HapticsManager.swift
//  DaFoJok1
//
//  Created by IGOR on 29/08/2025.
//

import UIKit

class HapticsManager {
    static let shared = HapticsManager()
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    private init() {}
    
    // Success feedback (card collected, correct answer)
    func success() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    // Error feedback (card missed, wrong answer)
    func error() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    // Warning feedback (time running out)
    func warning() {
        notificationGenerator.notificationOccurred(.warning)
    }
    
    // Light impact (button tap)
    func lightImpact() {
        impactLight.impactOccurred()
    }
    
    // Medium impact (card tap)
    func mediumImpact() {
        impactMedium.impactOccurred()
    }
    
    // Heavy impact (game complete, record broken)
    func heavyImpact() {
        impactHeavy.impactOccurred()
    }
    
    // Prepare generators for better performance
    func prepare() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notificationGenerator.prepare()
    }
}

