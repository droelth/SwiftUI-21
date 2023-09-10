//
//  Deck.swift
//  21Blackjack
//
//  Created by Berkay Sutlu on 10.09.2023.
//

import Foundation

struct Deck: Identifiable {
    var id = UUID()
    var name: String
    var cards: [Card]
}
