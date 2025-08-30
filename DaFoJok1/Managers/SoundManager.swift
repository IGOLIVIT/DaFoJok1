//
//  SoundManager.swift
//  DaFoJok1
//
//  Created by IGOR on 29/08/2025.
//

import AVFoundation
import UIKit

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "soundEnabled")
        }
    }
    
    private init() {
        self.isSoundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        // Default to true if not set
        if UserDefaults.standard.object(forKey: "soundEnabled") == nil {
            self.isSoundEnabled = true
        }
    }
    
    // Play system sounds (no external assets needed)
    func playSuccess() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1057) // Success sound
    }
    
    func playError() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1053) // Error sound
    }
    
    func playTap() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1104) // Tap sound
    }
    
    func playCardFlip() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1105) // Card flip sound
    }
    
    func playGameComplete() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1025) // Game complete sound
    }
    
    func playCombo() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1016) // Combo sound
    }
    
    // Toggle sound setting
    func toggleSound() {
        isSoundEnabled.toggle()
    }
}
