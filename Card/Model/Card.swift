//
//  Card.swift
//  Card
//
//  Created by Айдар Абдуллин on 30.11.2022.
//

import UIKit

enum CardType: CaseIterable {
    case circle
    case cross
    case square
    case fill
    case donut
}

enum CardColor: CaseIterable {
    case red
    case green
    case black
    case gray
    case brown
    case yellow
    case purple
    case orange
}

typealias Card = (type: CardType, color: CardColor)
