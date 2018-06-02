//
//  ViewController.swift
//  Robin_Francq_digx_werkstuk2
//
//  Created by Robin Francq on 1/06/18.
//  Copyright © 2018 Robin Francq. All rights reserved.
//  Deze app is beschikbaar in het Engels en Nederlands

import UIKit
import CoreData
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var lastUpdate: UILabel!
    @IBOutlet weak var refresh: UIButton!
    @IBAction func refreshClick(_ sender: Any) {
        getDataWith { (result) in
            switch result {
            case .Success(let data):
                print(data)
            case .Error(let message):
                DispatchQueue.main.async {
                    self.showAlertWith(title: "Error", message: message)
                }
            }
        }
    }
    @IBOutlet weak var updateTime: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    var villoStands = Array<NSManagedObject>()
    lazy var endPoint: String = {
        return "https://api.jcdecaux.com/vls/v1/stations?contract=Bruxelles-Capitale&apiKey=0f6eeb84f56a0ec96b79278e957afed918b2d6db"
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.lastUpdate.text = NSLocalizedString("LaatsteUpdateLabel", comment: "Laatste update label")
        self.refresh.setTitle(NSLocalizedString("RefreshButton", comment: "Refresh button"), for: .normal)
        
        locationManager.requestAlwaysAuthorization()
        
        locationManager.startUpdatingLocation()
        
        getDataWith { (result) in
            switch result {
            case .Success(let data):
                print(data)
            case .Error(let message):
                DispatchQueue.main.async {
                    self.showAlertWith(title: "Error", message: message)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    // Omvormen van default annotation naar een pin annotation (om extra info bij een VilloStand te kunnen weergeven)
    internal func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pin.canShowCallout = true
        return pin
    }
    
    // Het opvullen van de mapView met de VilloStands
    private func fillMapWithVilloStands(){
        for villoStand in self.villoStands {
            let location = CLLocationCoordinate2D(latitude: villoStand.value(forKey: "lat") as! CLLocationDegrees, longitude: villoStand.value(forKey: "lng") as! CLLocationDegrees)
            
            let name = villoStand.value(forKey: "name") as! String
            let status = villoStand.value(forKey: "status") as! String
            let available_bike_stands = String(villoStand.value(forKey: "available_bike_stands") as! Int)
            let bikes = String(villoStand.value(forKey: "available_bikes") as! Int)
            
            let myTitle = name
            let mySubtitle =  status + " | BIKES: " + bikes + " | STANDS: " + available_bike_stands
            
            let annotation = MyAnnotation(coordinate: location, title: myTitle, subtitle: mySubtitle)
            
            self.mapView.addAnnotation(annotation)
        }
    }

    // Het binnentrekken van data van de Villo API en persisteren naar Core Data
    // BRON: https://medium.com/@jamesrochabrun/parsing-json-response-and-save-it-in-coredata-step-by-step-fb58fc6ce16f
    func getDataWith(completion: @escaping (Result<[[String: AnyObject]]>) -> Void) {
        
        guard let url = URL(string: endPoint) else {
            return completion(.Error("Invalid URL, we can't update your feed"))
        }
        
        mapView.removeAnnotations(mapView.annotations)
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                return completion(.Error(error!.localizedDescription))
            }
            guard let data = data else {
                return completion(.Error(error?.localizedDescription ?? "There are no new Items to show"))
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [[String: AnyObject]] {
                    
                    let itemsJsonArray = json
                    
                    DispatchQueue.main.async {
                        
                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                        
                        let managedContext = appDelegate.persistentContainer.viewContext
                        
                        for items in itemsJsonArray {
                            
                            let villoStandEntity = NSEntityDescription.entity(forEntityName: "VilloStand", in: managedContext)!
                            
                            let villoStand = NSManagedObject(entity: villoStandEntity, insertInto: managedContext)
                            
                            for (key, value) in items{
                                if (key == "position"){
                                    let value2 = value as! [String: Any]
                                    for (key, value) in value2 {
                                        villoStand.setValue(value, forKeyPath: key)
                                    }
                                }
                                else {
                                    villoStand.setValue(value, forKeyPath: key)
                                }
                            }
                            
                            self.villoStands.append(villoStand)
                            
                            do {
                                try managedContext.save()
                            } catch let error as NSError {
                                print("Could not save. \(error), \(error.userInfo)")
                            }
                        }
                        self.getDateTime()
                        self.fillMapWithVilloStands()
                    }
                }
            } catch let error {
                return completion(.Error(error.localizedDescription))
            }
        }.resume()
    }
    
    // Opgevangen Errors kunnen worden weergegeven aan de gebruiker in de vorm van een foutmelding (zodat de gebruiker verwittigd wordt indien er een probleem is met bijvoorbeeld de Villo API)
    enum Result <T>{
        case Success(T)
        case Error(String)
    }
    
    // Het tonen van de allert aan de gebruiker indien er iets mis is gegaan
    func showAlertWith(title: String, message: String, style: UIAlertControllerStyle = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: title, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Het ophalen van de huidige datum met tijd
    // BRON: https://stackoverflow.com/questions/39513258/get-current-date-in-swift-3
    func getDateTime(){
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd/MM/yyyy hh:mm:ss"
        self.updateTime.text = formatter.string(from: date)
    }
}

