//
//  ViewController.swift
//  Card
//
//  Created by Айдар Абдуллин on 25.11.2022.
//

import UIKit

class BoardGameController: UIViewController {
    
    var cardsPairsCount = 8
    var cardViews = [UIView]()
    
    lazy var game: Game = getNewGame()
    lazy var startButtonView = getStartButtonView()
    lazy var flipAllCardsButtonView = getFlipAllCardsButton()
    lazy var boardGameView = getBoardGameView()
    
    private var flippedCards: [UIView] = []
    private let margin: CGFloat = 10
    
    private var cardSize: CGSize {
        CGSize(width: 80, height: 120)
    }
    private var cardMaxXCoordinate: Int {
        Int(boardGameView.frame.width - cardSize.width)
    }
    private var cardMaxYCoordinate: Int {
        Int(boardGameView.frame.height - cardSize.height)
    }

    override func loadView() {
        super.loadView()
        
        view.addSubview(startButtonView)
        view.addSubview(boardGameView)
        view.addSubview(flipAllCardsButtonView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    private func getNewGame() -> Game {
        let game = Game()
        game.cardsCount = self.cardsPairsCount
        game.generateCards()
        return game
    }
    
    private func getFlipAllCardsButton() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        if let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let window = UIWindow(windowScene: firstScene)
            let topPadding = window.safeAreaInsets.top
            button.frame.origin.y = topPadding
            button.frame.origin.x = margin
            button.frame.size.width = UIScreen.main.bounds.width / 2 - margin * 2 - startButtonView.frame.size.width / 2
        }
        
        button.setTitle("Flip", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.backgroundColor = .systemGray4
        button.layer.cornerRadius = 10
        
        return button
    }

    private func getStartButtonView() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        button.center.x = view.center.x
        
        if let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let window = UIWindow(windowScene: firstScene)
            let topPadding = window.safeAreaInsets.top
            button.frame.origin.y = topPadding
        }
        
        button.setTitle("Start game", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.backgroundColor = .systemGray4
        button.layer.cornerRadius = 10
        button.addTarget(nil, action: #selector(startGame(_:)), for: .touchUpInside)
        
        return button
    }
    
    private func getBoardGameView() -> UIView {
        let boardView = UIView()
        
        boardView.frame.origin.x = margin
        
        if let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let window = UIWindow(windowScene: firstScene)
            let topPadding = window.safeAreaInsets.top
            let bottomPadding = window.safeAreaInsets.bottom
            boardView.frame.origin.y = topPadding + startButtonView.frame.height + margin
            boardView.frame.size.height = UIScreen.main.bounds.height - boardView.frame.origin.y - margin - bottomPadding
        }
        
        boardView.frame.size.width = UIScreen.main.bounds.width - margin * 2
        boardView.layer.cornerRadius = 5
        boardView.backgroundColor = UIColor(red: 0.1, green: 0.9, blue: 0.1, alpha: 0.3)
        
        return boardView
    }
    
    private func getCardsBy(modelData: [Card]) -> [UIView] {
        var cardViews: [UIView] = []
        let cardViewFactory = CardViewFactory()
        
        for (index, modelCard) in modelData.enumerated() {
            let cardOne = cardViewFactory.get(modelCard.type, withSize: cardSize, andColor: modelCard.color)
            cardOne.tag = index
            cardViews.append(cardOne)
            
            let cardTwo = cardViewFactory.get(modelCard.type, withSize: cardSize, andColor: modelCard.color)
            cardTwo.tag = index
            cardViews.append(cardTwo)
        }
        
        for card in cardViews {
            (card as! FlippableView).flipComplitionHandler = { [self] flippedCard in
                flippedCard.superview?.bringSubviewToFront(flippedCard)
                
                if flippedCard.isFlipped {
                    self.flippedCards.append(flippedCard)
                } else {
                    if let cardIndex = self.flippedCards.firstIndex(of: flippedCard) {
                        self.flippedCards.remove(at: cardIndex)
                    }
                }
                
                if self.flippedCards.count == 2 {
                    let firstCard = game.cards[self.flippedCards.first!.tag]
                    let secondCard = game.cards[self.flippedCards.last!.tag]
                    
                    if game.checkCards(firstCard, secondCard) {
                        UIView.animate(withDuration: 0.3, animations: {
                            self.flippedCards.first?.layer.opacity = 0
                            self.flippedCards.last?.layer.opacity = 0
                        }, completion:  { _ in
                            self.flippedCards.first?.removeFromSuperview()
                            self.flippedCards.last?.removeFromSuperview()
                            self.flippedCards = []
                        })
                    } else {
                        for card in self.flippedCards {
                            (card as! FlippableView).flip()
                        }
                    }
                }
            }
        }
        
        return cardViews
    }
    
    private func placeCardsOnBoard(_ cards: [UIView]) {
        for card in cardViews {
            card.removeFromSuperview()
        }
        
        cardViews = cards
        
        for card in cardViews {
            let randomXCoordinate = Int.random(in: 0...cardMaxXCoordinate)
            let randomYCoordinate = Int.random(in: 0...cardMaxYCoordinate)
            card.frame.origin = CGPoint(x: randomXCoordinate, y: randomYCoordinate)
            boardGameView.addSubview(card)
        }
    }
    
    @objc func startGame(_ sender: UIButton) {
        game = getNewGame()
        let cards = getCardsBy(modelData: game.cards)
        placeCardsOnBoard(cards)
    }
}

