//
//  MapViewController.swift
//  FoodPin
//
//  Created by Phoenix Wu on H29/10/03.
//  Copyright © 平成29年 Phoenix Wu. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var restaurant: RestaurantMO!
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        
        if annotation.isKind(of: MKUserLocation.self) {
            // 有可能是抓到 user 當下的位置，這個時候就忽略掉
            return nil
        } else {
            var annotationView: MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            }
            
            if let imgData = restaurant.image {
                let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 53, height: 53))
                leftIconView.image = UIImage(data: imgData)
                annotationView?.leftCalloutAccessoryView = leftIconView
            }
            
            return annotationView
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        mapView.showsTraffic = true
        mapView.delegate = self

        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(restaurant.location!, completionHandler: {
            placemarks, error in
            
            if error != nil {
                print(error!)
            } else if let marks = placemarks {
                let mark = marks[0]
                
                let annotation = MKPointAnnotation()
                annotation.title = self.restaurant!.name
                annotation.subtitle = self.restaurant!.type
                
                if let location = mark.location {
                    annotation.coordinate = location.coordinate
                    
                    self.mapView.showAnnotations([annotation], animated: true)
                    self.mapView.selectAnnotation(annotation, animated: true)
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
