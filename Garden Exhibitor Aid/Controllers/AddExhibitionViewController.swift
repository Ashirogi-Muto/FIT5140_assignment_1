//
//  AddExhibitionViewController.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 07/09/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import CoreData

protocol NewExhibtionCreated {
    func initializeGeofencingForNewExhibition(coordinates: CLLocationCoordinate2D, name: String)
}

class AddExhibitionViewController: UIViewController, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DidSelectPlants, UITextFieldDelegate {
    
    @IBOutlet weak var exhibitName: UITextField!
    @IBOutlet weak var exhibitDescription: UITextField!
    @IBOutlet weak var addPlants: UIButton!
    @IBOutlet weak var exhibitLocation: MKMapView!
    @IBOutlet weak var addImage: UIButton!
    @IBOutlet weak var exhibitionImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var modifyExhibitionDetailsButton: UIButton!
    var indicator = UIActivityIndicatorView()
    var passedExhibitionId: UUID? = nil
    var plantsToBeSaved: [Plant] = []
    var selectedPlants: [PlantModel] = []
    var delegate: NewExhibtionCreated?
    var passedExhibitionIdDataObject: NSManagedObject!

    override func viewDidLoad() {
        super.viewDidLoad()
        exhibitName.delegate = self
        exhibitDescription.delegate = self
        addPlants.layer.cornerRadius = 5
        addImage.layer.cornerRadius = 5
        let homeScreenView = HomeScreenController()
        delegate = homeScreenView
        let initialRegion = CLLocationCoordinate2D(latitude: Constants.DEFAULT_MAP_LAT, longitude: Constants.DEFAULT_MAP_LON)
        exhibitLocation.delegate = self
        exhibitLocation.setRegion(initialRegion)
        let defaultAnnotation = ExhibitAnnotation(coordinate: initialRegion, title: Constants.DEFAULT_ANNOTATION_NAME, subtitle: "", id: UUID(), image: "plant")
        exhibitLocation.addAnnotation(defaultAnnotation)
        exhibitName.delegate = self
        exhibitDescription.delegate = self
        modifyExhibitionDetailsButton.layer.cornerRadius = 5
    }
    override func viewDidAppear(_ animated: Bool) {
        if passedExhibitionId != nil {
            addImage.setTitle("Update Image", for: .normal)
            loadPassedExhibitionIdDataAndSetTextFields()
        }
    }
    
