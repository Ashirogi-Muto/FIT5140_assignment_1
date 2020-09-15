//
//  ExhibitDetailViewMasterController.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 07/09/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import UIKit
import CoreData

class ExhibitDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PlantWasUpdated {
    var selectedExhibitId: UUID? = nil
    var commitPredicate: NSPredicate?
    var exhibit: Exhibition?
    var plants: [Plant] = []
    
    @IBOutlet weak var exhibitImage: UIImageView!
    @IBOutlet weak var exhibitDescription: UILabel!
    @IBOutlet weak var exhibitName: UILabel!
    @IBOutlet weak var plantList: UITableView!
    var selectedPlant: Plant?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plantList.delegate = self
        plantList.dataSource = self
        plantList.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadSelectedExhibition()
    }
    
    func refreshPlantList() {
        loadSelectedExhibition()
    }
    
    func loadSelectedExhibition() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Exhibition>(entityName: "Exhibition")
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "id", selectedExhibitId! as CVarArg)
        
        do {
            let exhbition = try managedObjectContext.fetch(fetchRequest)
            if exhbition.count > 0 {
                exhibit = exhbition.first
                plants = (exhibit?.plants!.allObjects ?? []) as [Plant]
                exhibitName.text = exhibit?.name
                exhibitDescription.text = exhibit?.exhibitionDescription
                exhibitImage.image = getExhibitImage(name: exhibit?.image ?? "no name")
                plantList.reloadData()
            }
        } catch let error as NSError {
            print("Error in deleting exhibits \(error.userInfo)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        plants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = plantList.dequeueReusableCell(withIdentifier: Constants.PLANT_CELL_VIEW_IDENTIFIER, for: indexPath)
        let currentPlant = plants[indexPath.row]
        cell.textLabel?.text = currentPlant.name
        cell.detailTextLabel?.text = currentPlant.scientificName
        cell.imageView?.image = getExhibitImage(name: "plant")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlant = plants[indexPath.row]
        performSegue(withIdentifier: Constants.EDIT_PLANT_SEGUE_IDENTIFIER, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.EDIT_PLANT_SEGUE_IDENTIFIER {
            let destination = segue.destination as! EditPlantViewController
            destination.delegate = self
            destination.plantId = selectedPlant?.id
        }
    }
    
    
    func getExhibitImage(name: String) -> UIImage {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(name).path) ?? UIImage(named: "plant")!
        }
        return UIImage(named: "plant")!
    }
}
