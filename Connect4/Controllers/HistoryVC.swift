//
//  HistoryVC.swift
//  Connect4
//
//  Created by James Clackett on 08/12/2023.
//

import UIKit

/// HistoryVC is Responsible for managing the table view created in storyboard
/// This class acts as the delegate and datasource for the table (see extension)
/// Uses the Data Model to retrive historic games, and presents these to the user on the table
class HistoryVC: UIViewController {
    
    // reference to the UITableView in storyboard. Used to reload table when necessary
    @IBOutlet weak var tableView: UITableView!
    
    // Contect for the data model to use
    let context = (UIApplication.shared.delegate as!
                   AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Notification center is extremely useful. Used to trigger table reload from Connect4VC on game ended
        NotificationCenter.default.addObserver(self, selector: #selector(updateTable), name: Notification.Name("GameEnded"), object: nil)
    }
    
    /// Navigation bar delete button
    @IBAction func deleteAllButton(_ sender: Any) {
        deleteAllConfirm()
    }
    
    /// A pop up alert to confirm if user really wants to delete all game save history
    /// If "Cancel", alert does nothing
    /// If "Clear All", deletes all game saves history
    private func deleteAllConfirm() {
        let alert = UIAlertController(title: "Clear History", message: "This will remove all saved games", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
        
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { _ in
            DataModel.deleteAllGameHistory(context: self.context)
            self.updateTable()
        })
        present(alert, animated: true, completion: nil)
    }
    
    /// Loads history game saves from Core Data using the Data Model
    /// Checks to make sure it does not include an ongoing game (again via the hacky hacky icon condition)
    /// If there is an ongoing game, drop it from list. Do not want to show/alter it in any way
    /// - Returns: A List of GameSave
    func loadGameHistory() -> [GameSave] {
        let gameSaves = DataModel.getAllGameSaves(context: self.context) ?? [GameSave]()
        
        if let first = gameSaves.first {
            if first.icon!.isEmpty {
                return Array(gameSaves.dropFirst())
            }
        }
        return gameSaves
    }
    
    /// Segue function that loads ReplayVC and passes it the relevant GameSave variable
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ReplayVC
        destinationVC.historySave = sender as? GameSave
    }

}
