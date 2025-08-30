//
//  DeckCatchViewModel.swift
//  DaFoJok1
//
//  Created by IGOR on 29/08/2025.
//

import SwiftUI
import Combine

// MARK: - Falling Card Model
struct FallingCard: Identifiable, Equatable {
    let id = UUID()
    let card: Card
    var position: CGPoint
    var rotation: Double
    var scale: Double
    var velocity: CGFloat
    
    static func == (lhs: FallingCard, rhs: FallingCard) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Game State
enum DeckCatchGameState {
    case playing
    case paused
    case gameOver
}

// MARK: - Deck Catch View Model
class DeckCatchViewModel: ObservableObject {
    @Published var fallingCards: [FallingCard] = []
    @Published var collectedCount = 0
    @Published var missedCount = 0
    @Published var comboCount = 0
    @Published var gameState: DeckCatchGameState = .playing
    @Published var gameTime: TimeInterval = 0
    @Published var backgroundOffset: CGFloat = 0
    @Published var isNewRecord = false
    
    private var gameTimer: Timer?
    private var cardSpawnTimer: Timer?
    private var animationTimer: Timer?
    private var deckManager = DeckManager()
    private var availableCards: [Card] = []
    private var startTime: Date?
    private let userDefaults = UserDefaultsManager.shared
    
    // Game configuration
    private let cardSpawnInterval: TimeInterval = 1.5
    private let cardFallSpeed: CGFloat = 2.0
    private let screenWidth: CGFloat = UIScreen.main.bounds.width
    private let screenHeight: CGFloat = UIScreen.main.bounds.height
    private let missLineY: CGFloat = UIScreen.main.bounds.height - 100
    
    var formattedTime: String {
        let minutes = Int(gameTime) / 60
        let seconds = Int(gameTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var accuracy: Double {
        let total = collectedCount + missedCount
        guard total > 0 else { return 0 }
        return Double(collectedCount) / Double(total)
    }
    
    var formattedAccuracy: String {
        return String(format: "%.1f%%", accuracy * 100)
    }
    
    var bestRecordText: String {
        let bestTime = userDefaults.deckCatchBestTime
        let bestAccuracy = userDefaults.deckCatchBestAccuracy
        
        if bestTime > 0 {
            let minutes = Int(bestTime) / 60
            let seconds = Int(bestTime) % 60
            let timeString = String(format: "%d:%02d", minutes, seconds)
            let accuracyString = String(format: "%.1f%%", bestAccuracy * 100)
            return "\(timeString) • \(accuracyString)"
        } else {
            return "No record yet"
        }
    }
    
    init() {
        setupGame()
    }
    
    // MARK: - Game Setup
    private func setupGame() {
        availableCards = deckManager.getShuffledDeck()
        collectedCount = 0
        missedCount = 0
        comboCount = 0
        gameTime = 0
        fallingCards = []
        backgroundOffset = 0
        isNewRecord = false
        gameState = .paused // Start in paused state, will be set to playing in startGame()
    }
    
    // MARK: - Game Control
    func startGame() {
        NSLog("🎯 DeckCatch: startGame called, current state: \(gameState)")
        guard gameState != .playing else { 
            NSLog("🎯 DeckCatch: Game already playing, returning")
            return 
        }
        
        gameState = .playing
        startTime = Date()
        NSLog("🎯 DeckCatch: Game started, setting up timers")
        
        // Start timers
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateGameTime()
        }
        
        cardSpawnTimer = Timer.scheduledTimer(withTimeInterval: cardSpawnInterval, repeats: true) { _ in
            self.spawnCard()
        }
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            self.updateCardPositions()
            self.updateBackgroundOffset()
        }
        
        // Spawn first card immediately
        spawnCard()
    }
    
    func pauseGame() {
        gameState = .paused
        stopTimers()
    }
    
    func resumeGame() {
        guard gameState == .paused else { return }
        gameState = .playing
        
        // Restart timers
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateGameTime()
        }
        
