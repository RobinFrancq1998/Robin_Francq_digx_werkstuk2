//
//  myAnnotation.swift
//  Robin_Francq_digx_werkstuk2
//
//  Created by Robin Francq on 2/06/18.
//  Copyright © 2018 Robin Francq. All rights reserved.
//  Dit is de klasse dat de inhoud van de annotatie bepaald

import Foundation
import MapKit

class MyAnnotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title:String?, subtitle:String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
