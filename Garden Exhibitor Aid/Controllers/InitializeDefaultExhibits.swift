//
//  InitExhibits.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 31/08/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//
import UIKit
import CoreData
/**
 Create default  exhibtions for the app
 */
enum DefaultExhibitionCretionError: Error {
    case managedObjectContextError(String)
    case plantFetchError(String)
    case runTimeError(String)
}

protocol DefaultExhibitionCreation {
    func defaultExhibitionsCreated(allDone: Bool)
}

class InitializeExhibits {
    var fetchedPlants: [Plant] = []
    var delegate: DefaultExhibitionCreation? = nil

    init() {
    }
    
    private func getManagedObjectContext() -> NSManagedObjectContext? {
        //Fetching the app delegate object
        //Refered this style of using Core Data from a Medium article
        //named "Mastering In CoreData"
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return nil
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        return managedObjectContext
    }
    
    
    func startDefaultExhibitionProcess() {
        let defaults = UserDefaults.standard
        let haveExhibitsInitialised = defaults.bool(forKey: "exhibitInit")
        if haveExhibitsInitialised != true {
            fetchPlants()
            defaults.set(true, forKey: "exhibitInit")
        }
    }
    
    private func createExhibitions() throws {
        let managedObjectContext = getManagedObjectContext()
        if managedObjectContext == nil {
            throw DefaultExhibitionCretionError.managedObjectContextError("Could not create default exhibitions")
        }
        
        if fetchedPlants.count == 0 || fetchedPlants.count < 20 {
            throw DefaultExhibitionCretionError.plantFetchError("Plants not loaded")
        }
        
        let exhibitionOne = Exhibition(context: managedObjectContext!)
        exhibitionOne.exhibitionDescription = "Exhibition One"
        exhibitionOne.id = UUID()
        exhibitionOne.lat = -37.83026972238079
        exhibitionOne.lon = 144.9812958604805
        exhibitionOne.name = "Exhibition One"
        exhibitionOne.plants = NSSet.init(array: [fetchedPlants[0], fetchedPlants[1]])
        
        let exhibitionTwo = Exhibition(context: managedObjectContext!)
        exhibitionTwo.exhibitionDescription = "Exhibition Two"
        exhibitionTwo.id = UUID()
        exhibitionTwo.lat = -37.830434897948926
        exhibitionTwo.lon = 144.98160575012548
        exhibitionTwo.name = "Exhibition Two"
        exhibitionTwo.plants = NSSet.init(array: [fetchedPlants[2], fetchedPlants[3]])
        
        let exhibitionThree = Exhibition(context: managedObjectContext!)
        exhibitionThree.exhibitionDescription = "Exhibition Three"
        exhibitionThree.id = UUID()
        exhibitionThree.lat = -37.8303868469452
        exhibitionThree.lon = 144.98095174988987
        exhibitionThree.name = "Exhibition Three"
        exhibitionThree.plants = NSSet.init(array: [fetchedPlants[4], fetchedPlants[5]])
        
        let exhibitionFour = Exhibition(context: managedObjectContext!)
        exhibitionFour.exhibitionDescription = "Exhibition Four"
        exhibitionFour.id = UUID()
        exhibitionFour.lat = -37.83088687664818
        exhibitionFour.lon = 144.98128635463326
        exhibitionFour.name = "Exhibition Four"
        exhibitionFour.plants = NSSet.init(array: [fetchedPlants[6], fetchedPlants[7]])
        
        let exhibitionFive = Exhibition(context: managedObjectContext!)
        exhibitionFive.exhibitionDescription = "Exhibition Five"
        exhibitionFive.id = UUID()
        exhibitionFive.lat = -37.83075774014967
        exhibitionFive.lon = 144.9807026974235
        exhibitionFive.name = "Exhibition Five"
        exhibitionFive.plants = NSSet.init(array: [fetchedPlants[8], fetchedPlants[9]])
        
        let exhibitionSix = Exhibition(context: managedObjectContext!)
        exhibitionSix.exhibitionDescription = "Exhibition Six"
        exhibitionSix.id = UUID()
        exhibitionSix.lat = -37.830538038716156
        exhibitionSix.lon = 144.98158465914935
        exhibitionSix.name = "Exhibition Six"
        exhibitionSix.plants = NSSet.init(array: [fetchedPlants[10], fetchedPlants[11]])
        
        let exhibitionSeven = Exhibition(context: managedObjectContext!)
        exhibitionSeven.exhibitionDescription = "Exhibition Seven"
        exhibitionSeven.id = UUID()
        exhibitionSeven.lat = -37.83080902877808
        exhibitionSeven.lon = 144.98277437171112
        exhibitionSeven.name = "Exhibition Seven"
        exhibitionSeven.plants = NSSet.init(array: [fetchedPlants[12], fetchedPlants[13]])
        
        let exhibitionEight = Exhibition(context: managedObjectContext!)
        exhibitionEight.exhibitionDescription = "Exhibition Eight"
        exhibitionEight.id = UUID()
        exhibitionEight.lat = -37.83084070287619
        exhibitionEight.lon = 144.98053307800853
        exhibitionEight.name = "Exhibition Eight"
        exhibitionEight.plants = NSSet.init(array: [fetchedPlants[14], fetchedPlants[15]])
        
        let exhibitionNine = Exhibition(context: managedObjectContext!)
        exhibitionNine.exhibitionDescription = "Exhibition Nine"
        exhibitionNine.id = UUID()
        exhibitionNine.lat = -37.83029520262037
        exhibitionNine.lon = 144.9808048849983
        exhibitionNine.name = "Exhibition Nine"
        exhibitionNine.plants = NSSet.init(array: [fetchedPlants[16], fetchedPlants[17]])
        
        let exhibitionTen = Exhibition(context: managedObjectContext!)
        exhibitionTen.exhibitionDescription = "Exhibition Ten"
        exhibitionTen.id = UUID()
        exhibitionTen.lat = -37.830823106156686
        exhibitionTen.lon = 144.98035484391693
        exhibitionTen.name = "Exhibition Ten"
        exhibitionTen.plants = NSSet.init(array: [fetchedPlants[18], fetchedPlants[19]])
        do{
            try managedObjectContext!.save()
            print("Data Created")
            delegate?.defaultExhibitionsCreated(allDone: true)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
            throw DefaultExhibitionCretionError.runTimeError("Error in saving managed object context")
        }
    }
    
