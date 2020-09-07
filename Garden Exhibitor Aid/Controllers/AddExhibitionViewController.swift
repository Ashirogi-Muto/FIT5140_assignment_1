//
//  AddExhibitionViewController.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 07/09/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import UIKit
import MapKit
class AddExhibitionViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var exhibitName: UITextField!
    @IBOutlet weak var exhibitDescription: UITextField!
    @IBOutlet weak var exhibitLocation: MKMapView!
    @IBOutlet weak var addPlants: UIButton!
    @IBOutlet weak var saveExhibition: UIButton!

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
    
    @IBAction func loadPlantListView(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let plantView = storyboard.instantiateViewController(identifier: Constants.PLANT_CONTROLLER_VIEW_ID) as! PlantTableViewController
        plantView.didMove(toParent: self)
        self.present(plantView, animated: true) {
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MKMapView {
    func setRegion(_ location: CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 100, longitudinalMeters: 100)
        setRegion(region, animated: true)
        setCenter(location, animated: true)
    }
}
