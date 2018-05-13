//
//  ViewController.swift
//  CDTask2
//
//  Created by Jon Boling on 5/3/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
   
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var departmentField: UITextField!
    
    var people = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func saveButtonWasTapped(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: coreDataLabels.Person, in: context)
        let newPerson = NSManagedObject(entity: entity!, insertInto: context)
        
        newPerson.setValue(firstNameField.text, forKey: coreDataLabels.firstName)
        newPerson.setValue(lastNameField.text, forKey: coreDataLabels.lastName)
        newPerson.setValue(departmentField.text, forKey: coreDataLabels.department)
        
        appDelegate.saveContext()
    }
    
    @IBAction func showButtonWasTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toCollectionView", sender: self)
    }
}

