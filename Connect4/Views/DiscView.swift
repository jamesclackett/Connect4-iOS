//
//  DiscView.swift
//  Connect4
//
//  Created by James Clackett on 06/12/2023.
//

import UIKit

/// A view to reprsent a Connect4 Disc
/// Has a number (turn) and a color
class DiscView: UIView {
    var color: UIColor = .darkGray
    var number: Int = 0
    
    // Uses Bezier Path to create the disc shape
    override func draw(_ rect: CGRect) {
        var path = UIBezierPath(ovalIn: bounds)
        UIColor.black.setFill()
        path.fill()
        
        let smallerCircleSize = CGSize(width: bounds.width * 0.8, height: bounds.height * 0.8)
        let smallerCircleOrigin = CGPoint(x: bounds.midX - smallerCircleSize.width / 2.0, y: bounds.midY - smallerCircleSize.height / 2.0)
        
        path = UIBezierPath(ovalIn: CGRect(origin: smallerCircleOrigin, size: smallerCircleSize))

        color.setFill()
        path.fill()
        
        let label = UILabel(frame: CGRect(origin: smallerCircleOrigin, size: smallerCircleSize))
        label.text = number.description
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        
        addSubview(label)
    }
   
    /// Init to setup the necessary properties
    init(color: UIColor, number: Int, frame: CGRect) {
        super.init(frame: frame)
        self.color = color
        self.number = number
        layer.cornerRadius = bounds.width / 2.0
        clipsToBounds = true
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
