//
//  MapaViewController.swift
//  CoreDataFinal
//
//  Created by Fernando Jt on 15/4/18.
//  Copyright © 2018 Fernando Jumbo Tandazo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class MapaViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapa: MKMapView!
    var manager = CLLocationManager()
    var latitudMapa : CLLocationDegrees!
    var longitudMapa: CLLocationDegrees!
    var coordLugares : Lugares!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        
        latitudMapa = coordLugares.latitud
        longitudMapa = coordLugares.longitud
       
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let localizacion = CLLocationCoordinate2DMake(latitudMapa, longitudMapa)
        let span = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion.init(center: localizacion, span: span)
        self.mapa.setRegion(region, animated: true)
        
        //self.mapa.showsUserLocation = true
        let anotacion = MKPointAnnotation()
        anotacion.coordinate = (localizacion)
        anotacion.title = coordLugares.nombre
        anotacion.subtitle = coordLugares.descripcion
        mapa.addAnnotation(anotacion)
        mapa.selectAnnotation(anotacion, animated: true)
        
    }
   
}
