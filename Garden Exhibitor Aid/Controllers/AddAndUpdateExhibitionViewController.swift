//
//  AddExhibitionViewController.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 07/09/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//


//IMP:- This controller is used for both operations of adding and updating a controller

import UIKit
import MapKit
import Foundation
import CoreData

//Prtocol to notify other constollers when a new exhibition is added
protocol NewExhibtionCreated {
    func newExhibitionAdded(newExhibition: Exhibition)
}
//Prtocol to notify other constollers when an exhibition is updated
protocol ExhibtionUpdated {
    func exhibitionIsUpdated(updatedExhibition: Exhibition)
}

class AddAndUpdateExhibitionViewController: UIViewController, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DidSelectPlants, UITextFieldDelegate {
    
    @IBOutlet weak var exhibitName: UITextField!
    @IBOutlet weak var exhibitDescription: UITextField!
    @IBOutlet weak var addPlants: UIButton!
    @IBOutlet weak var exhibitLocation: MKMapView!
    @IBOutlet weak var addImage: UIButton!
    @IBOutlet weak var exhibitionImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var modifyExhibitionDetailsButton: UIButton!
    var indicator = UIActivityIndicatorView()
    //This is variable which decided the context for this contorller
    var passedExhibitionId: UUID? = nil
    //If this variable is nil when this controller loads
    //then the controller works for adding a new exhibition
    //If the variable is not nil
    //then the controller works for updating the exhibition
    //with id passed in the variable
    

