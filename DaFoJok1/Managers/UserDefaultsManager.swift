//
//  UserDefaultsManager.swift
//  DaFoJok1
//
//  Created by IGOR on 29/08/2025.
//

import Foundation

class UserDefaultsManager: ObservableObject {
    static let shared = UserDefaultsManager()
    
    // MARK: - Keys
    private enum Keys {
        static let hasOnboarded = "hasOnboarded"
        static let soundEnabled = "soundEnabled"
        static let vibrationEnabled = "vibrationEnabled"
        
        // Deck Catch Stats
        static let deckCatchBestTime = "deckCatchBestTime"
        static let deckCatchBestAccuracy = "deckCatchBestAccuracy"
        static let deckCatchTotalSessions = "deckCatchTotalSessions"
        static let deckCatchLastPlayed = "deckCatchLastPlayed"
        
        // Poker Trainer Stats
        static let pokerTrainerBestStreak = "pokerTrainerBestStreak"
        static let pokerTrainerTotalSessions = "pokerTrainerTotalSessions"
        static let pokerTrainerLastPlayed = "pokerTrainerLastPlayed"
        static let pokerTrainerCorrectAnswers = "pokerTrainerCorrectAnswers"
        static let pokerTrainerTotalAnswers = "pokerTrainerTotalAnswers"
    }
    
    // MARK: - Published Properties
    @Published var hasOnboarded: Bool {
        didSet { 
            print("🎯 UserDefaultsManager: hasOnboarded set to \(hasOnboarded)")
            UserDefaults.standard.set(hasOnboarded, forKey: Keys.hasOnboarded) 
        }
    }
    
    @Published var soundEnabled: Bool {
        didSet { UserDefaults.standard.set(soundEnabled, forKey: Keys.soundEnabled) }
    }
    
    @Published var vibrationEnabled: Bool {
        didSet { UserDefaults.standard.set(vibrationEnabled, forKey: Keys.vibrationEnabled) }
    }
    
    private init() {
        self.hasOnboarded = UserDefaults.standard.bool(forKey: Keys.hasOnboarded)
        self.soundEnabled = UserDefaults.standard.object(forKey: Keys.soundEnabled) as? Bool ?? true
        self.vibrationEnabled = UserDefaults.standard.object(forKey: Keys.vibrationEnabled) as? Bool ?? true
        
        print("🎯 UserDefaultsManager: initialized with hasOnboarded = \(hasOnboarded)")
    }
    
    // MARK: - Deck Catch Stats
    var deckCatchBestTime: TimeInterval {
        get { UserDefaults.standard.double(forKey: Keys.deckCatchBestTime) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.deckCatchBestTime) }
    }
    
    var deckCatchBestAccuracy: Double {
        get { UserDefaults.standard.double(forKey: Keys.deckCatchBestAccuracy) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.deckCatchBestAccuracy) }
    }
    
    var deckCatchTotalSessions: Int {
        get { UserDefaults.standard.integer(forKey: Keys.deckCatchTotalSessions) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.deckCatchTotalSessions) }
    }
    
    var deckCatchLastPlayed: Date? {
        get { UserDefaults.standard.object(forKey: Keys.deckCatchLastPlayed) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: Keys.deckCatchLastPlayed) }
    }
    
    // MARK: - Poker Trainer Stats
    var pokerTrainerBestStreak: Int {
        get { UserDefaults.standard.integer(forKey: Keys.pokerTrainerBestStreak) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.pokerTrainerBestStreak) }
    }
    
    var pokerTrainerTotalSessions: Int {
        get { UserDefaults.standard.integer(forKey: Keys.pokerTrainerTotalSessions) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.pokerTrainerTotalSessions) }
    }
    
    var pokerTrainerLastPlayed: Date? {
        get { UserDefaults.standard.object(forKey: Keys.pokerTrainerLastPlayed) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: Keys.pokerTrainerLastPlayed) }
    }
    
    var pokerTrainerCorrectAnswers: Int {
        get { UserDefaults.standard.integer(forKey: Keys.pokerTrainerCorrectAnswers) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.pokerTrainerCorrectAnswers) }
    }
    
    var pokerTrainerTotalAnswers: Int {
        get { UserDefaults.standard.integer(forKey: Keys.pokerTrainerTotalAnswers) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.pokerTrainerTotalAnswers) }
    }
    
    // MARK: - Computed Properties
    var totalSessions: Int {
        return deckCatchTotalSessions + pokerTrainerTotalSessions
    }
    
    var lastPlayedDate: Date? {
        let dates = [deckCatchLastPlayed, pokerTrainerLastPlayed].compactMap { $0 }
        return dates.max()
    }
    
    var pokerTrainerAccuracy: Double {
        guard pokerTrainerTotalAnswers > 0 else { return 0 }
        return Double(pokerTrainerCorrectAnswers) / Double(pokerTrainerTotalAnswers)
    }
    
    // MARK: - Update Methods
    func updateDeckCatchStats(time: TimeInterval, accuracy: Double) {
        // Update best time (lower is better)
        if deckCatchBestTime == 0 || time < deckCatchBestTime {
            deckCatchBestTime = time
        }
        
        // Update best accuracy (higher is better)
        if accuracy > deckCatchBestAccuracy {
            deckCatchBestAccuracy = accuracy
        }
        
        deckCatchTotalSessions += 1
        deckCatchLastPlayed = Date()
    }
    
    func updatePokerTrainerStats(streak: Int, isCorrect: Bool) {
        if streak > pokerTrainerBestStreak {
            pokerTrainerBestStreak = streak
        }
        
        if isCorrect {
            pokerTrainerCorrectAnswers += 1
        }
        pokerTrainerTotalAnswers += 1
        pokerTrainerLastPlayed = Date()
    }
    
    func incrementPokerTrainerSessions() {
        pokerTrainerTotalSessions += 1
    }
    
    // MARK: - Reset Methods
    func resetAllProgress() {
        // Keep onboarding status - user shouldn't see onboarding again
        // hasOnboarded remains unchanged
        
        // Reset Deck Catch stats
        deckCatchBestTime = 0
        deckCatchBestAccuracy = 0
        deckCatchTotalSessions = 0
        deckCatchLastPlayed = nil
        
        // Reset Poker Trainer stats
        pokerTrainerBestStreak = 0
        pokerTrainerTotalSessions = 0
        pokerTrainerLastPlayed = nil
        pokerTrainerCorrectAnswers = 0
        pokerTrainerTotalAnswers = 0
        
        // Keep settings (sound, vibration) unchanged
    }
    
    // MARK: - Debug Reset (includes onboarding)
    func resetEverything() {
        hasOnboarded = false
        UserDefaults.standard.set(false, forKey: "hasOnboarded") // Also reset AppStorage
        resetAllProgress()
    }
    
    // MARK: - Formatted Strings
    func formattedLastPlayed() -> String {
        guard let date = lastPlayedDate else { return "Never" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
    
    func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    func formattedAccuracy(_ accuracy: Double) -> String {
        return String(format: "%.1f%%", accuracy * 100)
    }
}