    func loadPassedExhibitionIdDataAndSetTextFields() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Exhibition>(entityName: "Exhibition")
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "id", passedExhibitionId! as CVarArg)
        do {
            let exhbition = try managedObjectContext.fetch(fetchRequest)
            if exhbition.count > 0 {
                let exhibit = exhbition.first
                let plants = (exhibit?.plants!.allObjects ?? []) as [Plant]
                exhibitName.text = exhibit?.name
                exhibitDescription.text = exhibit?.exhibitionDescription
                exhibitionImage.image = getExhibitImage(name: exhibit?.image ?? "no name")
                typeCastPlantDataToModeForm(plantArray: plants)
            }

        } catch let error as NSError {
            showAlert(title: "Oop!", message: "Could not load the exhibition", actionTitle: "Ok!")
            modifyExhibitionDetailsButton.isEnabled = false
            print("Error in deleting exhibits \(error.userInfo)")
        }
    }
    
    func typeCastPlantDataToModeForm(plantArray: [Plant]) {
        for plant in plantArray {
            let name = plant.name
            let plantDescription = plant.plantDescription
            let imageUrl = plant.imageUrl
            let scientificName = plant.scientificName
            let year = plant.yearDiscovered
            let family = plant.family
            let id = plant.id
            let plantModel = PlantModel(name: name, plantDescription: plantDescription, imageUrl: imageUrl, scientificName: scientificName, yearDiscovered: year, family: family, id: id)
            selectedPlants.append(plantModel)
        }
        addPlants.setTitle("\(selectedPlants.count) plants", for: .normal)
    }
    
    @IBAction func handleMapTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let locationView = sender.location(in: exhibitLocation)
            let tappedView = exhibitLocation.convert(locationView, toCoordinateFrom: exhibitLocation)
            print(tappedView.latitude)
            print(tappedView.longitude)
            let newSelectedCoordinates = CLLocationCoordinate2D(latitude: tappedView.latitude, longitude: tappedView.longitude)
            let newSelectedAnnotation = ExhibitAnnotation(coordinate: newSelectedCoordinates, title: exhibitName.text ?? "Name", subtitle: exhibitDescription.text ?? "Description", id: UUID(), image: "plant")
            let allPreviosAnnotation = exhibitLocation.annotations
            exhibitLocation.removeAnnotations(allPreviosAnnotation)
            exhibitLocation.addAnnotation(newSelectedAnnotation)
        }
    }
    
    func passSelectedPlants(plants: [PlantModel]) {
        selectedPlants = plants
        let count = selectedPlants.count
        if count > 0 {
            addPlants.setTitle("\(count) plants", for: .normal)
        }
    }
    
    func presentSaveExhibitionErrorAlert() {
        let alertController = UIAlertController(title: "Error", message: "Could not save the exhibition!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    //Since this controller will be used for adding and updating the exhibition
    //This func will decide what to do with the contents of the form
    //based on if a previous exhibition ID is passed or not
    @IBAction func modifyExhibitionDataBasedOnContext(_ sender: Any) {
        if passedExhibitionId != nil {
            updateExhibition()
        }
        else {
            saveExhibition()
        }
    }
    
    func saveExhibition() {
        let isFormValid = isExhibitionFormValid()
        if isFormValid == true {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                else {
                    return
            }
            let managedObjectContext = appDelegate.persistentContainer.viewContext
            for plant in selectedPlants {
                let plantToBeSaved = Plant(context: managedObjectContext)
                plantToBeSaved.family = plant.family
                plantToBeSaved.name = plant.name
                plantToBeSaved.imageUrl = plant.imageUrl
                plantToBeSaved.plantDescription = plant.plantDescription
                plantToBeSaved.yearDiscovered = plant.yearDiscovered
                plantToBeSaved.id = plant.id ?? UUID()
                plantsToBeSaved.append(plantToBeSaved)
            }
            let exhibitionId = UUID()
            
            let exhibitionToBeSaved = Exhibition(context: managedObjectContext)
            exhibitionToBeSaved.id = exhibitionId
            exhibitionToBeSaved.name = exhibitName.text
            exhibitionToBeSaved.exhibitionDescription = exhibitDescription.text
            let annotation = exhibitLocation.annotations.first
            exhibitionToBeSaved.lat = NSNumber(value: (annotation?.coordinate.latitude)!) as! Double
            exhibitionToBeSaved.lon = NSNumber(value: (annotation?.coordinate.longitude)!) as! Double
            exhibitionToBeSaved.plants = NSSet.init(array: plantsToBeSaved)
            let imageName = "\(exhibitionId.uuidString).png"
            exhibitionToBeSaved.image = imageName
            
            let hasImageBeenSaved = saveImageOfExhibition(image: exhibitionImage.image!, name: imageName)
            if hasImageBeenSaved == true {
                do{
                    try managedObjectContext.save()
                    delegate?.initializeGeofencingForNewExhibition(coordinates: annotation!.coordinate, name: exhibitionToBeSaved.name!)
                    navigationController?.popViewController(animated: true)
                } catch let error as NSError{
                    print("Could not save \(error), \(error.userInfo)")
                    presentSaveExhibitionErrorAlert()
                }
            }
            else {
                presentSaveExhibitionErrorAlert()
            }
        }
    }
    
    func updateExhibition() {
        let isFormValid = isExhibitionFormValid()
    }
    
    func isExhibitionFormValid() -> Bool {
        var isValid = true
        //Change the colors to default before validating the data
        setDefaultStyleForFormElements()
        
        if exhibitName.text!.count <= 0 {
            isValid = false
            if let bg = exhibitName?.subviews.first {
                bg.backgroundColor = .red
            }
            exhibitName.attributedPlaceholder = NSAttributedString(string: "Exhibition Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
        
        if exhibitDescription.text!.count <= 0 {
            if let bg = exhibitDescription?.subviews.first {
                bg.backgroundColor = .red
            }
            exhibitDescription.attributedPlaceholder = NSAttributedString(string: "Exhibition Description", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            isValid = false
        }
        
        let annotations = exhibitLocation.annotations
        if annotations.count > 0 {
            let annotation = annotations.first
            if annotation?.coordinate.latitude == Constants.DEFAULT_MAP_LAT && annotation?.coordinate.longitude == Constants.DEFAULT_MAP_LON {
                locationLabel.text = "Choose a new location!"
                locationLabel.textColor = .red
                isValid = false
            }
        }
        
        if selectedPlants.count == 0 {
            addPlants.backgroundColor = .red
            addPlants.setTitle("Choose at least 3 plants!", for: .normal)
            isValid = false
        }
        
        if exhibitionImage.image == nil {
            addImage.backgroundColor = .red
            isValid = false
        }
        
        return isValid
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setDefaultStyleForFormElements()
    }
    
    func setDefaultStyleForFormElements(){
        locationLabel.text = "Choose a location:"
        locationLabel.textColor = Constants.APP_COLOR_DARK
        if let bg = exhibitName?.subviews.first {
            bg.backgroundColor = .none
        }
        if let bg = exhibitDescription?.subviews.first {
            bg.backgroundColor = .none
        }
        if selectedPlants.count > 0 {
            addPlants.setTitle("\(selectedPlants.count) plants", for: .normal)
        }
        else {
            addPlants.setTitle("Add Plants", for: .normal)
        }
        addPlants.backgroundColor = Constants.APP_COLOR_DARK
        addImage.backgroundColor = Constants.APP_COLOR_DARK

        exhibitName.attributedPlaceholder = NSAttributedString(string: "Exhibition Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)])
        
        exhibitDescription.attributedPlaceholder = NSAttributedString(string: "Exhibition Description", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)])
    }
    
    @IBAction func selectImageForExhibition(_ sender: Any) {
        let chooseImageFromCameraAction = UIAlertAction(title: "Camera", style: .default) { (action: UIAlertAction) in
            self.getImage(from: .camera)
        }
        
        let chooseImageFromLibraryAction = UIAlertAction(title: "Library", style: .default) { (action: UIAlertAction) in
            self.getImage(from: .photoLibrary)
        }
        
        let cancelImageSelectionAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        let alertController = UIAlertController(title: "Select Image", message: "Choose Location", preferredStyle: .actionSheet)
        alertController.addAction(chooseImageFromCameraAction)
        alertController.addAction(chooseImageFromLibraryAction)
        alertController.addAction(cancelImageSelectionAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func getImage(from sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true) {
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            self.exhibitionImage.image = image
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveImageOfExhibition(image: UIImage, name: String) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent(name)!)
            print("IMAGE SAVED___>>>>")
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.PLANT_VIEW_SEGUE_IDENTIDIER {
            let destination = segue.destination as! PlantTableViewController
            destination.delegate = self
            destination.selectedPlants = selectedPlants
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func performAddPlantSegue(_ sender: Any) {
        performSegue(withIdentifier: Constants.PLANT_VIEW_SEGUE_IDENTIDIER, sender: self)
    }
    
    func getExhibitImage(name: String) -> UIImage {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(name).path) ?? UIImage(named: "plant")!
        }
        return UIImage(named: "plant")!
    }
    
    func showAlert(title: String, message: String, actionTitle: String) {
        let alertAction = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
}

extension MKMapView {
    func setRegion(_ location: CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 100, longitudinalMeters: 100)
        setRegion(region, animated: true)
        setCenter(location, animated: true)
    }
}
