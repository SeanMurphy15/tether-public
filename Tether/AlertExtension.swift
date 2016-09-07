//
//  AlertExtension.swift
//  Tether
//
//  Created by Sean Murphy on 1/10/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import UIKit


extension MapViewController {

    func mapTypeSelectionAlert(){

        let mapTypeAlert = UIAlertController(title: "Select Map Type", message: "The selected map type does not affect tethered friends.", preferredStyle: .ActionSheet)

        let satilliteMapType =  UIAlertAction(title: "Satillite", style: .Default) { (_) -> Void in

            self.mapView.mapType = .Satellite
        }
        let standardMapType =  UIAlertAction(title: "Standard", style: .Default) { (_) -> Void in

            self.mapView.mapType = .Standard
        }
        let satilliteFlyoverMapType =  UIAlertAction(title: "Satillite Flyover", style: .Default) { (_) -> Void in

            self.mapView.mapType = .SatelliteFlyover
        }
        let hybridMapType =  UIAlertAction(title: "Hybrid", style: .Default) { (_) -> Void in

            self.mapView.mapType = .Hybrid
        }
        let cancelMapType =  UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

        mapTypeAlert.addAction(satilliteMapType)
        mapTypeAlert.addAction(standardMapType)
        mapTypeAlert.addAction(satilliteFlyoverMapType)
        mapTypeAlert.addAction(hybridMapType)
        mapTypeAlert.addAction(cancelMapType)

        presentViewController(mapTypeAlert, animated: true, completion: nil)
    }
}