//
//  ReplayVC.swift
//  Connect4
//
//  Created by James Clackett on 08/12/2023.
//

import UIKit
import Alpha0C4

/// ReplayVC is using to control the ReplayView. Replay View is identical to a GameView to reduce code duplication.
/// ReplayVC overrides a number of functions rom Connect4VC to carry out a very similar purpose
/// The difference: Game State is not created/used. A Game View is populated with discs using overriden functions like dropDiscView.
/// There is still significant duplication here, but it was a very quick and simple solution when under pressure for time.
class ReplayVC: Connect4VC {
    
    @IBOutlet weak var replayButton: UIBarButtonItem!
    @IBOutlet weak var replayLabel: UILabel!
    @IBOutlet weak var replayView: GameView!
    private var gravity = UIGravityBehavior()
    private var collider = UICollisionBehavior()
    private var animator: UIDynamicAnimator?
    var historySave: GameSave?

   
    override func viewDidLoad() {
        print("replay did load")
        print(historySave?.botIsFirst ?? "error")
        
        animator = UIDynamicAnimator(referenceView: replayView)
        animator?.addBehavior(gravity)
        collider.translatesReferenceBoundsIntoBoundary = true
        animator?.addBehavior(collider)
        
        loadGameSession(gameSave: historySave!)
    }
    
    /// Overriden from Connect4VC.
    /// References to Game Session are removed, startGame is never called
    /// Outlets modified to reflect this VC
    /// Sleep times changed to reflect a game replay as opposed to a game load.
    override func loadGameSession(gameSave: GameSave) {
        let botColor: GameSession.DiscColor = gameSave.botIsRed ? .red : .yellow
        let isBotFirst = gameSave.botIsFirst
        
        // all we need to know is initial color. Then just flip for each played position
        var color = isBotFirst ? botColor : !botColor
        
        let playedPositions = DataModel.decodePositions(data: gameSave.playedPositions!)
        replayLabel.text = "\(gameSave.botIsWinner ? "Bot (\(botColor)) Won" : "User (\(!botColor)) Won")"
        
        // drop discs to create loaded board
        Task {
            replayButton.isEnabled = false
            for (index, move) in playedPositions.enumerated() {
                dropDiscView(trayIndex: move.column - 1, color: color, number: index+1)
                color = !color // flip the color
                try await Task.sleep(nanoseconds: 650_000_000)
            }
            replayButton.isEnabled = true
        }
    }
    
    /// Overriden from Connect4VC.
    /// Outlets modified to reflect this VC
    override func dropDiscView(trayIndex: Int, color: GameSession.DiscColor, number: Int) {
        let trayView = replayView.subviews[trayIndex]
        let uiColor: UIColor
        
        switch color {
        case .red:
            uiColor = .red
        case .yellow:
            uiColor = .yellow
        @unknown default:
            uiColor = .black
        }
        
        let width = trayView.bounds.width
        let discDiameter = width * 0.95
        let discView = DiscView(color: uiColor, number: number, frame: CGRect(x:0 , y: 0, width: discDiameter, height: discDiameter))
        
        trayView.addSubview(discView)
        collider.addItem(discView)
        let trayBoundary = UIBezierPath(rect: trayView.bounds)
        collider.addBoundary(withIdentifier: "trayBoundary\(trayIndex)" as NSCopying, for: trayBoundary)
        
        gravity.addItem(discView)
    }
    
    /// overriden so as to use this VCs dynamic behaviour and not Connect4VC
    override func resetBoard() {
        collider = UICollisionBehavior()
        collider.translatesReferenceBoundsIntoBoundary = true
        gravity = UIGravityBehavior()
        animator?.removeAllBehaviors()
        animator?.addBehavior(gravity)
        animator?.addBehavior(collider)
        
        for trayView in replayView.subviews[0..<7] {
            for discView in trayView.subviews {
                if discView is DiscView {
                    Task {
                        // wait till theyve fallen off the screen and delete
                        try await Task.sleep(nanoseconds: 2_000_000_000)
                        discView.removeFromSuperview()
                    }
                    gravity.addItem(discView)
                }
            }
        }
    }

    /// For Navigation bar replay button
    /// Resets the board, waits for 3 seconds, then calls loadGameSession again.
    @IBAction func replayButtonPressed(_ sender: Any) {
        Task {
            resetBoard()
            try await Task.sleep(nanoseconds: 3_000_000_000)
            loadGameSession(gameSave: historySave!)
        }
    }
}
