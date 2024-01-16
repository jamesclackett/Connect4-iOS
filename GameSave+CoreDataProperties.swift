//
//  GameSave+CoreDataProperties.swift
//  Connect4
//
//  Created by James Clackett on 08/12/2023.
//
//

import Foundation
import CoreData


extension GameSave {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GameSave> {
        return NSFetchRequest<GameSave>(entityName: "GameSave")
    }

    @NSManaged public var botIsFirst: Bool
    @NSManaged public var botIsRed: Bool
    @NSManaged public var date: Date?
    @NSManaged public var icon: Data?
    @NSManaged public var playedPositions: Data?
    @NSManaged public var botIsWinner: Bool

}

extension GameSave : Identifiable {

}
