//
//  PlantTableViewController.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 07/09/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import UIKit
import CoreData

class PlantTableViewController: UITableViewController, UISearchBarDelegate {
    var allPlants: [Plant] = []
    var filteredPlants: [Plant] = []
    var arePlantsSetByParent = false
    var selectedPlantIds: [UUID] = []
    
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAllPlants()
        tableView.allowsMultipleSelection = true
        tableView.allowsSelectionDuringEditing = true
        searchBar.delegate = self
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPlants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.PLANT_CELL_VIEW_IDENTIFIER, for: indexPath) as! PlantTableViewCell
        let currentPlant = filteredPlants[indexPath.row]
        cell.plantName.text = currentPlant.name
        let image = UIImage(named: "plant")
        cell.plantImage.image = image
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            filteredPlants = allPlants.filter({ (plant: Plant) -> Bool in
                return (plant.name?.lowercased().contains(searchText.lowercased()) ?? false)
            })
            performSearchPlantApiCall(searchText: searchText)
        }
        else {
            filteredPlants = allPlants
        }
//        UIView.setAnimationsEnabled(true)
//        tableView.beginUpdates()
//        tableView.reloadSections(NSIndexSet(index: 1) as IndexSet, with: UITableView.RowAnimation.none)
//        tableView.endUpdates()
        tableView.reloadData()
    }
    
    func loadAllPlants(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Plant>(entityName: "Plant")
        
        do {
            allPlants = try managedObjectContext.fetch(fetchRequest)
            filteredPlants = allPlants
        } catch let error as NSError {
            print("Error in fetching plants \(error.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlant = filteredPlants[indexPath.row]
        selectedPlantIds.append(selectedPlant.id!)
        print(selectedPlantIds)
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let unselectedPlant = filteredPlants[indexPath.row]
        let index = selectedPlantIds.lastIndex(of: unselectedPlant.id!)
        selectedPlantIds.remove(at: index!)
        print(selectedPlantIds)
    }
    
    func performSearchPlantApiCall(searchText: String) {
        let finalUrl = Constants.TREFLE_BASE_URL + "&q=" + searchText
        if let url = URL(string: finalUrl) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let safeData = data {
                   let decoder = JSONDecoder()
                    do {
                     let decodedData = try decoder.decode(PlantSearchResult.self, from: safeData)
                    } catch {
                        print("ERROR-> \(error)")
                    }
                }
            }
            task.resume()
        }
    }
}
