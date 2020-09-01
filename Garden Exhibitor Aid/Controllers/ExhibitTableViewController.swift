//
//  ExhibitTableViewController.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 01/09/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import UIKit
import CoreData

class ExhibitTableViewController: UITableViewController, UISearchResultsUpdating {
    var exhibitions: [Exhibition] = []
    var filteredExhibits: [Exhibition] = []
    let exhibitCell = "exhibitInfoCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAllExhibits()
        filteredExhibits = exhibitions
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Exhibits"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func loadAllExhibits() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Exhibition>(entityName: "Exhibition")
        
        do{
            let exhibits = try managedObjectContext.fetch(fetchRequest)
            exhibitions = exhibits
        } catch let error as NSError {
            print("Error in fetching exhibits \(error.userInfo)")
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredExhibits.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: exhibitCell, for: indexPath) as! ExhibitTableViewCell
        let currentExhibit = filteredExhibits[indexPath.row]
        cell.exhibitName.text = currentExhibit.name
        cell.exhibitDescription.text = currentExhibit.exhibitionDescription
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased()
            else {
                return
        }
        print("searchText \(searchText)")
        if searchText.count > 0 {
            filteredExhibits = exhibitions.filter({ (exhibit: Exhibition) -> Bool in
                return (exhibit.name?.lowercased().contains(searchText.lowercased()) ?? false)
            })
        }
        else {
            filteredExhibits = exhibitions
        }
        tableView.reloadData()
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
