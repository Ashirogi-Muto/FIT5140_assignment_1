//
//  InitExhibits.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 31/08/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//
import UIKit
import CoreData

class InitExhibits {
    func creatDefaulteExhibits(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        print("Creating data")
        let plantOne = Plant(context: managedObjectContext)
        plantOne.family = "Family One"
        plantOne.id = UUID()
        plantOne.imageUrl = "image url"
        plantOne.name = "Plant One"
        plantOne.plantDescription = "Plant One"
        plantOne.scientificName = "Plant One"
        plantOne.yearDiscovered = 1992
        
        let plantTwo = Plant(context: managedObjectContext)
        plantTwo.family = "Family Two"
        plantTwo.id = UUID()
        plantTwo.imageUrl = "image url"
        plantTwo.name = "Plant Two"
        plantTwo.plantDescription = "Plant Two"
        plantTwo.scientificName = "Plant Two"
        plantTwo.yearDiscovered = 1990
        
        let plantThree = Plant(context: managedObjectContext)
        plantThree.family = "Family Three"
        plantThree.id = UUID()
        plantThree.imageUrl = "image url"
        plantThree.name = "Plant Three"
        plantThree.scientificName = "Plant Three"
        plantThree.plantDescription = "Plant Three"
        plantThree.yearDiscovered = 1998
        
        let plantFour = Plant(context: managedObjectContext)
        plantFour.family = "Family Four"
        plantFour.id = UUID()
        plantFour.imageUrl = "image url"
        plantFour.name = "Plant Four"
        plantFour.scientificName = "Plant Four"
        plantFour.plantDescription = "Plant Four"
        plantFour.yearDiscovered = 1997
        
        let plantFive = Plant(context: managedObjectContext)
        plantFive.family = "Family Five"
        plantFive.id = UUID()
        plantFive.imageUrl = "image url"
        plantFive.name = "Plant Five"
        plantFive.scientificName = "Plant Five"
        plantFive.plantDescription = "Plant Five"
        plantFive.yearDiscovered = 1993
        
        let plantSix = Plant(context: managedObjectContext)
        plantSix.family = "Family Six"
        plantSix.id = UUID()
        plantSix.imageUrl = "image url"
        plantSix.name = "Plant Six"
        plantSix.scientificName = "Plant Six"
        plantSix.plantDescription = "Plant Six"
        plantSix.yearDiscovered = 1992
        
        let plantSeven = Plant(context: managedObjectContext)
        plantSeven.family = "Family Seven"
        plantSeven.id = UUID()
        plantSeven.imageUrl = "image url"
        plantSeven.name = "Plant Seven"
        plantSeven.scientificName = "Plant Seven"
        plantSeven.plantDescription = "Plant seven"
        plantSeven.yearDiscovered = 1992
        
        let plantEight = Plant(context: managedObjectContext)
        plantEight.family = "Family Seven"
        plantEight.id = UUID()
        plantEight.imageUrl = "image url"
        plantEight.name = "Plant Seven"
        plantEight.scientificName = "Plant Seven"
        plantEight.plantDescription = "Plant seven"
        plantEight.yearDiscovered = 1992
        
        let plantNine = Plant(context: managedObjectContext)
        plantNine.family = "Family Nine"
        plantNine.id = UUID()
        plantNine.imageUrl = "image url"
        plantNine.name = "Plant Nine"
        plantNine.scientificName = "Plant Nine"
        plantNine.plantDescription = "Plant Nine"
        plantNine.yearDiscovered = 1991
        
        let plantTen = Plant(context: managedObjectContext)
        plantTen.family = "Family Ten"
        plantTen.id = UUID()
        plantTen.imageUrl = "image url"
        plantTen.name = "Plant Ten"
        plantTen.scientificName = "Plant Ten"
        plantTen.plantDescription = "Plant Ten"
        plantTen.yearDiscovered = 1991
        
        
        let exhibitionOne = Exhibition(context: managedObjectContext)
        exhibitionOne.exhibitionDescription = "Exhibition One"
        exhibitionOne.id = UUID()
        exhibitionOne.lat = -37.830043
        exhibitionOne.lon = 144.979198
        exhibitionOne.name = "Exhibition One"
        exhibitionOne.plants = NSSet.init(array: [plantOne, plantTwo])
        
        let exhibitionTwo = Exhibition(context: managedObjectContext)
        exhibitionTwo.exhibitionDescription = "Exhibition Two"
        exhibitionTwo.id = UUID()
        exhibitionTwo.lat = -37.830130
        exhibitionTwo.lon = 144.979474
        exhibitionTwo.name = "Exhibition Two"
        exhibitionTwo.plants = NSSet.init(array: [plantThree, plantFour])
        
        let exhibitionThree = Exhibition(context: managedObjectContext)
        exhibitionThree.exhibitionDescription = "Exhibition Three"
        exhibitionThree.id = UUID()
        exhibitionThree.lat = -37.830231
        exhibitionThree.lon = 144.979269
        exhibitionThree.name = "Exhibition Three"
        exhibitionThree.plants = NSSet.init(array: [plantFive, plantSix])
        
        let exhibitionFour = Exhibition(context: managedObjectContext)
        exhibitionFour.exhibitionDescription = "Exhibition Four"
        exhibitionFour.id = UUID()
        exhibitionFour.lat = -37.830342
        exhibitionFour.lon = 144.979845
        exhibitionFour.name = "Exhibition Four"
        exhibitionFour.plants = NSSet.init(array: [plantSeven, plantEight])
        
        let exhibitionFive = Exhibition(context: managedObjectContext)
        exhibitionFive.exhibitionDescription = "Exhibition Five"
        exhibitionFive.id = UUID()
        exhibitionFive.lat = -37.830471
        exhibitionFive.lon = 144.979659
        exhibitionFive.name = "Exhibition Five"
        exhibitionFive.plants = NSSet.init(array: [plantNine, plantTen])
        
        
        do{
            try managedObjectContext.save()
            print("Data Created")
        } catch let error as NSError{
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
}
