//
//  PlantTableViewController.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 07/09/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import UIKit
import CoreData

protocol DidSelectPlants {
    func passSelectedPlants(plants: [PlantModel])
}

class PlantTableViewController: UITableViewController, UISearchBarDelegate {
    var allPlants: [Plant] = []
    var filteredPlants: [PlantModel] = []
    var selectedPlants: [PlantModel] = []
    var delegate: DidSelectPlants?
    var indicator = UIActivityIndicatorView()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = true
        tableView.allowsSelectionDuringEditing = true
        loadAllPlants()
        searchBar.delegate = self
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.center = tableView.center
        indicator.hidesWhenStopped = true
        indicator.backgroundColor = UIColor.clear
        view.addSubview(indicator)
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
        let plantName = currentPlant.name
        let plantDescription = currentPlant.plantDescription ?? "No description"
        cell.plantName.text = plantName
        cell.plantDescription.text = plantDescription
        
        //        if currentPlant.imageUrl == "image url" {
        //            cell.plantImage.image = UIImage(named: "plant")
        //        }
        //        else {
        //            let imageUrl = currentPlant.imageUrl!
        //            let url = URL(string: imageUrl)
        //            if let data = try? Data(contentsOf: url!) {
        //                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        //                imageView.image = UIImage(data: data)
        //                cell.plantImage = imageView
        //            }
        //        }
        
        cell.plantImage.image = UIImage(named: "plant")
        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            indicator.startAnimating()
            filteredPlants = filteredPlants.filter({ (plant: PlantModel) -> Bool in
                return (plant.name?.lowercased().contains(searchText.lowercased()) ?? false)
            })
            performSearchPlantApiCall(searchText: searchText)
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlant = filteredPlants[indexPath.row]
        selectedPlants.append(selectedPlant)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let unselectedPlant = filteredPlants[indexPath.row]
        let name = unselectedPlant.name!
        selectedPlants = selectedPlants.filter({ (plant) -> Bool in
            plant.name != name
        })
    }
    
    @IBAction func setSelectedPlants(_ sender: Any) {
        if selectedPlants.count < 3 {
            let alert = UIAlertController(title: "Oops!", message: "Please choose at least 3 plants!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        delegate?.passSelectedPlants(plants: self.selectedPlants)
        navigationController?.popViewController(animated: true)
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
            for plant in allPlants{
                let name = plant.name
                let family = plant.family
                let year = plant.yearDiscovered
                let id = plant.id
                let imageUrl = plant.imageUrl
                let description = plant.plantDescription
                let plantModel = PlantModel(name: name, plantDescription: description, imageUrl: imageUrl, yearDiscovered: year, family: family, id: id)
                filteredPlants.append(plantModel)
            }
            
            //Merge previously selected plants with new list of filtered plants
            for plant in selectedPlants {
                if filteredPlants.contains(where: { $0.name != plant.name }){
                    filteredPlants.append(plant)
                }
            }
            
            //Add selection style to previously selected plants
            for (index, plant) in filteredPlants.enumerated() {
                let name = plant.name!
                if selectedPlants.contains(where: { $0.name == name }){
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                }
            }
        } catch let error as NSError {
            print("Error in fetching plants \(error.userInfo)")
        }
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
                        DispatchQueue.main.async {
                            if decodedData.data!.count > 0 {
                                for item in decodedData.data! {
                                    let name = item.common_name ?? ""
                                    let family = item.family ?? ""
                                    let imageUrl = item.image_url ?? "plant"
                                    let year = item.year ?? 0
                                    if name.count > 0 {
                                        let plantModel = PlantModel(name: name, plantDescription: "No Description", imageUrl: imageUrl, yearDiscovered: year, family: family, id: nil)
                                        self.filteredPlants.append(plantModel)
                                        self.indicator.stopAnimating()
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    } catch {
                        print("ERROR-> \(error)")
                    }
                }
            }
            task.resume()
        }
    }
}
