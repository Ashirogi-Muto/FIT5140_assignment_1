//
//  AddExhibitionViewController.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 07/09/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import UIKit
import MapKit
class AddExhibitionViewController: UIViewController, MKMapViewDelegate, DidSelectPlants {
    @IBOutlet weak var exhibitName: UITextField!
    @IBOutlet weak var exhibitDescription: UITextField!
    @IBOutlet weak var exhibitLocation: MKMapView!
    @IBOutlet weak var saveExhibition: UIButton!
    @IBOutlet weak var addPlants: UIButton!
    var selectedPlants: [PlantModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlants.layer.cornerRadius = 5
        saveExhibition.layer.cornerRadius = 5
        let initialRegion = CLLocationCoordinate2D(latitude: Constants.DEFAULT_MAP_LAT, longitude: Constants.DEFAULT_MAP_LON)
        exhibitLocation.delegate = self
        exhibitLocation.setRegion(initialRegion)
        let defaultAnnotation = ExhibitAnnotation(coordinate: initialRegion, title: Constants.DEFAULT_ANNOTATION_NAME, subtitle: "", id: UUID())
        exhibitLocation.addAnnotation(defaultAnnotation)
    }
    
    
    
    @IBAction func handleMapTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let locationView = sender.location(in: exhibitLocation)
            let tappedView = exhibitLocation.convert(locationView, toCoordinateFrom: exhibitLocation)
            print(tappedView.latitude)
            print(tappedView.longitude)
            let newSelectedCoordinates = CLLocationCoordinate2D(latitude: tappedView.latitude, longitude: tappedView.longitude)
            let newSelectedAnnotation = ExhibitAnnotation(coordinate: newSelectedCoordinates, title: exhibitName.text ?? "Name", subtitle: exhibitDescription.text ?? "Description", id: UUID())
            let allPreviosAnnotation = exhibitLocation.annotations
            exhibitLocation.removeAnnotations(allPreviosAnnotation)
            exhibitLocation.addAnnotation(newSelectedAnnotation)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.PLANT_VIEW_SEGUE_IDENTIDIER {
            let destination = segue.destination as! PlantTableViewController
            destination.delegate = self
            destination.selectedPlants = selectedPlants
        }
    }
    
    func passSelectedPlants(plants: [PlantModel]) {
        selectedPlants = plants
    }
}

extension MKMapView {
    func setRegion(_ location: CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 100, longitudinalMeters: 100)
        setRegion(region, animated: true)
        setCenter(location, animated: true)
    }
}
