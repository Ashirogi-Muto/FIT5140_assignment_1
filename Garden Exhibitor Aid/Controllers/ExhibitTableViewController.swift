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
    var sortOrder = 0
    
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
    
    
    @IBAction func sortExhibitions(_ sender: Any) {
        if sortOrder == 0 || sortOrder == 1 {
            self.filteredExhibits = self.filteredExhibits.sorted(by: { (exhibitFirst, exhibitNext) -> Bool in
                let nameFirst: String = (exhibitFirst.name as AnyObject) as! String
                let nameNext: String = (exhibitNext.name as AnyObject) as! String
                sortOrder = 2
                return nameFirst > nameNext
            })
        }
        else {
            self.filteredExhibits = self.filteredExhibits.sorted(by: { (exhibitFirst, exhibitNext) -> Bool in
                let nameFirst: String = (exhibitFirst.name as AnyObject) as! String
                let nameNext: String = (exhibitNext.name as AnyObject) as! String
                sortOrder = 1
                return nameFirst < nameNext
            })
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredExhibits.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedExhibit = filteredExhibits[indexPath.row]
        let id = selectedExhibit.id
        let homeScreenTab = tabBarController?.viewControllers?[0] as! HomeScreenController
        homeScreenTab.selectedAnnotationFromExhibitList = id
        tabBarController?.selectedIndex = 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: exhibitCell, for: indexPath) as! ExhibitTableViewCell
        let currentExhibit = filteredExhibits[indexPath.row]
        cell.exhibitName.text = currentExhibit.name
        cell.exhibitDescription.text = currentExhibit.exhibitionDescription
        let image = UIImage(named: "plant")
        cell.exhibitImage.image = image
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
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
