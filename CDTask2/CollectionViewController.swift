//
//  CollectionViewController.swift
//  CDTask2
//
//  Created by Jon Boling on 5/3/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import CoreData

class CollectionViewController: UICollectionViewController {
    
    var people = [Person]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var managedContext : NSManagedObjectContext?
    var fetchedResultsController: NSFetchedResultsController<Person>?
    var blockOperations: [BlockOperation] = []
    private let cellID = "Cell"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Person>(entityName: CoreDataIDs.Person)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: CoreDataIDs.firstName, ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: CoreDataIDs.personsCache)
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            fatalError("Unable to fetch: \(error)")
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.allowsSelection = true
        
        //setting size of cell
        let width = collectionView!.frame.width
        let height = collectionView!.frame.height / 5
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: height)
        
        //Fetch Data
        managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Person>(entityName: CoreDataIDs.Person)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: CoreDataIDs.firstName, ascending: true), NSSortDescriptor(key: CoreDataIDs.lastName, ascending: true), NSSortDescriptor(key: CoreDataIDs.department, ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext!, sectionNameKeyPath: nil, cacheName: CoreDataIDs.personsCache)
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            fatalError("Unable to fetch: \(error)")
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //this ensures that you actually have set this value and throws an error if you haven't.
        guard let fetchedResultsController = fetchedResultsController else {
            fatalError("Failed to load fetched results controller")
        }
        return (fetchedResultsController.fetchedObjects?.count)!
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let fetchedResultsController = fetchedResultsController else {
            fatalError("Failed to load fetched results controller")
        }
        
        let person = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! DataCell

        var displayName = [person.firstName, person.lastName]
            .compactMap({ $0 }) // Removes the nil strings
            .joined(separator: " ")
        
        // Returns blank if there is no display name
        guard !displayName.isEmpty else {
            cell.personLabel.text = "BLANK"
            return cell
        }
        
        // adds the department if it's not nil only
        if let department = person.department {
            displayName += " in \(department)"
        }
        
        cell.personLabel.text = displayName
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
 
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
    
    //delete on selection
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let fetchedResultsController = fetchedResultsController else {
            fatalError("Failed to load fetched results controller")
        }
        let person = fetchedResultsController.object(at: indexPath)
        fetchedResultsController.managedObjectContext.delete(person)
        
        appDelegate.saveContext()
    }
}

//NSFetchedResultControllerDelegate methods

extension CollectionViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        let op: BlockOperation
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            op = BlockOperation { self.collectionView?.insertItems(at: [newIndexPath]) }
            blockOperations.append(op)
        case .delete:
            guard let indexPath = indexPath else { return }
            op = BlockOperation { self.collectionView?.deleteItems(at: [indexPath]) }
        case .move:
            guard let indexPath = indexPath,  let newIndexPath = newIndexPath else { return }
            op = BlockOperation { self.collectionView?.moveItem(at: indexPath, to: newIndexPath) }
        case .update:
            guard let indexPath = indexPath else { return }
            op = BlockOperation { self.collectionView?.reloadItems(at: [indexPath]) }
        }
    
        blockOperations.append(op)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            self.blockOperations.forEach { $0.start() }
        }, completion: { finished in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
        collectionView?.reloadData()
    }
}
