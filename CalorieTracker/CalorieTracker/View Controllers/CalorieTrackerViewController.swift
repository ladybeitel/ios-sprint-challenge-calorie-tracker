//
//  CalorieTrackerViewController.swift
//  CalorieTracker
//
//  Created by Ciara Beitel on 10/18/19.
//  Copyright © 2019 Ciara Beitel. All rights reserved.
//

import UIKit
import CoreData

class CalorieTrackerViewController: UIViewController {
    
     // MARK: - Properties
    
    lazy var fetchResultsController: NSFetchedResultsController<Calorie> = {
        
        let fetchRequest: NSFetchRequest<Calorie> = Calorie.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: CoreDataStack.shared.mainContext,
                                             sectionNameKeyPath: "timestamp",
                                             cacheName: nil)
        
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            fatalError("Error performing fetch for frc: \(error)")
        }
        
        return frc
    }()
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: CalorieTrackerTableView!
    
    
    // MARK: - Actions
    
    @IBAction func addCalorieButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add a calorie", message: nil, preferredStyle: .alert)
        var calorieIntakeTextField: UITextField!
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "Calories:"
            calorieIntakeTextField = textfield
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            let intake = calorieIntakeTextField.text ?? "0"
            let intakeInt = Int16(intake)
                        
            let calorie = Calorie(intake: intakeInt ?? 0, context: CoreDataStack.shared.mainContext)
        }
        
        alert.addAction(submitAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

extension CalorieTrackerViewController: UITableViewDelegate {
    
}
            
extension CalorieTrackerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CalorieCell", for: indexPath) as? CalorieTrackerTableViewCell else { return UITableViewCell() }
        
        let calorie = fetchResultsController.object(at: indexPath)
        
        cell.intakeLabel?.text = "Calories: \(calorie.intake)"
        cell.timestampLabel.text = "\(calorie.timestamp)"
        
        return cell
    }
}

extension CalorieTrackerViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        @unknown default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        
        let sectionSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(sectionSet, with: .automatic)
        case .delete:
            tableView.deleteSections(sectionSet, with: .automatic)
        default:
            return
        }
    }
}
