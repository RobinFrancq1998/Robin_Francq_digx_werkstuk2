//
//  ViewController.swift
//  CoreDataTest
//
//  Created by Robin Francq on 29/05/18.
//  Copyright © 2018 Robin Francq. All rights reserved.
//

// Voorbereiding: Aanmaken van entiteiten, attributen en reslaties in CoreDataTest.xcdatamodelid (Users en Cars)

import UIKit
// Importeer CoreData
import CoreData

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Aanmaken van managed object model voor het uitvoeren van CRUD toepassingen
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // userEntity = managed object
        let userEntity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)!
        
        // Aanmaken van een User
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        
        // Invullen van attributen van user
        user.setValue("John", forKeyPath: "name")
        user.setValue("john@test.com", forKey: "email")
        
        // (dataformatter)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let date = formatter.date(from: "1990/10/08")
        user.setValue(date, forKey: "date_of_birth")
        
        user.setValue(0, forKey: "number_of_children")
        
        // Aanmen van een Car
        let carEntity = NSEntityDescription.entity(forEntityName: "Car", in: managedContext)!
        
        // Invullen van attributen van car 1
        let car1 = NSManagedObject(entity: carEntity, insertInto: managedContext)
        car1.setValue("Audi TT", forKey: "model")
        car1.setValue(2010, forKey: "year")
        
        // Relatie maken tussen user en car 1
        car1.setValue(user, forKey: "user")
        
        // Invullen van attributen van car 2
        let car2 = NSManagedObject(entity: carEntity, insertInto: managedContext)
        car2.setValue("BMW X6", forKey: "model")
        car2.setValue(2014, forKey: "year")
        
        // Relatie maken tussen user en car 2
        car2.setValue(user, forKey: "user")
        
        // Saven van data naar CoreData + errorHandeling
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        // OP DIT MOMENT ZIJN DE GEGEVENS OPGESLAGEN IN COREDATA !
        
        // Object voor het uitlezen van de data in CoreData
        let userFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        // Request (komt overeen met SQL-statements)
        userFetch.fetchLimit = 1
        userFetch.predicate = NSPredicate(format: "name = %@", "John")
        userFetch.sortDescriptors = [NSSortDescriptor.init(key: "email", ascending: true)]
        
        // Execute van de query
        let users = try! managedContext.fetch(userFetch)
        
        // Resultaat van query toekennen aan object User
        let john: User = users.first as! User
        
        // Print van de resultaten in console
        print("Email: \(john.email!)")
        let johnCars = john.cars?.allObjects as! [Car]
        print("has \(johnCars.count)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

