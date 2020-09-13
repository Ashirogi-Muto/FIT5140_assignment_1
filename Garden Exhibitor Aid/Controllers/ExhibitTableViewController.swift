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
    var sortOrder = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Exhibits"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadAllExhibits()
    }
    
    func loadAllExhibits() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Exhibition>(entityName: "Exhibition")
        
        do{
            exhibitions = try managedObjectContext.fetch(fetchRequest)
            filteredExhibits = exhibitions
            print(exhibitions.count)
            tableView.reloadData()
        } catch let error as NSError {
            print("Error in fetching exhibits \(error.userInfo)")
        }
    }
    
    
    @IBAction func sortExhibitions(_ sender: Any) {
        if sortOrder == 0 || sortOrder == 1 {
            filteredExhibits = filteredExhibits.sorted(by: { (exhibitFirst, exhibitNext) -> Bool in
                let nameFirst: String = (exhibitFirst.name as AnyObject) as! String
                let nameNext: String = (exhibitNext.name as AnyObject) as! String
                sortOrder = 2
                return nameFirst > nameNext
            })
        }
        else {
            filteredExhibits = filteredExhibits.sorted(by: { (exhibitFirst, exhibitNext) -> Bool in
                let nameFirst: String = (exhibitFirst.name as AnyObject) as! String
                let nameNext: String = (exhibitNext.name as AnyObject) as! String
                sortOrder = 1
                return nameFirst < nameNext
            })
        }
        tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.EXHIBIT_CELL_VIEW_IDENTIFIER, for: indexPath) as! ExhibitTableViewCell
        let currentExhibit = filteredExhibits[indexPath.row]
        cell.exhibitName.text = currentExhibit.name
        cell.exhibitDescription.text = currentExhibit.exhibitionDescription
        cell.exhibitImage.image = getExhibitImage(name: currentExhibit.image ?? "no image")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                else {
                    return
            }
            let managedObjectContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<Exhibition>(entityName: "Exhibition")
            let id = filteredExhibits[indexPath.row].id
            fetchRequest.predicate = NSPredicate(format: "%K == %@", "id", id! as CVarArg)
            if let result = try? managedObjectContext.fetch(fetchRequest) {
                for item in result {
                    managedObjectContext.delete(item)
                }
            }
            do {
                try managedObjectContext.save()
                loadAllExhibits()
            } catch  {
                print("Could not delete")
            }
        }
    }
    
    func getExhibitImage(name: String) -> UIImage {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(name).path) ?? UIImage(named: "plant")!
        }
        return UIImage(named: "plant")!
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased()
            else {
                return
        }

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
}
