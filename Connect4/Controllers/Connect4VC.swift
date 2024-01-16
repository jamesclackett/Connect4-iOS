//
//  ViewController.swift
//  Connect4
//
//  Created by Instructor on 29/09/2023.
//

import UIKit
import Alpha0C4
import CoreData


/// View Controller for the Connect4 board
class Connect4VC: UIViewController {
 
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var gameView: GameView!
    
    // setup physics for the board
    private var gravity = UIGravityBehavior()
    private var collider = UICollisionBehavior()
    private var animator: UIDynamicAnimator?
    
    // setup gestures for plays and resets
    var tapGesture = UITapGestureRecognizer()
    var swipeDownGesture = UISwipeGestureRecognizer()
    
    // Alpha0C4 session properties
    private var gameSession = GameSession()
    var botColor: GameSession.DiscColor = Bool.random() ? .red : .yellow
    var isBotFirst = Bool.random()
    
    // For Core Data:
    var gameSave : GameSave?
    let context = (UIApplication.shared.delegate as!
                   AppDelegate).persistentContainer.viewContext
    

    /// Setup the view on load
    /// initialize Dynamic Behaviour (Physics) and gestures
    /// Loads most recent saved game if exists
    override func viewDidLoad() {
        super.viewDidLoad()
        animator = UIDynamicAnimator(referenceView: gameView)
        animator?.addBehavior(gravity)
        collider.translatesReferenceBoundsIntoBoundary = true
        animator?.addBehavior(collider)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapBoard))
        swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeBoard))
        swipeDownGesture.direction = .down
        gameView.addGestureRecognizer(tapGesture)
        gameView.addGestureRecognizer(swipeDownGesture)
        //DataModel.deleteAllGameSaves(context: context) // for debugging: to start afresh if needs be
        loadGameSave()
    }
    
    /// Loads the most recent Game Save object from Core Data persistence
    /// 'icon' is my hacky indicator for whether a game has been won or not
    /// So, if 'won' start a new game via isBotFirst popup
    /// Or if not won (i.e. game in progress), call loadGameSession with the loaded game save
    private func loadGameSave() {
        gameSave = DataModel.getGameSave(context: context)
          
        if let gameSave {
            if gameSave.icon!.isEmpty {
                print("latest game incomplete, continuing game")
                loadGameSession(gameSave: gameSave)
            } else {
                print("latest game complete, starting new game")
                isBotFirstPopup()
            }
        } else {
            print("couldnt find game save, starting new game")
            isBotFirstPopup()
        }
    }
    
    /// An alert  to allow the user to choose whether or not they go first
    ///
    /// NOTE:  i have tried multiple ways of presenting the alert. None seem to confine the alert to Connect4VC and it shows regardless of what view is in focus
    /// This causes a warning. One effort I made was to present it at the navigation controller level but this made no difference
    ///
    /// If the user selects "You", a new game is started whre they take the first turn
    /// If the user selects "𝛂-C4 Bot", a new game is started where  the bot takes the first turn
    func isBotFirstPopup() {
        let alert = UIAlertController(title: "Who Plays First?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "You", style: .default) { _ in
            self.isBotFirst = false
            self.newGameSession()
        })
        alert.addAction(UIAlertAction(title: "𝛂-C4 Bot", style: .default) { _ in
            self.isBotFirst = true
            self.newGameSession()
        })
        present(alert, animated: true, completion: nil)
    }
    
    
    /// Creates a new Game Session using the properties of the given Game Save
    /// Iterates through the game save's 'played positions', loading a new disc for each play (in order)
    /// When all discs have been loaded, it creates the new game session.
    func loadGameSession(gameSave: GameSave) {
        botColor = gameSave.botIsRed ? .red : .yellow
        isBotFirst = gameSave.botIsFirst
        
        // all we need to know is initial color. Then just flip for each played position
        var color = isBotFirst ? botColor : !botColor
        
        let playedPositions = DataModel.decodePositions(data: gameSave.playedPositions!)
        infoLabel.text = "Loading previous game.."
        
        // drop discs to create loaded board
        Task {
            for (index, move) in playedPositions.enumerated() {
                dropDiscView(trayIndex: move.column - 1, color: color, number: index+1)
                color = !color // flip the color
                try await Task.sleep(nanoseconds: 500_000_000)
            }
            try await Task.sleep(nanoseconds: 1_500_000_000)
            gameSession.startGame(delegate: self, botPlays: botColor, first: isBotFirst, initialPositions: playedPositions)
        }
        print("CONNECT4 \(gameSession.boardLayout.rows) rows by \(gameSession.boardLayout.columns) columns")
    }

    /// Responsible for starting a new Game Session
    /// Unlike loadGameSession, this function creates a fresh session with 0 played positions.
    private func newGameSession() {
        botColor = Bool.random() ? .red : .yellow
        gameSave = DataModel.createGameSave(isBotFirst: isBotFirst, botColor: botColor, context: context)
        
        self.gameSession.startGame(delegate: self, botPlays: botColor, first: isBotFirst, initialPositions: [(row: Int, column: Int)]())
        
        print("CONNECT4 \(gameSession.boardLayout.rows) rows by \(gameSession.boardLayout.columns) columns")
    }

    /// Navigation bar refresh button
    @IBAction func refreshButtonTapped(_ sender: Any) {
        restartGame()
    }
    
    /// Handler for game view swipe gesture
    @objc private func swipeBoard(gesture: UISwipeGestureRecognizer) {
        restartGame()
    }
    
   
    /// Handler for game view tap gesture
    /// On tap, it finds the tray/column view which corresponds with the tap location.
    /// Checks if this is a valid play locatiion, if so it drops a disc view on this location
    @objc private func tapBoard(gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: gesture.view)
        
        let subviewList = gesture.view?.subviews ?? []
        
        for (index, subview) in subviewList.enumerated() {
            if subview.frame.contains(tapLocation) {
                if (gameSession.isValidMove(index + 1)) {
                    gameSession.dropDisc(atColumn: index + 1)
                    infoLabel.text = ""
                } else {
                    infoLabel.text = "Invalid Move. Choose another"
                }
                break
            }
        }
    }
    
    /// Restarts the game.
    /// Throws away the current game save
    /// Resets game view and triggers a new game via isBotFirstPopup
    private func restartGame() {
        print("restarting game!")
        if let gameSave { DataModel.deleteGameSave(gameSave: gameSave, context: context) }
        resetBoard()
        infoLabel.text = "Game Restarted"
        isBotFirstPopup()
    }
    
    /// Creates a DiscView with the specified color and number and adds it to the specified game view tray
    func dropDiscView(trayIndex: Int, color: GameSession.DiscColor, number: Int) {
        // get the tray view
        let trayView = gameView.subviews[trayIndex]
        let uiColor: UIColor
        
        switch color {
        case .red:
            uiColor = .red
        case .yellow:
            uiColor = .yellow
        @unknown default:
            uiColor = .black
        }
        
        // Creating the disc view
        let width = trayView.bounds.width
        let discDiameter = width * 0.95
        let discView = DiscView(color: uiColor, number: number, frame: CGRect(x:0 , y: 0, width: discDiameter, height: discDiameter))
        
        // add the disc to tray view
        trayView.addSubview(discView)
        
        // update Dynamic behaviour
        // note: disc view is bound to its parent tray view, not game view.
        // For some reason this fails very easily if discs are added unexpecdedly (ie. discs fall out of tray)
        // When behaviour is as expected, the bounds work fine
        collider.addItem(discView)
        let trayBoundary = UIBezierPath(rect: trayView.bounds)
        collider.addBoundary(withIdentifier: "trayBoundary\(trayIndex)" as NSCopying, for: trayBoundary)
        gravity.addItem(discView)
    }
    
    /// Resets the game view
    /// Removes all discs from the board, deletes them, and updates the dynamic behaviours.
    func resetBoard() {
        collider = UICollisionBehavior()
        collider.translatesReferenceBoundsIntoBoundary = true
        gravity = UIGravityBehavior()
        animator?.removeAllBehaviors()
        animator?.addBehavior(gravity)
        animator?.addBehavior(collider)
        
        for trayView in gameView.subviews[0..<7] {
            for discView in trayView.subviews {
                if discView is DiscView {
                    Task {
                        // wait till they have fallen off the screen and then delete
                        try await Task.sleep(nanoseconds: 2_000_000_000)
                        discView.removeFromSuperview()
                    }
                    gravity.addItem(discView)
                }
            }
        }
    }

}

extension GameView {
    
    /// creates a screenshot image of the view
    /// Used to show the user an image of a game's result in the History table.
    /// - Returns: nil or a UIImage of the current Game View.
    func createImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        layer.render(in: context)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
