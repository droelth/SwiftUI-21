//
//  SingleCardView.swift
//  21Blackjack
//
//  Created by Berkay Sutlu on 10.09.2023.
//

import SwiftUI

struct SingleCardView: View {
    @State var card : Card
    var body: some View {
        
            VStack{
                
                //Text("\(card.worth)").font(.title).fontWeight(.bold).padding(30)
                Image("\(card.suit)").resizable().frame(width: 25,height: 25)
                Text("\(card.value)").font(.title).fontWeight(.bold)
                
            }.padding(10).background(Rectangle().frame(width: 50, height: 100).foregroundColor(.gray.opacity(0.2)).cornerRadius(4).shadow(radius: 2))
            
        
    }
}


struct ClosedCardView: View {
    var body: some View {
        VStack{
            Circle().frame(width: 20).foregroundColor(.blue)
        }.padding(10).background(Rectangle().frame(width: 50, height: 100).foregroundColor(.red.opacity(0.5)).cornerRadius(4).shadow(radius: 2))
    }
}
