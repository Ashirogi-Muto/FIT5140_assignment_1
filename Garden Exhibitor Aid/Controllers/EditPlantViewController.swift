//
//  EditPlantViewController.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 14/09/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import UIKit
import CoreData

protocol PlantWasUpdated {
    func refreshPlantList()
}

class EditPlantViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var plantName: UITextField!
    @IBOutlet weak var plantScientificName: UITextField!
    @IBOutlet weak var yearDiscovered: UITextField!
    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var plantFamily: UITextField!
    var delegate: PlantWasUpdated?
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
        
        plantName.delegate = self
        plantFamily.delegate = self
        yearDiscovered.delegate = self
        plantScientificName.delegate = self
        
        editAndSaveButton.layer.cornerRadius = 5
        loadPlant()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.refreshPlantList()
    }
    
    func loadPlant() {
        let plant = fetchPlant()
        plantName.text = plant?.name
        plantFamily.text = plant?.family
        plantScientificName.text = plant?.scientificName
        yearDiscovered.text = "\(String(describing: plant!.yearDiscovered))"
        let imageUrl = plant?.imageUrl
        plantImage.image = UIImage(named: "plant")
        if imageUrl != nil && imageUrl != "image url" {
            loadPlantImage(imageUrl: imageUrl!)
        }
    }
    
    @IBAction func toggleMode(_ sender: Any) {
        if defaultMode == "edit" {
            defaultMode = "save"
            makeTextFieldsEditable()
        }
        else {
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
        let isValid = areEnteredPlantDetailsValid()
        if isValid == true {
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
                    dismiss(animated: true) {
                        
                    }
                }
            } catch let error as NSError {
                print("Error in fetching the plant \(error.userInfo)")
                return
            }
        }
    }
    
    func areEnteredPlantDetailsValid() -> Bool {
        var isValid = true
        if plantName.text?.count == 0 {
            isValid = false
            if let bg = plantName?.subviews.first {
                bg.backgroundColor = .red
            }
            plantName.attributedPlaceholder = NSAttributedString(string: "Enter a valid name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
        if plantFamily.text?.count == 0 {
            isValid = false
            if let bg = plantFamily?.subviews.first {
                bg.backgroundColor = .red
            }
            plantFamily.attributedPlaceholder = NSAttributedString(string: "Enter a valid family", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
        if plantScientificName.text?.count == 0 {
            isValid = false
            if let bg = plantScientificName?.subviews.first {
                bg.backgroundColor = .red
            }
            plantScientificName.attributedPlaceholder = NSAttributedString(string: "Enter a valid scientifinc name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
        if yearDiscovered.text?.count == 0 {
            isValid = false
            if let bg = yearDiscovered?.subviews.first {
                bg.backgroundColor = .red
            }
            yearDiscovered.attributedPlaceholder = NSAttributedString(string: "Enter a valid year", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
        let yearAsNum = Int(yearDiscovered.text!)
        if yearAsNum == nil {
            isValid = false
            if let bg = yearDiscovered?.subviews.first {
                bg.backgroundColor = .red
            }
            yearDiscovered.attributedPlaceholder = NSAttributedString(string: "Enter a valid year", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
        return isValid
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setDefaultStyleForFormElements()
    }
    
    func setDefaultStyleForFormElements(){
        if let bg = plantName?.subviews.first {
            bg.backgroundColor = .none
        }
        plantName.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)])
        
        if let bg = plantScientificName?.subviews.first {
            bg.backgroundColor = .none
        }
        
        plantScientificName.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)])
        
        if let bg = plantFamily?.subviews.first {
            bg.backgroundColor = .none
        }
        
        plantFamily.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)])
        
        if let bg = yearDiscovered?.subviews.first {
            bg.backgroundColor = .none
        }
        
        yearDiscovered.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)])
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func loadPlantImage(imageUrl: String){
        let url = URL(string: imageUrl)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                self.plantImage.image = UIImage(named: "plant")
                return
            }
            DispatchQueue.main.async {
                self.plantImage.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
}
