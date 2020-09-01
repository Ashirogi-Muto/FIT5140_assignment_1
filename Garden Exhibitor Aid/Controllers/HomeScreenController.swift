//
//  HomeScreenController.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 25/08/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class HomeScreenController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var homeScreenMap: MKMapView!
    var exhibitions: [Exhibition] = []
    var plants: [Plant] = []
    var coordinates: [CLLocationCoordinate2D] = []
    var exhibitAnnotations: [ExhibitAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        let haveExhibitsInitialised = defaults.bool(forKey: "exhibitInit")
        if haveExhibitsInitialised != true {
            let initExhibit = InitExhibits()
            initExhibit.creatDefaulteExhibits()
            defaults.set(true, forKey: "exhibitInit")
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Exhibition>(entityName: "Exhibition")
        
        do{
            let exhibits = try managedObjectContext.fetch(fetchRequest)
            for exhibit in exhibits {
                let name = exhibit.name ?? "No name"
                let description = exhibit.exhibitionDescription!
                let lat = exhibit.lat
                let lon = exhibit.lon
                let id = exhibit.id!
                let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let annotation = ExhibitAnnotation(coordinate: coordinates, title: name, subtitle: description, id: id)
                exhibitAnnotations.append(annotation)
            }
        } catch let error as NSError {
            print("Error in deleting exhibits \(error.userInfo)")
        }
        
        homeScreenMap.delegate = self
        let initialRegion = CLLocationCoordinate2D(latitude: -37.830187, longitude: 144.979649)
        homeScreenMap.centerLocation(initialRegion)
        //Add annotations
        for annotation in exhibitAnnotations {
            homeScreenMap.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? ExhibitAnnotation else {
            return nil
        }
        let identifier = "exhibit"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = homeScreenMap.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        }
        else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            view.subtitleVisibility = MKFeatureVisibility.visible
        }
        return view
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let exhibit = view.annotation as! ExhibitAnnotation
        let id = exhibit.id.uuidString
        print("ID \(id)")
    }
}

extension MKMapView {
    func centerLocation(_ location: CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 100, longitudinalMeters: 100)
        setRegion(region, animated: true)
        setCenter(location, animated: true)
    }
}