    private func fetchPlants() {
        let managedObjectContext = getManagedObjectContext()
        if managedObjectContext == nil {
            return
        }
        let url = URL(string: Constants.TREFLE_BASE_URL)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("Error in fetching default plants")
                return
            }
            if let safeData = data {
                let decoder = JSONDecoder()
                do {
                    let decodedData = try decoder.decode(PlantSearchResult.self, from: safeData)
                    DispatchQueue.main.async {
                        if decodedData.data!.count > 0 {
                            for item in decodedData.data! {
                                let name = item.common_name ?? ""
                                let family = item.family ?? ""
                                let imageUrl = item.image_url ?? "plant"
                                let year = item.year ?? 0
                                let scientificName = item.scientific_name
                                if name.count > 0 {
                                    let plant = Plant(context: managedObjectContext!)
                                    plant.name = name
                                    plant.family = family
                                    plant.id = UUID()
                                    plant.imageUrl = imageUrl
                                    plant.scientificName = scientificName
                                    plant.yearDiscovered = year
                                    self.fetchedPlants.append(plant)
                                }
                            }
                            do {
                                try self.createExhibitions()
                            } catch let error {
                                print("Error in createExhibitions \(error.localizedDescription)")
                            }
                        }
                    }
                } catch {
                    print("ERROR-> \(error)")
                }
            }
            
        }
        task.resume()
    }
    
}
