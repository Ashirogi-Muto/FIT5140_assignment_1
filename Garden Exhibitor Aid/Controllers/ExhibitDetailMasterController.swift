//
//  ExhibitDetailViewMasterController.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 07/09/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import UIKit
import CoreData

class ExhibitDetailMasterController: UIViewController {
    @IBOutlet var container: UIView!
    var selectedExhibitId: UUID? = nil
    var commitPredicate: NSPredicate?
    var spinner = UIActivityIndicatorView(style: .large)
    var exhibit: Exhibition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        spinner.translatesAutoresizingMaskIntoConstraints = false
        //        spinner.startAnimating()
        //        view.addSubview(spinner)
        //        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Exhibition>(entityName: "Exhibition")
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "id", selectedExhibitId! as CVarArg)
        
        do {
            let exhbition = try managedObjectContext.fetch(fetchRequest)
            print(exhbition.count)
            if exhbition.count > 0 {
                exhibit = exhbition[0]
            }
            guard let exhibitDetailView = storyboard?.instantiateViewController(identifier: "exhibitDetailView") as? ExhibitionDetailViewController
                else {
                    return
            }
            let imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 240, height: 128))
            imageView.image = UIImage(named: "plant")
            exhibitDetailView.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            container.addSubview(exhibitDetailView.view)
            exhibitDetailView.didMove(toParent: self)
            exhibitDetailView.exhibitDescription.text = exhibit?.description
            exhibitDetailView.exhibitName.text = exhibit?.name
            exhibitDetailView.exhibitImage = imageView
        } catch let error as NSError {
            print("Error in deleting exhibits \(error.userInfo)")
        }
    }
}
