//
//  PokerTrainerViewModel.swift
//  DaFoJok1
//
//  Created by IGOR on 29/08/2025.
//

import Foundation
import SwiftUI

// MARK: - Game Mode
enum PokerTrainerGameMode {
    case quickTraining
    case tenRounds
}

// MARK: - Game State
enum PokerTrainerGameState {
    case playing
    case gameOver
}

// MARK: - Poker Trainer View Model
class PokerTrainerViewModel: ObservableObject {
    @Published var currentHand: [Card] = []
    @Published var correctHandType: PokerHandType = .highCard
    @Published var selectedAnswer: PokerHandType?
    @Published var showingResult = false
    @Published var lastAnswerCorrect = false
    @Published var currentStreak = 0
    @Published var gameState: PokerTrainerGameState = .playing
    @Published var gameMode: PokerTrainerGameMode = .quickTraining
    @Published var currentRound = 0
    @Published var correctAnswers = 0
    @Published var totalAnswers = 0
    @Published var isNewRecord = false
    
    private let deckManager = DeckManager()
    private let userDefaults = UserDefaultsManager.shared
    
    // MARK: - Game Control
    func startGame(mode: PokerTrainerGameMode) {
        gameMode = mode
        resetGame()
        dealNewHand()
    }
    
    func resetGame() {
        currentStreak = 0
        currentRound = 0
        correctAnswers = 0
        totalAnswers = 0
        gameState = .playing
        showingResult = false
        selectedAnswer = nil
        isNewRecord = false
    }
    
    func restartGame() {
        resetGame()
        dealNewHand()
    }
    
    // MARK: - Hand Dealing
    private func dealNewHand() {
        guard gameState == .playing else { return }
        
        // Deal 5 unique cards
        currentHand = deckManager.dealCards(count: 5)
        correctHandType = deckManager.evaluatePokerHand(currentHand)
        selectedAnswer = nil
        showingResult = false
        
        // Increment round for 10-round mode
        if gameMode == .tenRounds {
            currentRound += 1
        }
    }
    
