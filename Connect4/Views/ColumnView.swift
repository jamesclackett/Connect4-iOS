//
//  ColumnView.swift
//  Connect4
//
//  Created by James Clackett on 06/12/2023.
//

import UIKit

/// A View to represent a single column in the Game View
/// In summary, they are simply a rectangle view designed to look like a Connect4 column (blue, clear holes etc.)
/// They serve no purpose other than this. In fact, the game would still work without them.
class ColumnView: UIView {
    
    override func draw(_ rect: CGRect) {
        
        let column = UIBezierPath(rect: bounds)
        UIColor(red: 0.1, green: 0.4, blue: 0.8, alpha: 1).setFill()
        column.fill()
        UIColor.black.setStroke()
        column.lineWidth = 5
        column.stroke()
        
        let holeDiameter = bounds.width * 0.60
        let segmentHeight = bounds.height / 6
        
        for i in 0..<6 {
            let hole = UIBezierPath(
                ovalIn:
                    CGRect(
                        x: bounds.midX - (holeDiameter / 2),
                        y: ((segmentHeight) * CGFloat(i)) + ((segmentHeight / 2) - (holeDiameter / 2)),
                        width: holeDiameter,
                        height: holeDiameter
                )
            )
            column.append(hole)
            
            UIColor.black.setStroke()
            hole.lineWidth = 5
            hole.stroke()
        }
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = column.cgPath
        maskLayer.fillRule = .evenOdd
        self.layer.mask = maskLayer
    }
}

