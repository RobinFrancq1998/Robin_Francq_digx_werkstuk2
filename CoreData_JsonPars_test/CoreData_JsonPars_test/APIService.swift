//
//  APIService.swift
//  CoreData_JsonPars_test
//
//  Created by Robin Francq on 29/05/18.
//  Copyright © 2018 Robin Francq. All rights reserved.
//

import Foundation

class APIService: NSObject {
    let query = "dogs"
    lazy var endPoint: String = { return "https://api.flickr.com/services/feeds/photos_public.gne?format=json&tags=\(self.query)&nojsoncallback=1#" }()
}
