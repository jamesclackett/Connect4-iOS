import Alpha0C4
import UIKit


/// An extension for Connect4VC.
/// Sets up the VC as a delegate for Alpha0C4s game session.
/// Much of this code was contained in the sample project.
extension Connect4VC: GameSessionDelegate {
    
    // GameSessionDelegate update for game state changes (I have made very little changes here)
    func stateChanged(_ gameSession: GameSession, state: SessionState, textLog: String) {
        // Handle state transition
        switch state {
        // Inital state
        case .cleared:
            print("game cleared")
        // Player evaluating position to play
        case .busy(_):
            tapGesture.isEnabled = false
            
        // Waiting for play action
        case .idle(let color):
            let isUserTurn = (color != botColor)
            infoLabel.text = isUserTurn ? "Your turn (\(!botColor))" : "Bot's turn (\(botColor))"
            tapGesture.isEnabled = isUserTurn
            if !isUserTurn {
                Task {
                    try await Task.sleep(nanoseconds: 3_000_000_000)
                    gameSession.dropDisc()
                }
            }
            
        // End of game, update UI with game result, start new game
        case .ended(let outcome):
            tapGesture.isEnabled = false
            
            // Display game result
            var gameResult: String
            switch outcome {
            case botColor:
                gameResult = "Bot (\(botColor)) wins!"
                gameSave?.botIsWinner = true
            case !botColor:
                gameResult = "User (\(!botColor)) wins!"
            default:
                gameResult = "Draw!"
            }
            
            infoLabel.text = gameResult
            
            Task {
                try await Task.sleep(nanoseconds: 9_000_000_000)
                await MainActor.run {
                    infoLabel.text = ""
                    isBotFirstPopup()
                }
            }
        @unknown default:
            break
        }
    }
    
    
    /// GameSessionDelegate notifying of the result of a player action
    /// When a disc is dropped, call dropDiscView at the dropped location
    /// Then, update the game save in Core Data.
    func didDropDisc(_ gameSession: GameSession, color: DiscColor, at location: (row: Int, column: Int), index: Int, textLog: String) {
        print("\(color) drops at \(location)")
        
        dropDiscView(trayIndex: location.column - 1, color: color, number: index)
        
        if let gameSave {
            gameSave.playedPositions = DataModel.encodePositions(positions: gameSession.playerPositions)
            DataModel.updateGameSave(gameSave: gameSave, context: context)
            
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }

        
    /// GameSessionDelegate notification of end of game
    /// When a game has ended, highlight the winning play
    /// Update the save game in core data with the winning image
    /// Tell table view in HistoryVC to reload using NotificationCenter.
    func didEnd(_ gameSession: GameSession, color: DiscColor?, winningActions: [(row: Int, column: Int)]) {
        
        print("Winning actions: " + winningActions.map({"\($0)"}).joined(separator: " "))
        
        for trayView in gameView.subviews {
            for discView in trayView.subviews {
                discView.alpha = 0.2
            }
        }
        
        for loc in winningActions {
            let trayView = gameView.subviews[loc.column - 1]
            let discView = trayView.subviews[loc.row - 1]
            discView.alpha = 1
        }
        
        if let gameSave {
            Task {
                try await Task.sleep(nanoseconds: 3_000_000_000)
                gameSave.icon = gameView.createImage()?.pngData()
                DataModel.updateGameSave(gameSave: gameSave, context: context)
                NotificationCenter.default.post(name: Notification.Name("GameEnded"), object: nil)
            }
        }
        
        Task {
            try await Task.sleep(nanoseconds:9_000_000_000)
            resetBoard()
        }
    }

}

