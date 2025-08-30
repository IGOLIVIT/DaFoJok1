//
//  DeckManager.swift
//  DaFoJok1
//
//  Created by IGOR on 29/08/2025.
//

import Foundation

class DeckManager: ObservableObject {
    @Published var cards: [Card] = []
    
    init() {
        generateStandardDeck()
    }
    
    // Generate standard 52-card deck
    private func generateStandardDeck() {
        cards = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                cards.append(Card(suit: suit, rank: rank))
            }
        }
    }
    
    // Fisher-Yates shuffle algorithm
    func shuffle() {
        for i in stride(from: cards.count - 1, through: 1, by: -1) {
            let j = Int.random(in: 0...i)
            cards.swapAt(i, j)
        }
    }
    
    // Get a shuffled deck
    func getShuffledDeck() -> [Card] {
        var shuffledCards = cards
        for i in stride(from: shuffledCards.count - 1, through: 1, by: -1) {
            let j = Int.random(in: 0...i)
            shuffledCards.swapAt(i, j)
        }
        return shuffledCards
    }
    
    // Deal specific number of cards
    func dealCards(count: Int) -> [Card] {
        let shuffledDeck = getShuffledDeck()
        return Array(shuffledDeck.prefix(count))
    }
    
    // Check if deck is complete (all 52 cards)
    func isComplete() -> Bool {
        return cards.count == 52
    }
    
    // Reset deck to standard 52 cards
    func reset() {
        generateStandardDeck()
    }
}

// MARK: - Poker Hand Evaluator
extension DeckManager {
    
    // Evaluate poker hand type from 5 cards
    func evaluatePokerHand(_ hand: [Card]) -> PokerHandType {
        guard hand.count == 5 else { return .highCard }
        
        let sortedHand = hand.sorted { $0.rank.value < $1.rank.value }
        
        if isRoyalFlush(sortedHand) { return .royalFlush }
        if isStraightFlush(sortedHand) { return .straightFlush }
        if isFourOfAKind(sortedHand) { return .fourOfAKind }
        if isFullHouse(sortedHand) { return .fullHouse }
        if isFlush(sortedHand) { return .flush }
        if isStraight(sortedHand) { return .straight }
        if isThreeOfAKind(sortedHand) { return .threeOfAKind }
        if isTwoPair(sortedHand) { return .twoPair }
        if isOnePair(sortedHand) { return .onePair }
        
        return .highCard
    }
    
    private func isRoyalFlush(_ hand: [Card]) -> Bool {
        guard isFlush(hand) && isStraight(hand) else { return false }
        let ranks = hand.map { $0.rank.value }.sorted()
        return ranks == [10, 11, 12, 13, 14] // 10, J, Q, K, A
    }
    
    private func isStraightFlush(_ hand: [Card]) -> Bool {
        return isFlush(hand) && isStraight(hand) && !isRoyalFlush(hand)
    }
    
    private func isFourOfAKind(_ hand: [Card]) -> Bool {
        let rankCounts = getRankCounts(hand)
        return rankCounts.values.contains(4)
    }
    
    private func isFullHouse(_ hand: [Card]) -> Bool {
        let rankCounts = getRankCounts(hand)
        return rankCounts.values.contains(3) && rankCounts.values.contains(2)
    }
    
    private func isFlush(_ hand: [Card]) -> Bool {
        let suits = Set(hand.map { $0.suit })
        return suits.count == 1
    }
    
    private func isStraight(_ hand: [Card]) -> Bool {
        let values = hand.map { $0.rank.value }.sorted()
        
        // Check for regular straight
        for i in 0..<values.count - 1 {
            if values[i + 1] - values[i] != 1 {
                // Check for low ace straight (A, 2, 3, 4, 5)
                if values == [2, 3, 4, 5, 14] {
                    return true
                }
                return false
            }
        }
        return true
    }
    
    private func isThreeOfAKind(_ hand: [Card]) -> Bool {
        let rankCounts = getRankCounts(hand)
        return rankCounts.values.contains(3) && !rankCounts.values.contains(2)
    }
    
    private func isTwoPair(_ hand: [Card]) -> Bool {
        let rankCounts = getRankCounts(hand)
        let pairs = rankCounts.values.filter { $0 == 2 }
        return pairs.count == 2
    }
    
    private func isOnePair(_ hand: [Card]) -> Bool {
        let rankCounts = getRankCounts(hand)
        let pairs = rankCounts.values.filter { $0 == 2 }
        return pairs.count == 1
    }
    
    private func getRankCounts(_ hand: [Card]) -> [Rank: Int] {
        var counts: [Rank: Int] = [:]
        for card in hand {
            counts[card.rank, default: 0] += 1
        }
        return counts
    }
}