    // MARK: - Answer Selection
    func selectAnswer(_ answer: PokerHandType) {
        guard !showingResult else { return }
        
        selectedAnswer = answer
        lastAnswerCorrect = (answer == correctHandType)
        totalAnswers += 1
        
        if lastAnswerCorrect {
            correctAnswers += 1
            currentStreak += 1
            
            // Play success feedback
            HapticsManager.shared.success()
            SoundManager.shared.playSuccess()
            
            // Play combo sound for streaks
            if currentStreak % 5 == 0 {
                SoundManager.shared.playCombo()
            }
        } else {
            // Play error feedback
            HapticsManager.shared.error()
            SoundManager.shared.playError()
            
            // End game for quick training mode
            if gameMode == .quickTraining {
                endGame()
                return
            } else {
                // Reset streak for 10-round mode (but continue playing)
                currentStreak = 0
            }
        }
        
        // Update user defaults
        userDefaults.updatePokerTrainerStats(streak: currentStreak, isCorrect: lastAnswerCorrect)
        
        // Show result
        withAnimation(.easeInOut(duration: 0.3)) {
            showingResult = true
        }
        
        // Check if game should end (10-round mode)
        if gameMode == .tenRounds && currentRound >= 10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.endGame()
            }
        }
    }
    
    func nextHand() {
        dealNewHand()
    }
    
    // MARK: - Game End
    private func endGame() {
        gameState = .gameOver
        
        // Check for new records
        let previousBestStreak = userDefaults.pokerTrainerBestStreak
        
        if currentStreak > previousBestStreak {
            isNewRecord = true
            HapticsManager.shared.heavyImpact()
            SoundManager.shared.playGameComplete()
        }
        
        // Increment session count
        userDefaults.incrementPokerTrainerSessions()
    }
    
    // MARK: - Test Hands (for QA)
    func generateTestHands() -> [(hand: [Card], expectedType: PokerHandType)] {
        var testHands: [(hand: [Card], expectedType: PokerHandType)] = []
        
        // Royal Flush
        testHands.append((
            hand: [
                Card(suit: .hearts, rank: .ace),
                Card(suit: .hearts, rank: .king),
                Card(suit: .hearts, rank: .queen),
                Card(suit: .hearts, rank: .jack),
                Card(suit: .hearts, rank: .ten)
            ],
            expectedType: .royalFlush
        ))
        
        // Straight Flush
        testHands.append((
            hand: [
                Card(suit: .spades, rank: .nine),
                Card(suit: .spades, rank: .eight),
                Card(suit: .spades, rank: .seven),
                Card(suit: .spades, rank: .six),
                Card(suit: .spades, rank: .five)
            ],
            expectedType: .straightFlush
        ))
        
        // Four of a Kind
        testHands.append((
            hand: [
                Card(suit: .hearts, rank: .ace),
                Card(suit: .diamonds, rank: .ace),
                Card(suit: .clubs, rank: .ace),
                Card(suit: .spades, rank: .ace),
                Card(suit: .hearts, rank: .king)
            ],
            expectedType: .fourOfAKind
        ))
        
        // Full House
        testHands.append((
            hand: [
                Card(suit: .hearts, rank: .king),
                Card(suit: .diamonds, rank: .king),
                Card(suit: .clubs, rank: .king),
                Card(suit: .spades, rank: .queen),
                Card(suit: .hearts, rank: .queen)
            ],
            expectedType: .fullHouse
        ))
        
        // Flush
        testHands.append((
            hand: [
                Card(suit: .diamonds, rank: .ace),
                Card(suit: .diamonds, rank: .jack),
                Card(suit: .diamonds, rank: .nine),
                Card(suit: .diamonds, rank: .seven),
                Card(suit: .diamonds, rank: .five)
            ],
            expectedType: .flush
        ))
        
        // Straight
        testHands.append((
            hand: [
                Card(suit: .hearts, rank: .ten),
                Card(suit: .diamonds, rank: .nine),
                Card(suit: .clubs, rank: .eight),
                Card(suit: .spades, rank: .seven),
                Card(suit: .hearts, rank: .six)
            ],
            expectedType: .straight
        ))
        
        // Three of a Kind
        testHands.append((
            hand: [
                Card(suit: .hearts, rank: .jack),
                Card(suit: .diamonds, rank: .jack),
                Card(suit: .clubs, rank: .jack),
                Card(suit: .spades, rank: .nine),
                Card(suit: .hearts, rank: .seven)
            ],
            expectedType: .threeOfAKind
        ))
        
        // Two Pair
        testHands.append((
            hand: [
                Card(suit: .hearts, rank: .king),
                Card(suit: .diamonds, rank: .king),
                Card(suit: .clubs, rank: .eight),
                Card(suit: .spades, rank: .eight),
                Card(suit: .hearts, rank: .five)
            ],
            expectedType: .twoPair
        ))
        
        // One Pair
        testHands.append((
            hand: [
                Card(suit: .hearts, rank: .queen),
                Card(suit: .diamonds, rank: .queen),
                Card(suit: .clubs, rank: .jack),
                Card(suit: .spades, rank: .nine),
                Card(suit: .hearts, rank: .seven)
            ],
            expectedType: .onePair
        ))
        
        // High Card
        testHands.append((
            hand: [
                Card(suit: .hearts, rank: .ace),
                Card(suit: .diamonds, rank: .jack),
                Card(suit: .clubs, rank: .nine),
                Card(suit: .spades, rank: .seven),
                Card(suit: .hearts, rank: .five)
            ],
            expectedType: .highCard
        ))
        
        return testHands
    }
    
    // MARK: - QA Test Method
    func runHandEvaluationTests() -> [String] {
        var results: [String] = []
        let testHands = generateTestHands()
        
        for (index, testCase) in testHands.enumerated() {
            let evaluatedType = deckManager.evaluatePokerHand(testCase.hand)
            let passed = evaluatedType == testCase.expectedType
            
            let result = "Test \(index + 1): \(testCase.expectedType.rawValue) - \(passed ? "PASS" : "FAIL")"
            if !passed {
                results.append("\(result) (Got: \(evaluatedType.rawValue))")
            } else {
                results.append(result)
            }
        }
        
        return results
    }
}

