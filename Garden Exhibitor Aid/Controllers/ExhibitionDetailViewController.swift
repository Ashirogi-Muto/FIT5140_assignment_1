//
//  ExhibitionDetailViewController.swift
//  Garden Exhibitor Aid
//
//  Created by Kshitij Pandey on 07/09/20.
//  Copyright © 2020 Kshitij Pandey. All rights reserved.
//

import UIKit

class ExhibitionDetailViewController: UIViewController {    
    @IBOutlet weak var exhibitImage: UIImageView!
    @IBOutlet weak var exhibitName: UILabel!
    @IBOutlet weak var exhibitDescription: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("VIEW DID LOAD____>>>>")
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("I AM EXHHHHHHHHH")
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
