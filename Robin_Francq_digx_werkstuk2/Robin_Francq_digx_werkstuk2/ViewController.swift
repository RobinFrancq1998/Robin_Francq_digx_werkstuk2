//
//  ViewController.swift
//  Robin_Francq_digx_werkstuk2
//
//  Created by Robin Francq on 29/05/18.
//  Copyright © 2018 Robin Francq. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    var allNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updateCoreData(theURL: "https://api.jcdecaux.com/vls/v1/stations?apiKey=6d5071ed0d0b3b68462ad73df43fd9e5479b03d6&contract=Bruxelles-Capitale")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // BRON: https://www.youtube.com/watch?v=XqNvHHAi08s
    func parseURL(theURL:String) {
        let url = URL(string: theURL)
        URLSession.shared.dataTask(with: url!){(data, response, error) in
            if error != nil {
                print ("didn't work, \(String(describing: error))")
                
                DispatchQueue.main.asyncAfter(deadline: .now() ){
                    // ...
                }
            } else{
                do{
                    let parsedData = try JSONSerialization.jsonObject(with: data!) as! [[String:Any]]
                    
                    // print alle data
                    //print(parsedData)
                    
                    for stand in parsedData{
                        for (key, value) in stand{
                            print(key, "=", value)
                        }
                    }
                    
                } catch let error as NSError{
                    print(error)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        // ...
                    }
                }
            }
        }.resume()
    }
    
    func updateCoreData(theURL:String){
        
        // Aanmaken van managed object model voor het uitvoeren van CRUD toepassingen
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let url = URL(string: theURL)
        URLSession.shared.dataTask(with: url!){(data, response, error) in
            if error != nil {
                print ("didn't work, \(String(describing: error))")
                
                DispatchQueue.main.asyncAfter(deadline: .now() ){
                    // ...
                }
            } else{
                do{
                    let parsedData = try JSONSerialization.jsonObject(with: data!) as! [[String:Any]]
                    
                    // print alle data
                    //print(parsedData)

                    // position, status, name, last_update, bonus, bike_stands, available_bike_stands, address, available_bikes, number, contract_name
                    
                    for stands in parsedData{
                        for stand in stands{
                            
                            // userEntity = managed object
                            let villoEntity = NSEntityDescription.entity(forEntityName: "VilloStand", in: managedContext)!
                            
                            // Aanmaken van een ViloStand
                            let villoStand = NSManagedObject(entity: villoEntity, insertInto: managedContext)
                            
                            if(stand.key == "position"){
                                
                                // weet ik nog niet...
                                
                            }
                            else{
                                villoStand.setValue(stand.value, forKey: stand.key)
                            }
                        }
                    }
                    
                    do {
                        try managedContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                    
                    let userFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "VilloStand")
                    
                    let villoStands = try! managedContext.fetch(userFetch)
                    
                    let stand1: VilloStand = villoStands.first as! VilloStand
                    
                    print (stand1.address ?? "no address")
                    
                } catch let error as NSError{
                    print(error)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        // ...
                    }
                }
            }
        }.resume()
    }
}

