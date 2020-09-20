//
//  ExhibitDetailViewMasterController.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 07/09/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import UIKit
import CoreData
import MapKit

//  This controller shows the details of a plant lets the user edit those details
//  Initially the border of text field is removed and the text fields are disabled
//  When the user eants to edit the plant details the borders are added for text field
//  and editing is enabled for the text fields
class ExhibitDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PlantWasUpdated {
    var selectedExhibitId: UUID? = nil
    var commitPredicate: NSPredicate?
    var exhibit: Exhibition?
    var plants: [Plant] = []
    var images: [UIImage] = []

    @IBOutlet weak var exhibitImage: UIImageView!
    @IBOutlet weak var exhibitDescription: UILabel!
    @IBOutlet weak var exhibitName: UILabel!
    @IBOutlet weak var plantList: UITableView!
    
    @IBOutlet weak var exhibitionLocation: MKMapView!
    
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
        //Fetching the app delegate object
        //Refered this style of using Core Data from a Medium article
        //named "Mastering In CoreData"
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
                plants = Array((exhibit?.plants)!) as [Plant]
                print(plants.count)
                let id = exhibit?.id!
                let name = exhibit?.name!
                let exhibitionDescription = exhibit?.exhibitionDescription!
                let image = exhibit?.image ?? "no name"
                exhibitName.text = name
                exhibitDescription.text = exhibitionDescription
                exhibitImage.image = getExhibitImage(name: image)
                let lat = exhibit?.lat
                let lon = exhibit?.lon
                let coordinates = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
                exhibitionLocation.setRegion(coordinates)
                let defaultAnnotation = ExhibitAnnotation(coordinate: coordinates, title: name!, subtitle: exhibitionDescription!, id: id!, image: image)
                exhibitionLocation.addAnnotation(defaultAnnotation)
                exhibitionLocation.isZoomEnabled = false
                exhibitionLocation.isScrollEnabled = false
                exhibitionLocation.isUserInteractionEnabled = false
                loadImagesAsynchronously()
                plantList.reloadData()
            }
        } catch let error as NSError {
            print("Error in deleting exhibits \(error.userInfo)")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        plants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = plantList.dequeueReusableCell(withIdentifier: Constants.PLANT_CELL_VIEW_IDENTIFIER, for: indexPath) as! ExhibitDetailPantTableViewCell
        let currentPlant = plants[indexPath.row]
        cell.plantName?.text = currentPlant.name!
        cell.plantScientificName?.text = currentPlant.scientificName ?? ""
        if images.count > 0 && images.count >= plants.count {
            let currentImage = images[indexPath.row]
            cell.plantImage?.image = currentImage
        }
        else {
            cell.plantImage.image = UIImage(named: "plant")
        }
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
        
        if segue.identifier == Constants.EDIT_EXHIBITION_SEGUE_IDENTIFIER {
            let destination = segue.destination as! AddAndUpdateExhibitionViewController
            destination.passedExhibitionId = selectedExhibitId
        }
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
    
    
    ///Refered the class material to implement
    ///loading of images asynchronously
    func loadImagesAsynchronously(){
        for plant in plants {
            let imageUrl = plant.imageUrl
            if imageUrl != nil && imageUrl != "image url" {
                let url = URL(string: imageUrl!)
                let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                    if error != nil {
                        print("Error in loadImagesAsynchronously \(error.debugDescription)")
                        return
                    }
                    let image = UIImage(data: data!)
                    DispatchQueue.main.async {
                        self.images.append(image!)
                        self.plantList.reloadData()
                    }
                }
                task.resume()
            }
        }
    }
    
    
    @IBAction func loadEditExhibitionView(_ sender: Any) {
        performSegue(withIdentifier: Constants.EDIT_EXHIBITION_SEGUE_IDENTIFIER, sender: self)
    }
}
