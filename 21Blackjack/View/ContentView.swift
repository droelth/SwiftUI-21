//
//  ContentView.swift
//  21Blackjack
//
//  Created by Berkay Sutlu on 10.09.2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var deckVM = deckViewModel()
    @State var standardDeck: Deck = Deck(name: "", cards: [])
    
    @State var playerHand: [Card] = []
    @State var opponentHand: [Card] = []
    
    @State var opponentScore: Int = 0
    @State var playerScore: Int = 0
    
    
    @State var playerWon = false
    @State var opponentWon = false
    
    @State private var currentTurn: Turn = .player
    @State var gameOver = false
    @State var gameStatus = ""
    
    @State var playerMoney = 100
    @State var bettingMoney = "0"
    
    
    enum Turn {
        case player
        case opponent
    }
    
    var body: some View {
        VStack {
            // OPPONENT HAND AREA
            VStack{
                Text("Current Score : \(opponentScore)").opacity(currentTurn == .opponent ? 1 : 0)
                
                
                HStack {
                    ForEach(opponentHand.indices, id: \.self) { index in
                                   if index == 0 {
                                       // You can display a placeholder or hide the first card as needed
                                       if currentTurn == .player {
                                           ClosedCardView()
                                       } else if currentTurn == .opponent {
                                           SingleCardView(card: opponentHand[index])
                                       }
                                       
                                   } else {
                                       SingleCardView(card: opponentHand[index])
                                   }
                               }
                }
            }.frame(width: UIScreen.main.bounds.width, height: 250).background(.green)
            
            Spacer()
            
            Divider()
            Button {
                refreshEverything()
            } label: {
                Text("Begin Again!").foregroundColor(.white).padding(10).background(.blue).cornerRadius(50).opacity(playerWon || opponentWon ? 1 : 0)
            }
            ZStack{
                Text(playerWon == true ? "Player Won!" : "")
                Text(opponentWon == true ? "Opponent Won!" : "")
            }
            Divider()
            
            // BUTTONS
            HStack {
                Button { // Draw CARD
                    let cardDrawn = deckVM.drawCard(from: &standardDeck)
                    playerHand.append(cardDrawn!)
                    playerScore = calculateScore(playerHand)
                } label: {
                    Text("Draw Card").font(.title).foregroundColor(.white).padding(10).frame(width: 175).background( playerWon || currentTurn == .opponent ? .gray : .blue).cornerRadius(50)
                }.disabled( playerWon || opponentWon || currentTurn == .opponent)
                
                Button {
                    switchTurn() // End Player's turn
                    
                    // PLAYER TURN IS OVER AND OPPONENT AI START WORKING
                    opponentTurn(playerScore: playerScore, oppScore: &opponentScore, opponentHand: &opponentHand, deckVM: deckVM)
                    
                } label: {
                    Text("Stay").font(.title).foregroundColor(.white).padding(10).frame(width: 175).background( playerWon || currentTurn == .opponent ? .gray : .blue).cornerRadius(50)
                }.disabled(playerWon || opponentWon || currentTurn == .opponent)
                
            }
            
            
            Spacer()
            
            // PLAYER HAND AREA
            VStack {
                Text("Current Score : \(playerScore)").foregroundColor(opponentWon ? .red : .black).foregroundColor(playerWon ? .yellow : .black)
                HStack {
                    ForEach(playerHand) { card in
                        SingleCardView(card: card)
                    }
                }
            }.frame(width: UIScreen.main.bounds.width, height: 250).background(.green)
        }.onAppear{
            standardDeck = deckVM.createDeck() // CREATING NEW DECK
            initialCardDraw() // CARD DRAW INITIALLY
        }.padding()
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
// FUNCTIONS
extension ContentView {
    func if21reached() {
        if playerScore == 21 {
            playerWon = true
        }
        else if opponentScore == 21 {
            opponentWon = true
        }
    }
    func initialCardDraw() {
        for _ in 0..<2 {
            playerHand.append(deckVM.drawCard(from: &standardDeck)!)
        }
        for _ in 0..<2 {
            opponentHand.append(deckVM.drawCard(from: &standardDeck)!)
        }
        
        opponentScore = calculateScore(opponentHand) // calculate the score for opponent
        playerScore = calculateScore(playerHand) // calculate the score for player
        
        print("PLAYER HAND : \(playerHand)")
        print("OPPONENT HAND : \(opponentHand)")
        
        if21reached()
    }
    func calculateScore(_ hand: [Card]) -> Int {
        var score = 0
        var containsA = false  // Initialize the flag for Ace presence
        
        for card in hand {
            score += card.worth
            if card.value == "A" {  // Check if the card is an Ace (A)
                containsA = true   // Set the flag if Ace is found
            }
        }
        if score > 21 && containsA {
            // If the score is over 21 and an Ace is present, subtract 10 to account for the Ace being worth 1
            score -= 10
        }
        if currentTurn == .player {
            if score > 21 {
                opponentWon = true
            }
            if score == 21 || (hand.count == 5 && score <= 21) {
                playerWon = true
            }
        } else if currentTurn == .opponent {
            if score > 21 {
                playerWon = true
            }
            if score == 21 || (hand.count == 5 && score <= 21) {
                opponentWon = true
            }
        }
        
        
        return score
    }
    func switchTurn() {
        currentTurn = (currentTurn == .player) ? .opponent : .player
    }
    func opponentTurn(playerScore: Int, oppScore: inout Int, opponentHand: inout [Card], deckVM: deckViewModel) {
        // Check if opponent has already won or lost
        if oppScore > playerScore {
            opponentWon = true
        }
        
        if opponentWon {
            return
        }
        // Keep drawing as long as the opponent is losing or has fewer than 5 cards
        while oppScore <= playerScore && (opponentHand.count < 5 && oppScore <= 21) {
            if let drawnCard = deckVM.drawCard(from: &standardDeck) {
                opponentHand.append(drawnCard)
                
                // Recalculate the opponent's score
                oppScore = calculateScore(opponentHand)
                print("Opponent's Score: \(oppScore)")
                
                // Check if the opponent has busted (score over 21)
                if oppScore > 21 {
                    playerWon = true
                    break
                }
                // MARK !!!! ADD DELAY 1 SECOND HERE
                
            }
        }
    } // opponent AI
    func refreshEverything(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            playerHand = []
            opponentHand = []
            
            opponentScore = 0
            playerScore = 0
            
            playerWon = false
            opponentWon = false
            
            currentTurn = .player
            
            initialCardDraw()
            gameOver = false
        }
    }
    
}
