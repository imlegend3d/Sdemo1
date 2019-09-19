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
//        {
//        didSet{
//            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
//            swipe.direction = [.left, .right]
//            cardViews.addGestureRecognizer(swipe)
//
//          let pinch = UIPinchGestureRecognizer(target: playingCardView, action: #selector(PlayingCardView.adjustFaceCardScale(by:)))
//
//          cardViews.addGestureRecognizer(pinch)
//        }
//    }
     private var faceUpCardViews: [PlayingCardView] {
          return cardViews.filter {$0.isFaceUp && !$0.isHidden}
     }
     
     private var faceUpCardsMatch: Bool {
          return faceUpCardViews.count == 2 &&
               faceUpCardViews[0].rank == faceUpCardViews[1].rank &&
               faceUpCardViews[0].suit == faceUpCardViews[1].suit
     }
    
     @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
          
          switch sender.state {
          case .ended:
               if let tappedCard = sender.view as? PlayingCardView {
                    UIView.transition(with: tappedCard, duration: 0.7, options: [.transitionFlipFromLeft] , animations: {
                         tappedCard.isFaceUp = !tappedCard.isFaceUp
                    }, completion: { finished in
                         if self.faceUpCardsMatch {
                              UIViewPropertyAnimator.runningPropertyAnimator(
                                   withDuration: 0.7,
                                   delay: 0,
                                   options: [],
                                   animations: {
                                        self.faceUpCardViews.forEach {
                                             $0.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
                                        }
                              },
                                   completion: { position in
                                        UIViewPropertyAnimator.runningPropertyAnimator(
                                             withDuration: 0.9,
                                             delay: 0,
                                             options: [],
                                             animations: {
                                                  self.faceUpCardViews.forEach {
                                                       $0.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                                                       $0.alpha = 0
                                                  }
                                        },
                                             completion: { position in
                                                  self.faceUpCardViews.forEach {
                                                       $0.isHidden = true
                                                       $0.alpha = 1
                                                       $0.transform = .identity
                                                  }
                                        }
                                             )
                              }
                              )
                              
                         } else {
                              if self.faceUpCardViews.count == 2 {
                                   self.faceUpCardViews.forEach { cardView in
                                        UIView.transition(with: cardView, duration: 0.6, options: [.transitionFlipFromBottom], animations: {
                                             cardView.isFaceUp = false
                                        })
                                   }
                              }
                         }
                    })
               }
               
          default:
               break
          }
     }
    
//    @objc private func nextCard(){
//        if let card = deck.draw() {
//            cardViews.rank = card.rank.order
//            cardViews.suit = card.suit.rawValue
//        }
//    }
    
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
          }
          
          
     }

}

