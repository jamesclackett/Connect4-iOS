//
//  DataModel.swift
//  Connect4
//
//  Created by James Clackett on 07/12/2023.
//

import Foundation
import CoreData
import Alpha0C4

/// A struct to represent a played Position
/// This is necessary for the JSON coder to encode/decode positions from game saves
/// The easiest way I found to store objects such as arrays was as encoded Data.
struct Position: Codable {
    let row: Int
    let column: Int
}

/// A Data Model struct to simplify the Core Data API
/// While the APU itself is not very verbose, I need customised behaviour that is.
/// This struct acts as an easy way to interact with Core Data and Game Saves in  the manner I want and improves VC code clarity.
struct DataModel {
    
    /// Function to get all game saves from Core Data
    /// - Returns: An Optional List of Game Saves
    static func getAllGameSaves(context: NSManagedObjectContext) -> [GameSave]? {
        do {
            let request = GameSave.fetchRequest()
            
            let sort = NSSortDescriptor(key: "date", ascending: false)
            request.sortDescriptors = [sort]
            return try context.fetch(request)
            
        } catch {
            print("Error loading game saves: \(error)")
        }
        print("Could not find any game saves")
        return nil
    }
    
    /// Function to get the most recent game save from Core Data
    ///  - Returns: An Optional Game save item
    static func getGameSave(context: NSManagedObjectContext) -> GameSave? {
        do {
            let request = GameSave.fetchRequest()
            
            // Sort results by newest date first
            let sort = NSSortDescriptor(key: "date", ascending: false)
            request.sortDescriptors = [sort]
            
            print("Attempting to load latest game save...")
            // Only get the first item
            if let gameSave = try context.fetch(request).first {
                let id = gameSave.id
                let date = gameSave.date!
                print("Loaded game save: ", id, date)
                return gameSave
            }
        } catch {
            print("Error loading game save: \(error)")
        }
        print("Could not find a game save")
        return nil
    }
    
    /// Creates a new Game Save in Core Data with the provided properties
    /// - Returns: the Game Save item (Optional) that was created
    static func createGameSave(isBotFirst: Bool, botColor: GameSession.DiscColor, context: NSManagedObjectContext) -> GameSave? {
        
        let gameSave = GameSave(context: context)
        gameSave.date = Date()
        gameSave.icon = Data()
        gameSave.playedPositions = DataModel.encodePositions(positions: [(row: Int, column: Int)]())
        gameSave.botIsFirst = isBotFirst
        gameSave.botIsRed = botColor == .red ? true : false
        
        let id = gameSave.id
        let date = gameSave.date!
        
        do {
            try context.save()
            print("Created game save: ", id, date)
            return gameSave
        } catch {
            print("Error creating new game save: \(error)")
        }
        return nil
    }
    
    /// Update the provided Game Save in Core Data
    static func updateGameSave(gameSave: GameSave, context: NSManagedObjectContext) {
        let id = gameSave.id
        let date = gameSave.date
        do {
            try context.save()
            print("Updated game save: ", id, date ?? "date error")
        } catch {
            print("Error updating game save: \(error)")
        }
    }
    
    /// Deletes the provided Game Save in Core Data
    static func deleteGameSave(gameSave: GameSave, context: NSManagedObjectContext) {
        do {
            context.delete(gameSave)
            try context.save()
        } catch {
            print("Error deleted current game: \(error)")
        }
        print("Deleted current game save")
    }
    
    /// Deletes all the Game Saves that are currently stored in memory
    /// Note: This deletes any ongoing games (game will continue but not be saved as reference is lost)
    static func deleteAllGameSaves(context: NSManagedObjectContext) {
        do {
            let request = GameSave.fetchRequest()
            
            let gameSaves = try context.fetch(request)
            for gameSave in gameSaves {
                context.delete(gameSave)
            }
            try context.save()
            print("deleted all save games")
        } catch {
            print("Error deleting all game saves ")
            
        }
    }
    
    /// Deletes Game Save History
    /// Similar to deleteAllGameSaves, but does not delete any ongoing games.
    /// Uses the icon property to know if game is ongoing or not.
    static func deleteAllGameHistory(context: NSManagedObjectContext) {
        do {
            let request = GameSave.fetchRequest()
            
            let gameSaves = try context.fetch(request)
            for gameSave in gameSaves {
                if !gameSave.icon!.isEmpty {
                    context.delete(gameSave)
                }
            }
            try context.save()
            print("deleted all save games")
        } catch {
            print("Error deleting all game saves ")
            
        }
    }
}

/// An extension of Data Model to include Coding functionality for player Positions
extension DataModel {
    
    /// A function to encode a player positions list into JSON Data
    /// - Parameters: 
    ///   - positions: [(row: Int, column: Int)]
    /// - Returns: Data
    static func encodePositions(positions: [(row: Int, column: Int)]) -> Data {
        let structPositions = positions.map { Position(row: $0.row, column: $0.column) }
        
        do {
            return try JSONEncoder().encode(structPositions)
        } catch {
            print("Error encoding positions: \(error)")
        }
        return Data()
    }
    
    /// A function to decode  JSON Data into player positions
    /// - Parameters:
    ///   - positions: Data
    /// - Returns: [(row: Int, column: Int)]
    static func decodePositions(data: Data) -> [(row: Int, column: Int)] {
        do {
            let decoded = try JSONDecoder().decode([Position].self, from: data)
            return decoded.map { (row: $0.row, column: $0.column) }
        } catch {
            print("Error decoding positions: \(error)")
        }
        
        return [(row: Int, column: Int)]()
    }
}
