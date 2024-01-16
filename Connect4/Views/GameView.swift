//
//  GameView.swift
//  Connect4
//
//  Created by James Clackett on 28/11/2023.
//

import UIKit

/// View to represent the Connect 4 Board.
/// Consists of 7 trays that are used to hold the DiscView.
/// Also consists of 7 column views used purely for UI
/// The disc views liw in between the trays and the column views.
class GameView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createColumnViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createColumnViews()
    }
    
    // create 7 trays and then 7 column views
    func createColumnViews() {
        let width = bounds.width / 7
        
        // create 7 trays to provide disc boundaries
        // the trays are simply a blank uiview that will act as a collision boundary
        for i in 0..<7 {
            let tray = UIView(
                frame: CGRect(
                    x: CGFloat(i) * width,
                    y: 0,
                    width: width,
                    height: bounds.height))
            addSubview(tray)
        }
        
        // create 7 ui columns
        for i in 0..<7 {
            
            let columnView = ColumnView(
                frame: CGRect(
                    x: CGFloat(i) * width,
                    y: bounds.height * 0.2,
                    width: width,
                    height: bounds.height * 0.8))
            addSubview(columnView)
        }
    }
}
