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
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Exhibition>(entityName: "Exhibition")
        
        let plantOne = Plant(context: managedObjectContext)
        plantOne.family = "Family One"
        plantOne.id = UUID()
        plantOne.imageUrl = "image url"
        plantOne.name = "Plant One"
        plantOne.plantDescription = "Plant One"
        plantOne.yearDiscovered = 1992
        
        let plantTwo = Plant(context: managedObjectContext)
        plantTwo.family = "Family Two"
        plantTwo.id = UUID()
        plantTwo.imageUrl = "image url"
        plantTwo.name = "Plant Two"
        plantTwo.plantDescription = "Plant Two"
        plantTwo.yearDiscovered = 1990

        
        let exhibitionOne = Exhibition(context: managedObjectContext)
        exhibitionOne.exhibitionDescription = "exhibition one"
        exhibitionOne.id = UUID()
        exhibitionOne.lat = -37.830043
        exhibitionOne.lon = 144.979198
        exhibitionOne.name = "Exhibition Name"
        exhibitionOne.plants = NSSet.init(array: [plantOne, plantTwo])

        do{
//            try managedObjectContext.save()
            let exhibits = try managedObjectContext.fetch(fetchRequest)
            for exh in exhibits {
                print("Exhibit Name: \(exh.name ?? "No exhibit name")")
                print("Exhibit Id: \(exh.id?.uuidString ?? "No Id")")
                let plants = exh.plants as! Set<Plant>
                for plant in plants {
                    print("Plant Name: \(plant.name ?? "No plant name")")
                }
            }
            print("Saved")
        } catch let error as NSError{
            print("Could not save \(error), \(error.userInfo)")
        }
        
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
