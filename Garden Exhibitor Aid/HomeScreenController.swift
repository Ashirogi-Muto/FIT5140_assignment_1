//
//  HomeScreenController.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 25/08/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import UIKit
import MapKit

class HomeScreenController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var homeScreenMap: MKMapView!
    @IBOutlet weak var viewChangeSegment: UISegmentedControl!
    var exhibitions: [Exhibition] = []
    var plants: [Plant] = []
    var coordinates: [CLLocationCoordinate2D] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeScreenMap.delegate = self
        let initialRegion = CLLocationCoordinate2D(latitude: -37.830187, longitude: 144.979649)
        homeScreenMap.centerLocation(initialRegion)
        coordinates.append(CLLocationCoordinate2D(latitude: -37.830043, longitude: 144.979198))
        coordinates.append(CLLocationCoordinate2D(latitude: -37.829721, longitude: 144.979606))
        coordinates.append(CLLocationCoordinate2D(latitude: -37.829365, longitude: 144.978833))
        
        let plantOne = Plant(name: "Plant one", description: "Plant One", yearDiscovered: 1950, family: "Plant one", imageURL: "plant one")
        let plantTwo = Plant(name: "Plant two", description: "Plant Two", yearDiscovered: 1950, family: "Plant Two", imageURL: "plant two")
        let plantThree = Plant(name: "Plant Three", description: "Plant Three", yearDiscovered: 1950, family: "Plant Three", imageURL: "plant Three")
        plants.append(plantOne)
        plants.append(plantTwo)
        plants.append(plantThree)
        let exhOne = Exhibition(name: "Exhibit One", description: "Exhibit One", plants: plants, coordinate: coordinates[0])
        let exhTwo = Exhibition(name: "Exhibit Two", description: "Exhibit Two", plants: plants, coordinate: coordinates[1])
        let exhThree = Exhibition(name: "Exhibit Three", description: "Exhibit Three", plants: plants, coordinate: coordinates[2])
        exhibitions.append(exhOne)
        exhibitions.append(exhTwo)
        exhibitions.append(exhThree)
        homeScreenMap.addAnnotation(exhOne)
        homeScreenMap.addAnnotation(exhTwo)
        homeScreenMap.addAnnotation(exhThree)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print(view.annotation?.title)
    }
    
    @IBAction func viewChangeFromSegment(_ sender: Any) {
        switch viewChangeSegment.selectedSegmentIndex {
        case 0:
            print("Map")
        case 1:
        print("List")
        default:
            break
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
    func centerLocation(_ location: CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 100, longitudinalMeters: 100)
        setRegion(region, animated: true)
    }
}