        cardSpawnTimer = Timer.scheduledTimer(withTimeInterval: cardSpawnInterval, repeats: true) { _ in
            self.spawnCard()
        }
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            self.updateCardPositions()
            self.updateBackgroundOffset()
        }
    }
    
    func restartGame() {
        stopTimers()
        setupGame()
        startGame()
    }
    
    private func endGame() {
        gameState = .gameOver
        stopTimers()
        
        // Check for new record and save stats
        let previousBestTime = userDefaults.deckCatchBestTime
        let previousBestAccuracy = userDefaults.deckCatchBestAccuracy
        
        if collectedCount == 52 {
            // Complete deck - check time record
            if previousBestTime == 0 || gameTime < previousBestTime {
                isNewRecord = true
                HapticsManager.shared.heavyImpact()
                SoundManager.shared.playGameComplete()
            }
        }
        
        // Check accuracy record
        if accuracy > previousBestAccuracy {
            isNewRecord = true
            HapticsManager.shared.heavyImpact()
            SoundManager.shared.playGameComplete()
        }
        
        // Save stats
        userDefaults.updateDeckCatchStats(time: gameTime, accuracy: accuracy)
    }
    
    private func stopTimers() {
        gameTimer?.invalidate()
        cardSpawnTimer?.invalidate()
        animationTimer?.invalidate()
        gameTimer = nil
        cardSpawnTimer = nil
        animationTimer = nil
    }
    
    // MARK: - Game Logic
    private func updateGameTime() {
        guard let startTime = startTime else { return }
        gameTime = Date().timeIntervalSince(startTime)
    }
    
    private func spawnCard() {
        NSLog("🎯 DeckCatch: spawnCard called, gameState: \(gameState), availableCards: \(availableCards.count)")
        guard gameState == .playing, !availableCards.isEmpty else {
            NSLog("🎯 DeckCatch: Cannot spawn card - gameState: \(gameState), availableCards: \(availableCards.count)")
            if availableCards.isEmpty && fallingCards.isEmpty {
                endGame()
            }
            return
        }
        
        let card = availableCards.removeFirst()
        let startX = CGFloat.random(in: 50...(screenWidth - 50))
        let rotation = Double.random(in: -15...15)
        let scale = Double.random(in: 0.8...1.0)
        
        // Increase velocity slightly as game progresses
        let progressMultiplier = 1.0 + (Double(52 - availableCards.count) / 52.0) * 0.5
        let velocity = cardFallSpeed * CGFloat(progressMultiplier)
        
        let fallingCard = FallingCard(
            card: card,
            position: CGPoint(x: startX, y: -100),
            rotation: rotation,
            scale: scale,
            velocity: velocity
        )
        
        fallingCards.append(fallingCard)
    }
    
    private func updateCardPositions() {
        guard gameState == .playing else { return }
        
        // Update card positions
        for i in fallingCards.indices.reversed() {
            fallingCards[i].position.y += fallingCards[i].velocity
            
            // Check if card passed the miss line
            if fallingCards[i].position.y > missLineY {
                missCard(at: i)
            }
        }
    }
    
    private func updateBackgroundOffset() {
        guard gameState == .playing else { return }
        
        // Update background offset for parallax effect
        backgroundOffset += 0.5
    }
    
    func catchCard(_ card: Card) {
        guard let index = fallingCards.firstIndex(where: { $0.card == card }) else { return }
        
        // Remove card from falling cards
        fallingCards.remove(at: index)
        
        // Update stats
        collectedCount += 1
        comboCount += 1
        
        // Play feedback
        HapticsManager.shared.success()
        SoundManager.shared.playSuccess()
        
        if comboCount % 5 == 0 {
            SoundManager.shared.playCombo()
        }
        
        // Check if deck is complete
        if collectedCount == 52 {
            endGame()
        }
    }
    
    private func missCard(at index: Int) {
        fallingCards.remove(at: index)
        missedCount += 1
        comboCount = 0
        
        // Play feedback
        HapticsManager.shared.error()
        SoundManager.shared.playError()
        
        // Check if all cards are used
        if availableCards.isEmpty && fallingCards.isEmpty {
            endGame()
        }
    }
    
    deinit {
        stopTimers()
    }
}

