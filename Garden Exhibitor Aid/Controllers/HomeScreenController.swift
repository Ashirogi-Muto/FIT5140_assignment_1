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

class HomeScreenController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, NewExhibtionCreated, ExhibitionDeleted, ExhibtionUpdated {
    
    @IBOutlet weak var homeScreenMap: MKMapView!
    var exhibitions: [Exhibition] = []
    var plants: [Plant] = []
    var coordinates: [CLLocationCoordinate2D] = []
    var exhibitAnnotations: [ExhibitAnnotation] = []
    var selectedAnnotationFromExhibitList: UUID? = nil
    var selectedAnnotationIdForDetail: UUID? = nil
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Increase font sise for tab bar item text
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : Constants.APP_COLOR_DARK], for: .selected)

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 20

        //Check if default echibitions have been created
        //If not then create default exhibitions
        let defaults = UserDefaults.standard
        let haveExhibitsInitialised = defaults.bool(forKey: "exhibitInit")
        if haveExhibitsInitialised != true {
            let initExhibit = InitializeExhibits()
            initExhibit.creatDefaulteExhibits()
            defaults.set(true, forKey: "exhibitInit")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupHomeScreenMap()
    }
    override func viewDidDisappear(_ animated: Bool) {
        selectedAnnotationFromExhibitList = nil
    }

    /// This function sets up the home screen map
    /// It loads all the exhibitions from Core Data
    /// Sets the default annotation fr the garden
    /// then adds the remaining annotations
    func setupHomeScreenMap() {
        loadAllExhibitionsForMap()
        homeScreenMap.delegate = self
        
        let initialRegion = CLLocationCoordinate2D(latitude: Constants.DEFAULT_MAP_LAT, longitude: Constants.DEFAULT_MAP_LON)
        homeScreenMap.centerLocation(initialRegion)
        reinitializeMapAnnotations()
        let defaultAnnotation = ExhibitAnnotation(coordinate: initialRegion, title: Constants.DEFAULT_ANNOTATION_NAME, subtitle: "", id: UUID(), image: "plant")
        homeScreenMap.addAnnotation(defaultAnnotation)
        //infalte the selected annotation if any
        if selectedAnnotationFromExhibitList != nil {
            for exhibit in exhibitAnnotations {
                let id = exhibit.id
                if id == selectedAnnotationFromExhibitList {
                    homeScreenMap.selectAnnotation(exhibit, animated: true)
                }
            }
        }
    }
    
    /// Remove all previous annotations
    /// and initlialize them again
    func reinitializeMapAnnotations() {
        //first remove previous annotations
        let allAnnotations = homeScreenMap.annotations
        homeScreenMap.removeAnnotations(allAnnotations)
        //Then add all the available annotations
        for annotation in exhibitAnnotations {
            homeScreenMap.addAnnotation(annotation)
        }
    }
    ///Fetch exhibitions from Core Data
    ///Add annotations and init geo fence for them
    func loadAllExhibitionsForMap() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Exhibition>(entityName: "Exhibition")
        
        do{
            exhibitAnnotations = []
            let exhibits = try managedObjectContext.fetch(fetchRequest)
            for exhibit in exhibits {
                let name = exhibit.name ?? "No name"
                let description = exhibit.exhibitionDescription ?? "No Description"
                let lat = exhibit.lat
                let lon = exhibit.lon
                let id = exhibit.id!
                let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let imageName = exhibit.image ?? "no image"
                let annotation = ExhibitAnnotation(coordinate: coordinates, title: name, subtitle: description, id: id, image: imageName)
                exhibitAnnotations.append(annotation)
                initiateGeofencing(coordinates: coordinates, name: name)
            }
        } catch let error as NSError {
            print("Error in fetching exhibits \(error.userInfo)")
        }
    }

    func initiateGeofencing(coordinates: CLLocationCoordinate2D, name: String) {
        let geofencingCenter = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let geofencingRegion = CLCircularRegion(center: geofencingCenter, radius: 200, identifier: name)
        geofencingRegion.notifyOnEntry = true
        geofencingRegion.notifyOnExit = true
        locationManager.startMonitoring(for: geofencingRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        homeScreenMap.showsUserLocation = (status == .authorizedAlways)
    }
    
    ///Set the callout of rmap annotations
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
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            view.subtitleVisibility = MKFeatureVisibility.visible
            let leftImageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
            leftImageView.image = getExhibitImageForAnnotation(name: annotation.image!)
            view.leftCalloutAccessoryView = leftImageView
        }
        return view
    }
    
    func getExhibitImageForAnnotation(name: String) -> UIImage {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(name).path) ?? UIImage(named: "plant")!
        }
        return UIImage(named: "plant")!
    }
    
    ///Handle the callout tap and open the exhibition detail screen
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let exhibit = view.annotation as! ExhibitAnnotation
        if exhibit.coordinate.latitude != Constants.DEFAULT_MAP_LAT && exhibit.coordinate.longitude != Constants.DEFAULT_MAP_LON {
            selectedAnnotationIdForDetail = exhibit.id
             performSegue(withIdentifier: Constants.EXHIBIT_DETAIL_SEGUE_IDENTIFIER, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.EXHIBIT_DETAIL_SEGUE_IDENTIFIER {
            let destination = segue.destination as! ExhibitDetailViewController
            destination.selectedExhibitId = selectedAnnotationIdForDetail
        }
    }
    
    
    ///This is a delegate function which creates a new geo fencing region
    ///for a newly created exhibition
    func initializeGeofencingForNewExhibition(coordinates: CLLocationCoordinate2D, name: String) {
        initiateGeofencing(coordinates: coordinates, name: name)
    }
    
    ///This is a delegate function which updates the geo fencing region
    ///for an updated  exhibition
    func initializeGeofencingForUpdatedExhibition(updatedExhibition: Exhibition) {
        let updatedName = updatedExhibition.name!
        removeGeofence(name: updatedName)
        let lat = updatedExhibition.lat
        let lon = updatedExhibition.lon
        let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        initiateGeofencing(coordinates: coordinates, name: updatedName)
    }
    
    ///This is a delegate function which removed the geo fencing region
    ///when an exhibition is deleted
    func removeGeofence(name: String) {
        for region in locationManager.monitoredRegions {
            guard let region = region as? CLCircularRegion, region.identifier == name else { continue }
            locationManager.stopMonitoring(for: region)
        }
    }
}

extension MKMapView {
    func centerLocation(_ location: CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 100, longitudinalMeters: 100)
        setRegion(region, animated: true)
        setCenter(location, animated: true)
    }
}
