//
//  Position+CoreDataProperties.swift
//  Connect4
//
//  Created by James Clackett on 07/12/2023.
//
//

import Foundation
import CoreData


extension Position {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Position> {
        return NSFetchRequest<Position>(entityName: "Position")
    }

    @NSManaged public var row: Int16
    @NSManaged public var column: Int16
    @NSManaged public var gamesave: GameSave?

}

extension Position : Identifiable {

}
