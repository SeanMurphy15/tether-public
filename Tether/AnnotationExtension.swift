//
//  AnnotationExtension.swift
//  Tether
//
//  Created by Sean Murphy on 1/10/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import MapKit


extension MapViewController{

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) {

                let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userAnnotation")
                annotationView.image = UIImage(named: "arrow")
            annotationView.frame.size = CGSizeMake(50, 50)
                return annotationView

        }
        
        guard let annotation = annotation as? TetherAnnotation else {return nil}
        let calloutButton = UIButton(type: .DetailDisclosure)
        calloutButton.addTarget(self, action: #selector(MapViewController.annotationTapped), forControlEvents: .TouchUpInside)
        calloutButton.setImage(UIImage(named:"forward-button"), forState: .Normal)
        calloutButton.tintColor = UIColor.turquoiseColor()
        let annotationView = TetherAnnotationView(annotation: annotation)
        annotationView.rightCalloutAccessoryView = calloutButton
        annotationView.centerOffset = CGPoint(x: 0, y: -25)
        return annotationView
    }


    func updateAnnotations(){

        var annotationArray: [MKAnnotation] = []

        for tether in UserController.sharedInstance.tethered {

            let annotation = TetherAnnotation(tether: tether)

            annotationArray.append(annotation)

        }

        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotationArray)
        
    }

    func scaleAnnotationImage(image image: UIImage) -> UIImage{


        let scaledSize: CGSize = CGSize(width: 50, height: 50)
            let rect = CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height)
                UIGraphicsBeginImageContextWithOptions(scaledSize, false, 1.0)
                    image.drawInRect(rect)
                let newImageSize = UIGraphicsGetImageFromCurrentImageContext()

            UIGraphicsEndImageContext()

        return newImageSize
    }

    
    
    
}