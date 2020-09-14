//
//  EditPlantViewController.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 14/09/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import UIKit
import CoreData

class EditPlantViewController: UIViewController {
    
    @IBOutlet weak var plantName: UITextField!
    @IBOutlet weak var plantScientificName: UITextField!
    @IBOutlet weak var yearDiscovered: UITextField!
    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var plantFamily: UITextField!
    var imageUrl: String?
    var plantId: UUID?
    var defaultMode: String = "edit"
    @IBOutlet weak var editAndSaveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plantName.borderStyle = .none
        plantFamily.borderStyle = .none
        yearDiscovered.borderStyle = .none
        plantScientificName.borderStyle = .none
        editAndSaveButton.layer.cornerRadius = 5
        loadPlant()
    }
    
    func loadPlant() {
        let plant = fetchPlant()
        plantName.text = plant?.name
        plantFamily.text = plant?.family
        plantScientificName.text = plant?.scientificName
        yearDiscovered.text = "\(String(describing: plant!.yearDiscovered))"
        let imageUrl = plant?.imageUrl
        if imageUrl != nil && imageUrl != "image url" {
            fetchImageFromUrl(urlString: imageUrl!)
        }
        else {
            plantImage.image = UIImage(named: "plant")
        }
    }
    
    @IBAction func toggleMode(_ sender: Any) {
        print(defaultMode)
        if defaultMode == "edit" {
            defaultMode = "save"
            makeTextFieldsEditable()
        }
        else {
            print("CALLING SAVE--->")
            savePlantDetails()
        }
    }
    
    func makeTextFieldsEditable(){
        plantName.borderStyle = .roundedRect
        plantFamily.borderStyle = .roundedRect
        yearDiscovered.borderStyle = .roundedRect
        plantScientificName.borderStyle = .roundedRect
        editAndSaveButton.setTitle("Save", for: .normal)
        plantName.isUserInteractionEnabled = true
        plantFamily.isUserInteractionEnabled = true
        yearDiscovered.isUserInteractionEnabled = true
        plantScientificName.isUserInteractionEnabled = true
    }
    
    func savePlantDetails() {
        defaultMode = "edit"
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Plant>(entityName: "Plant")
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "id", plantId! as CVarArg)
        do {
            let planData = try managedObjectContext.fetch(fetchRequest) as [NSManagedObject]
            if planData.count > 0 {
                let plant = planData.first
                plant?.setValue(plantName.text, forKey: "name")
                plant?.setValue(plantFamily.text, forKey: "family")
                plant?.setValue(plantScientificName.text, forKey: "scientificName")
                if let yearInteger = Int(yearDiscovered.text!) {
                    let yearAsNsNumber = NSNumber(value: yearInteger)
                    plant?.setValue(yearAsNsNumber, forKey: "yearDiscovered")
                }
                try managedObjectContext.save()
                dismiss(animated: true, completion: nil)
            }
        } catch let error as NSError {
            print("Error in fetching the plant \(error.userInfo)")
            return
        }
    }
    
    func areEnteredPlantDetailsValid() -> Bool {
        var isValid = true
        if plantName.text?.count == 0 {
            isValid = false
            if let bg = plantName?.subviews.first {
                bg.backgroundColor = .red
            }
        }
        if plantFamily.text?.count == 0 {
            isValid = false
            if let bg = plantFamily?.subviews.first {
                bg.backgroundColor = .red
            }
        }
        if plantScientificName.text?.count == 0 {
            if let bg = plantScientificName?.subviews.first {
                bg.backgroundColor = .red
            }
        }
        if yearDiscovered.text?.count == 0 {
            if let bg = yearDiscovered?.subviews.first {
                bg.backgroundColor = .red
            }
        }
        let yearAsNum = Int(yearDiscovered.text!)
        if yearAsNum == nil {
            if let bg = yearDiscovered?.subviews.first {
                bg.backgroundColor = .red
            }
        }
        return isValid
    }
    
    func setDefaultStyleForFormElements(){
        if let bg = plantName?.subviews.first {
            bg.backgroundColor = .none
        }
    }
    
    func fetchPlant() -> Plant? {
        var plant: Plant?
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return nil
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Plant>(entityName: "Plant")
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "id", plantId! as CVarArg)
        do {
            let planData = try managedObjectContext.fetch(fetchRequest)
            if planData.count > 0 {
                plant = planData.first
            }
        } catch let error as NSError {
            print("Error in fetching the plant \(error.userInfo)")
            return nil
        }
        return plant
    }
    
    func fetchImageFromUrl(urlString: String) {
        let imageUrl = URL(string: urlString)
        if let data = try? Data(contentsOf: imageUrl!) {
            plantImage.image = UIImage(data: data)
        }
        else {
            plantImage.image = UIImage(named: "plant")
        }
    }
}