    var plantsToBeSaved: [Plant] = []
    var selectedPlants: [PlantModel] = []
    var delegate: NewExhibtionCreated?
    var updateExhibitionDelegate: ExhibtionUpdated?
    //This is the variable that stores the exhibition
    //to be updated if the controller loads in
    //update mode
    var passedExhibitionIdDataObject: NSManagedObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exhibitName.delegate = self
        exhibitDescription.delegate = self
        addPlants.layer.cornerRadius = 5
        addImage.layer.cornerRadius = 5
        let homeScreenView = HomeScreenController()
        delegate = homeScreenView
        updateExhibitionDelegate = homeScreenView

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
        //Update the button text
        if passedExhibitionId != nil {
            addImage.setTitle("Update Image", for: .normal)
            loadPassedExhibitionIdDataAndSetTextFields()
        }
    }
    
    
    //Return the app delegate managed context to be used by
    //other functions to interact with Core Data objects
    func getManagedobjectContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return nil
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        return managedObjectContext
    }
    
    func returnExhibitionContextManagedObject() throws -> [Exhibition]? {
        let managedObjectContext = getManagedobjectContext()
        if managedObjectContext != nil {
            let fetchRequest = NSFetchRequest<Exhibition>(entityName: "Exhibition")
            fetchRequest.predicate = NSPredicate(format: "%K == %@", "id", passedExhibitionId! as CVarArg)
            let exhbition = try managedObjectContext!.fetch(fetchRequest)
            return exhbition
        }
        else {
            return nil
        }
    }
    
    //If the controller loads in update mode
    //this func fetched the exhibition selected from
    //the previous screen and sets the form for the
    //user to update the details of the exhibition
    func loadPassedExhibitionIdDataAndSetTextFields() {
        let managedObjectContext = getManagedobjectContext()
        if managedObjectContext != nil {
            do {
                let exhbition = try returnExhibitionContextManagedObject()
                if exhbition!.count > 0 {
                    let exhibit = exhbition?.first
                    let plants = (exhibit?.plants!.allObjects ?? []) as [Plant]
                    exhibitName.text = exhibit?.name
                    exhibitDescription.text = exhibit?.exhibitionDescription
                    exhibitionImage.image = getExhibitImage(name: exhibit?.image ?? "no name")
                    typeCastPlantDataToModeForm(plantArray: plants)
                    let allPreviousAnnotations = exhibitLocation.annotations
                    exhibitLocation.removeAnnotations(allPreviousAnnotations)
                    let coordinates = CLLocationCoordinate2D(latitude: exhibit!.lat, longitude: exhibit!.lon)
                    exhibitLocation.setRegion(coordinates)
                    let currentExhibitAnnotation = ExhibitAnnotation(coordinate: coordinates, title: (exhibit?.name)!, subtitle: "", id: UUID(), image: "plant")
                    exhibitLocation.addAnnotation(currentExhibitAnnotation)
                }
            } catch let error as NSError {
                showAlert(title: "Oops!", message: "Could not load the exhibition", actionTitle: "Ok!")
                modifyExhibitionDetailsButton.isEnabled = false
                print("Error in deleting exhibits \(error.userInfo)")
            }
        }
        else {
            showAlert(title: "Oops!", message: "Could not load the exhibition", actionTitle: "Ok!")
            modifyExhibitionDetailsButton.isEnabled = false
        }
    }
    
    
    //Type cast the Plant type  from NSManagedObject of Core Data to
    //type of Plant Model
    func typeCastPlantDataToModeForm(plantArray: [Plant]) {
        for plant in plantArray {
            let name = plant.name
            let imageUrl = plant.imageUrl
            let scientificName = plant.scientificName
            let year = plant.yearDiscovered
            let family = plant.family
            let id = plant.id
            let plantModel = PlantModel(name: name, imageUrl: imageUrl, scientificName: scientificName, yearDiscovered: year, family: family, id: id)
            selectedPlants.append(plantModel)
        }
        addPlants.setTitle("\(selectedPlants.count) plants", for: .normal)
    }
    
    
    //Gets the lat long of the selected place from the map
    @IBAction func handleMapTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let locationView = sender.location(in: exhibitLocation)
            let tappedView = exhibitLocation.convert(locationView, toCoordinateFrom: exhibitLocation)
            let newSelectedCoordinates = CLLocationCoordinate2D(latitude: tappedView.latitude, longitude: tappedView.longitude)
            print(tappedView.latitude)
            print(tappedView.longitude)
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
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
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
            let managedObjectContext = getManagedobjectContext()
            if managedObjectContext != nil {
                let exhibitionId = UUID()
                let exhibitionToBeSaved = Exhibition(context: managedObjectContext!)
                exhibitionToBeSaved.id = exhibitionId
                exhibitionToBeSaved.name = exhibitName.text
                exhibitionToBeSaved.exhibitionDescription = exhibitDescription.text
                let annotation = exhibitLocation.annotations.first
                exhibitionToBeSaved.lat = NSNumber(value: (annotation?.coordinate.latitude)!) as! Double
                exhibitionToBeSaved.lon = NSNumber(value: (annotation?.coordinate.longitude)!) as! Double
                setPlantsToBeSaved()
                print("Saving \(plantsToBeSaved.count) plants")
                exhibitionToBeSaved.plants = NSSet.init(array: plantsToBeSaved)
                let imageName = "\(exhibitionId.uuidString).png"
                exhibitionToBeSaved.image = imageName
                
                let hasImageBeenSaved = saveImageOfExhibition(image: exhibitionImage.image!, name: imageName)
                if hasImageBeenSaved == true {
                    do{
                        try managedObjectContext?.save()
                        delegate?.newExhibitionAdded(newExhibition: exhibitionToBeSaved)
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
    }
    
    func updateExhibition() {
        let isFormValid = isExhibitionFormValid()
        if isFormValid == true {
            let managedObjectContext = getManagedobjectContext()
            if managedObjectContext != nil {
                let fetchRequest = NSFetchRequest<Exhibition>(entityName: "Exhibition")
                fetchRequest.predicate = NSPredicate(format: "%K == %@", "id", passedExhibitionId! as CVarArg)
                do {
                    let exhbition = try managedObjectContext!.fetch(fetchRequest)
                    if exhbition.count > 0 {
                        let exhibit = exhbition.first
                        exhibit?.setValue(exhibitName.text, forKey: "name")
                        exhibit?.setValue(exhibitDescription.text, forKey: "exhibitionDescription")
                        let annotation = exhibitLocation.annotations.first
                        let lat = NSNumber(value: (annotation?.coordinate.latitude)!) as! Double
                        let lon = NSNumber(value: (annotation?.coordinate.longitude)!) as! Double
                        exhibit?.setValue(lat, forKey: "lat")
                        exhibit?.setValue(lon, forKey: "lon")
                        setPlantsToBeSaved()
                        print("Saving \(plantsToBeSaved.count) plants")
                        exhibit?.addToPlants(NSSet.init(array: plantsToBeSaved))
                        let imageName = "\(passedExhibitionId!.uuidString).png"
                        exhibit?.setValue(imageName, forKey: "image")
                        let hasImageBeenSaved = saveImageOfExhibition(image: exhibitionImage.image!, name: imageName)
                        if hasImageBeenSaved == true {
                            do{
                                try managedObjectContext!.save()
                                updateExhibitionDelegate?.exhibitionIsUpdated(updatedExhibition: exhibit!)
                                view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                            } catch let error as NSError{
                                print("Could not save \(error), \(error.userInfo)")
                                presentSaveExhibitionErrorAlert()
                            }
                        }
                        else {
                            presentSaveExhibitionErrorAlert()
                        }
                    }
                    
                } catch let error as NSError {
                    presentSaveExhibitionErrorAlert()
                    print("Error in updating exhibit \(error.userInfo)")
                }
                
            }
            else {
                showAlert(title: "Oops!", message: "Could not load the exhibition", actionTitle: "Ok!")
                modifyExhibitionDetailsButton.isEnabled = false
            }
        }
    }
    
    //Get the plants selected from the Plant View Controller
    //Convert the type to NSManagedObject and store it in an array
    func setPlantsToBeSaved() {
        let managedObjectContext = getManagedobjectContext()
        if managedObjectContext != nil {
            for plant in selectedPlants {
                let newPlantItem = Plant(context: managedObjectContext!)
                newPlantItem.family = plant.family
                newPlantItem.name = plant.name
                newPlantItem.imageUrl = plant.imageUrl
                newPlantItem.yearDiscovered = plant.yearDiscovered
                newPlantItem.id = plant.id ?? UUID()
                plantsToBeSaved.append(newPlantItem)
            }
        }
    }
    
    //Validate the exhibition form
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
    
    //Set the default style for form elements
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
    
    
    //handle image selection
    //Refered to an article from "theswiftdev.com"
    //to implement handling if image selection
    @IBAction func selectImageForExhibition(_ sender: Any) {
        let chooseImageFromLibraryAction = UIAlertAction(title: "Library", style: .default) { (action: UIAlertAction) in
            self.getImage(from: .photoLibrary)
        }
        
        let cancelImageSelectionAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        let alertController = UIAlertController(title: "Select Image", message: "Choose Location", preferredStyle: .actionSheet)
        alertController.addAction(chooseImageFromLibraryAction)
        alertController.addAction(cancelImageSelectionAction)
        present(alertController, animated: true, completion: nil)
    }

    //Refered to an article from "theswiftdev.com"
    //to implement handling if image selection
    private func getImage(from sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    //Refered to an article from "theswiftdev.com"
    //to implement handling if image selection
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true) {
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            self.exhibitionImage.image = image
        }
    }

    //Refered to an article from "theswiftdev.com"
    //to implement handling if image selection
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    ///Refered to a StackOverflow answer to fetch the images from
    ///FileManager API
    ///If File Manger does not find the image a default image is returned
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
    
    ///Refered to a StackOverflow answer to fetch the images from
    ///FileManager API
    ///If File Manger does not find the image a default image is returned
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
