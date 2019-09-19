//
//  PlayingCardView.swift
//  Sdemo1
//
//  Created by David on 2019-08-11.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit

@IBDesignable
class PlayingCardView: UIView {
    
    @IBInspectable var rank: Int = 12 { didSet { setNeedsDisplay(); setNeedsLayout()}}
    @IBInspectable var suit: String = "♥️" { didSet { setNeedsDisplay(); setNeedsLayout()}}
    @IBInspectable var isFaceUp: Bool = true { didSet { setNeedsDisplay(); setNeedsLayout()}}
    
    var faceCardScale: CGFloat = SizeRatio.faceCardImageSizeToBoundsSize { didSet { setNeedsDisplay(); setNeedsLayout()}}
    
    private lazy var upperLeftCornerLabel = createLabel()
    private lazy var lowerRightCornerLabel = createLabel()
    
    private func createLabel()-> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    private var cornerString: NSAttributedString {
        return centeredAttributedString(rankString+"\n"+suit, fontSize: cornerFontSize)
    }
    
    private func configureCornerLabel(_ label: UILabel){
        label.attributedText = cornerString
        label.frame.size = CGSize.zero
        label.sizeToFit()
        label.isHidden = !isFaceUp
    }
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        
        let parragraphStyle = NSMutableParagraphStyle()
        parragraphStyle.alignment = .center
        
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.paragraphStyle:parragraphStyle, .font:font])
    }
    
    @objc func adjustFaceCardScale(by gesture: UIPinchGestureRecognizer){
        
        switch gesture.state {
        case .changed, .ended:
            faceCardScale *= gesture.scale
            gesture.scale = 1.0
        default:
            break
        }
    }
    
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
        
        if isFaceUp {
            if let faceCardImage = UIImage(named: rankString+suit, in: Bundle(for: self.classForCoder), compatibleWith: traitCollection){
                faceCardImage.draw(in: bounds.zoom(by: faceCardScale))
            } else {
                drawPips()
            }
        } else {
            if let cardsBackImage = UIImage(named: "cardback"){
                cardsBackImage.draw(in: bounds)
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureCornerLabel(upperLeftCornerLabel)
        configureCornerLabel(lowerRightCornerLabel)
        
        upperLeftCornerLabel.frame.origin = bounds.origin.offSetBy(dx: cornerOffSet, dy: cornerOffSet)
        lowerRightCornerLabel.transform = CGAffineTransform.identity.translatedBy(x: lowerRightCornerLabel.frame.size.width, y: lowerRightCornerLabel.frame.size.height).rotated(by: CGFloat.pi)
        lowerRightCornerLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY).offSetBy(dx: -cornerOffSet, dy: -cornerOffSet).offSetBy(dx: -lowerRightCornerLabel.frame.size.width, dy: -lowerRightCornerLabel.frame.size.height)
        
    }
    
    private func drawPips(){
        let pipsPerRowForRank = [[0], [1], [1,1], [1,1,1], [2,2], [2,1,2], [2,2,2], [2,1,2,2], [2,2,2,2], [2,2,1,2,2], [2,2,2,2,2]]
        
        func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.count, $0)})
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) {max($1.max() ?? 0, $0)})
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
            
            let probablyOkayStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            
            let probalblyOkayPipString = centeredAttributedString(suit, fontSize: probablyOkayStringFontSize)
            
            if probalblyOkayPipString.size().width > pipRect.size.width / maxVerticalPipCount {
                return centeredAttributedString(suit, fontSize: probablyOkayStringFontSize / (probalblyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
            } else {
                return probalblyOkayPipString
            }
        }
        
        if pipsPerRowForRank.indices.contains(rank) {
            let pipsPerRow = pipsPerRowForRank[rank]
            var pipRect = bounds.insetBy(dx: cornerOffSet, dy: cornerOffSet).insetBy(dx: cornerString.size().width, dy: cornerString.size().height / 2)
            let pipString = createPipString(thatFits: pipRect)
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipString.size().height
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            for pipCount in pipsPerRow {
                switch pipCount {
                case 1 :
                    pipString.draw(in: pipRect)
                case 2:
                    pipString.draw(in: pipRect.leftHalf)
                    pipString.draw(in: pipRect.rightHalf)
                default:
                    break
                }
                pipRect.origin.y += pipRowSpacing
            }
            
            
        }
    }

}

extension PlayingCardView {
    private struct SizeRatio {
        static let cornerFontSizeToBoundHeight: CGFloat = 0.085
        static let cornerRadiusToBoundHeight: CGFloat = 0.06
        static let cornerOffSetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundsSize: CGFloat = 0.75
    }
    
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundHeight
    }
    
    private var cornerOffSet: CGFloat {
        return cornerRadius * SizeRatio.cornerOffSetToCornerRadius
    }
    
    private var cornerFontSize: CGFloat {
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundHeight
    }
    
    private var rankString: String {
        switch rank {
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
    
}

extension CGRect {
    var leftHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    
    var rightHalf: CGRect {
        return CGRect(x: midX, y: minY, width: width/2, height: height)
    }
    
    func inset(by size: CGSize)-> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    
    func sized(to size: CGSize)-> CGRect {
        return CGRect(origin: origin, size: size)
    }
    
    func zoom(by scale: CGFloat)-> CGRect{
        let newWidth = width * scale
        let newHeight = height * scale
        
        return insetBy(dx: (width - newWidth) / 2, dy: (height / newHeight) / 2)
    }
}

extension CGPoint {
    func offSetBy(dx: CGFloat, dy: CGFloat)-> CGPoint {
        return CGPoint(x: x + dx , y: y + dy )
    }
}
