//
//  ViewController.swift
//  Sdemo1
//
//  Created by David on 2019-08-03.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
     
     
     private var deck = PlayingCardDeck()
     
     @IBOutlet var cardViews: [PlayingCardView]!
     
     lazy var animator = UIDynamicAnimator(referenceView: view)
     
     lazy var cardBehavior = CardBehavior(in: animator)
     
     
     private var faceUpCardViews: [PlayingCardView] {
          return cardViews.filter {$0.isFaceUp && !$0.isHidden && $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0) && $0.alpha == 1}
     }
     
     private var faceUpCardsMatch: Bool {
          return faceUpCardViews.count == 2 &&
               faceUpCardViews[0].rank == faceUpCardViews[1].rank &&
               faceUpCardViews[0].suit == faceUpCardViews[1].suit
     }
     
     private var lastChoosenCardView: PlayingCardView?
     
    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
          
          switch recognizer.state {
          case .ended:
               if let chosenCardView = recognizer.view as? PlayingCardView, faceUpCardViews.count < 2 {
                    
                    lastChoosenCardView = chosenCardView
                    
                    //cardBehavior.removeBehaviorFromItem(chosenCardView)
                    
                    UIView.transition(with: chosenCardView,
                                      duration: 0.7,
                                      options: [.transitionFlipFromLeft] ,
                                      animations: {
                                        chosenCardView.isFaceUp = !chosenCardView.isFaceUp
                    }, completion: { finished in
                         let cardsToAnimate = self.faceUpCardViews
                         
                         if self.faceUpCardsMatch {
                              UIViewPropertyAnimator.runningPropertyAnimator(
                                   withDuration: 0.7,
                                   delay: 0,
                                   options: [],
                                   animations: {
                                        cardsToAnimate.forEach {
                                             $0.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
                                        }
                              },
                                   completion: { position in
                                        UIViewPropertyAnimator.runningPropertyAnimator(
                                             withDuration: 0.8,
                                             delay: 0,
                                             options: [],
                                             animations: {
                                                  cardsToAnimate.forEach {
                                                       $0.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                                                       $0.alpha = 0
                                                  }
                                        },
                                             completion: { position in
                                                  cardsToAnimate.forEach {
                                                       $0.isHidden = true
                                                       
//                                                       $0.alpha = 1
//                                                       $0.transform = .identity
                                                  }
                                        }
                                        )
                              }
                              )
                         } else if cardsToAnimate.count == 2 {
                              if chosenCardView == self.lastChoosenCardView {
                                   cardsToAnimate.forEach { cardView in
                                        UIView.transition(with: cardView, duration: 0.6, options: [.transitionFlipFromBottom], animations: {
                                             cardView.isFaceUp = false
                                        }, completion: {finished in
                                             self.cardBehavior.addItem(cardView)
                                        }
                                        )
                                   }
                              }
                         } else {
                              if !chosenCardView.isFaceUp {
                                   self.cardBehavior.addItem(chosenCardView)
                              }
                         }
                    }
                    )
               }
          default:
               break
          }
     }
     
     override func viewDidLoad() {
          super.viewDidLoad()
          var cards = [PlayingCard]()
          
          for _ in 1...((cardViews.count + 1)/2 ) {
               let card = deck.draw()!
               cards += [card, card]
          }
          
          for cardView in cardViews {
               cardView.isFaceUp = false
               let card = cards.remove(at: cards.count.arc4random)
               cardView.rank = card.rank.order
               cardView.suit = card.suit.rawValue
               cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
               cardBehavior.addItem(cardView)
          }
     }
}



