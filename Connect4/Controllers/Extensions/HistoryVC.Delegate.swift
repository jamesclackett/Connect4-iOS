//
//  HistoryVC.Delegate.swift
//  Connect4
//
//  Created by James Clackett on 08/12/2023.
//

import UIKit

/// Table Delegate extension
extension HistoryVC: UITableViewDelegate, UITableViewDataSource {
    
    /// Obj-C function used by various functions, Most importantly by NoticationCentre's 'addObserver'
    ///  Updates the table asynchronously on the main thread. This is ncessary for the UI to be updated correclty.
    @objc func updateTable() {
        print("Update table called")
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    /// Specify the number of rows in the table to be equal to the number of saved games.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView = tableView
        let gameSaves = loadGameHistory()
        return gameSaves.count
    }
    
    /// Set a height of 120 for each cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    /// Manage what each cell displays
    /// Each cell displays the game save information (icon, botFirst, botIsWinner) to the user
    /// In future, I would like to change this so that it uses a custom cell type. It is currently a bit messy and visually unappealing.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath)
        let gameSave = loadGameHistory()[indexPath.row]
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = 
            "\(gameSave.botIsFirst ? "Bot Started" : "User Started") \n\n \(gameSave.botIsWinner ? "Bot Won" : "User Won!")"
        cell.textLabel?.font = .boldSystemFont(ofSize: 20)
        cell.textLabel?.textAlignment = .center
        cell.imageView?.image = UIImage(data: gameSave.icon ?? Data())
            
        return cell
    }
    
    /// Initiate segue on selection of cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gameSave = loadGameHistory()[indexPath.row]
        performSegue(withIdentifier: "toReplayVC", sender: gameSave)
    }
    
    /// Delete a row when the user makes a trailing swipe gesture
    /// Delets the game save being displayed in the current cell and reloads the table
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHanlder) in
            let gameSave = self.loadGameHistory()[indexPath.row]
            self.context.delete(gameSave)
            
            do {
                try self.context.save()
                print("deleting game")
            } catch {
                print("Error deleting game save")
            }
            self.updateTable()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
        
    }
}

