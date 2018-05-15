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
    private let toCollectionView = "toCollectionView"
    
    @IBAction func saveButtonWasTapped(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: CoreDataIDs.Person, in: context)
        let newPerson = NSManagedObject(entity: entity!, insertInto: context)
        
        newPerson.setValue(firstNameField.text, forKey: CoreDataIDs.firstName)
        newPerson.setValue(lastNameField.text, forKey: CoreDataIDs.lastName)
        if departmentField.text != "" {
        newPerson.setValue(departmentField.text, forKey: CoreDataIDs.department)
        }
        appDelegate.saveContext()
    }
    
    @IBAction func showButtonWasTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: toCollectionView, sender: self)
    }
}

