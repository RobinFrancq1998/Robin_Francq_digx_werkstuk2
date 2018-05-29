//
//  ViewController.swift
//  WebServiceTest
//
//  Created by Robin Francq on 29/05/18.
//  Copyright © 2018 Robin Francq. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        parseURL(theURL: "https://api.jcdecaux.com/vls/v1/stations?apiKey=6d5071ed0d0b3b68462ad73df43fd9e5479b03d6&contract=Bruxelles-Capitale")
        
        
        /*
        // Initialisatie van de URL
        let url = URL(string: "https://api.jcdecaux.com/vls/v1/stations?apiKey=6d5071ed0d0b3b68462ad73df43fd9e5479b03d6&contract=Bruxelles-Capitale")
        let urlRequest = URLRequest(url: url!)
        
        // Setup van de session
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        // Request maken
        let task = session.dataTask(with: urlRequest) {
            (data, reponse, error) in
            // check for errors
            guard error == nil else {
                print ("error calling GET")
                print (error!)
                return
            }
            // Make sure we got data
            guard let reponseData = data else {
                print ("Error: did not recieve data")
                return
            }
            
            do{
                let json = try JSONSerialization.jsonObject(with: reponseData, options: [])as? [String: AnyObject]
                print(json)
            } catch let error as NSError{
                print ("Error while feshing ", error)
            }
        }
        task.resume()
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func parseURL(theURL:String){
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
                    
                    print(parsedData)
                    
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

