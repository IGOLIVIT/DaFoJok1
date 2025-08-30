//
//  Card.swift
//  DaFoJok1
//
//  Created by IGOR on 29/08/2025.
//

import Foundation

// MARK: - Suit Enum
enum Suit: String, CaseIterable, Hashable {
    case hearts = "♥"
    case diamonds = "♦"
    case clubs = "♣"
    case spades = "♠"
    
    var color: CardColor {
        switch self {
        case .hearts, .diamonds:
            return .red
        case .clubs, .spades:
            return .black
        }
    }
}

// MARK: - Rank Enum
enum Rank: String, CaseIterable, Hashable, Comparable {
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "10"
    case jack = "J"
    case queen = "Q"
    case king = "K"
    case ace = "A"
    
    var value: Int {
        switch self {
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        case .seven: return 7
        case .eight: return 8
        case .nine: return 9
        case .ten: return 10
        case .jack: return 11
        case .queen: return 12
        case .king: return 13
        case .ace: return 14
        }
    }
    
    static func < (lhs: Rank, rhs: Rank) -> Bool {
        return lhs.value < rhs.value
    }
}

// MARK: - Card Color
enum CardColor {
    case red
    case black
}

// MARK: - Card Model
struct Card: Identifiable, Hashable, Equatable {
    let id = UUID()
    let suit: Suit
    let rank: Rank
    
    var displayName: String {
        return "\(rank.rawValue)\(suit.rawValue)"
    }
    
    var color: CardColor {
        return suit.color
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.suit == rhs.suit && lhs.rank == rhs.rank
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(suit)
        hasher.combine(rank)
    }
}

// MARK: - Poker Hand Types
enum PokerHandType: String, CaseIterable {
    case royalFlush = "Royal Flush"
    case straightFlush = "Straight Flush"
    case fourOfAKind = "Four of a Kind"
    case fullHouse = "Full House"
    case flush = "Flush"
    case straight = "Straight"
    case threeOfAKind = "Three of a Kind"
    case twoPair = "Two Pair"
    case onePair = "One Pair"
    case highCard = "High Card"
    
    var description: String {
        switch self {
        case .royalFlush:
            return "A, K, Q, J, 10 all of the same suit"
        case .straightFlush:
            return "Five cards in sequence, all of the same suit"
        case .fourOfAKind:
            return "Four cards of the same rank"
        case .fullHouse:
            return "Three of a kind plus a pair"
        case .flush:
            return "Five cards of the same suit, not in sequence"
        case .straight:
            return "Five cards in sequence, mixed suits"
        case .threeOfAKind:
            return "Three cards of the same rank"
        case .twoPair:
            return "Two different pairs"
        case .onePair:
            return "Two cards of the same rank"
        case .highCard:
            return "No matching cards, highest card wins"
        }
    }
    
    var value: Int {
        switch self {
        case .royalFlush: return 10
        case .straightFlush: return 9
        case .fourOfAKind: return 8
        case .fullHouse: return 7
        case .flush: return 6
        case .straight: return 5
        case .threeOfAKind: return 4
        case .twoPair: return 3
        case .onePair: return 2
        case .highCard: return 1
        }
    }
}

