//
//  MapViewController.swift
//  Tether
//
//  Created by Sean Murphy on 1/4/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import MapKit
import DigitsKit
import Firebase
import Darwin
import StoreKit
import Parse


class MapViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate, RequestReceivedCellDelegate {

    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var mapTypeButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTetherButton: UIBarButtonItem!
    
    var selectedRow: NSIndexPath? = nil

    var arrow: UIImageView? = nil
    var products = [SKProduct]()

    lazy var priceFormatter: NSNumberFormatter = {
        let pf = NSNumberFormatter()
        pf.formatterBehavior = .Behavior10_4
        pf.numberStyle = .CurrencyStyle
        return pf
    }()
    
    enum State {
        case directions
        case userControl
        case zoomedOut
    }

    var state: State = .zoomedOut {
        didSet {
            if state == .directions {
                LocationController.sharedInstance.locationManager.startUpdatingHeading()
            } else {
                LocationController.sharedInstance.locationManager.stopUpdatingHeading()
                if state == .zoomedOut {
                    setArrowtoNorth()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
        AppearanceController.setUpAppearance()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.setRegionForNewTether(_:)), name: "newTetherLocationReceived", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.updateAnnotations), name: "friendLocationChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.updateTableView), name: "userArraysChanged", object: nil)
        tableView.rowHeight = 66
        mapView.delegate = self
        mapView.showsUserLocation = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.updateCameraHeading(_:)), name: "userHeadingChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.setArrowForFriend), name: "userHeadingChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.setArrowForFriend), name: "friendLocationChanged", object: nil)
        self.view.multipleTouchEnabled = true
        checkForProducts()
        LocalNotificationController.sharedInstance.localNotificationSettingAlert()
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            self.navigationController?.performSegueWithIdentifier("toSignUpView", sender: self)
        }
    }

    func checkForProducts() {
        products = []
        TetherProducts.store.requestProductsWithCompletionHandler { (success, products) -> () in
            if success {
                self.products = products
            } else {
                print("There are no products in the store")
            }
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
        if UserController.sharedInstance.currentUser != nil {
            LocationController.shouldPromptForLocationAuthorization { (promptStatus) in
                switch promptStatus {
                case .Continue:
                    break
                case .AuthorizeLocation:
                    LocationController.authorizeLocationUse()
                case .GoToSettings:
                    let alert = UIAlertController(title: "Location use not authorized", message: "Tether doesn't work without access to your location. Please go to your settings and change location access for Tether to \"Always\"", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Go to Settings", style: .Cancel, handler: { (action) -> Void in
                        if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                            UIApplication.sharedApplication().openURL(url)
                        }
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
        if (UserController.sharedInstance.currentUser == nil || CLLocationManager.authorizationStatus() != .AuthorizedAlways) && self.presentedViewController != nil {
            self.navigationController?.performSegueWithIdentifier("toSignUpView", sender: self)
        } else {
            setZoomedOutView()
        }
        if state == .directions {
            LocationController.sharedInstance.locationManager.startUpdatingHeading()
        } else {
            LocationController.sharedInstance.locationManager.stopUpdatingHeading()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateCameraHeading(notification: NSNotification) {
        guard state == .directions else {return}
        if let userInfo = notification.userInfo,
            heading = userInfo["heading"] as? CLLocationDirection {
                let camera = mapView.camera
                camera.heading = heading
                mapView.setCamera(camera, animated: true)
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            selectedRow = indexPath
            setZoomedInView(UserController.sharedInstance.tethered[indexPath.row].friend)
            tableView.deselectRowAtIndexPath(indexPath, animated:true)
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    func updateTableView() {
        tableView.reloadData()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return UserController.sharedInstance.requestsReceived.count
        case 1:
            return UserController.sharedInstance.requestsSent.count
        case 2:
            return UserController.sharedInstance.tethered.count
        default:
            return 0
        }
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell = UITableViewCell()

        switch indexPath.section {
        case 0:
            if let sentCell = tableView.dequeueReusableCellWithIdentifier("RequestsReceivedCell", forIndexPath: indexPath) as? RequestsReceivedCell {
                let friend = UserController.sharedInstance.requestsReceived[indexPath.row]
                sentCell.updateWithFriend(friend)
                sentCell.delegate = self
                cell = sentCell
            }
        case 1:
            if let requestCell = tableView.dequeueReusableCellWithIdentifier("RequestSentCell", forIndexPath: indexPath) as? RequestSentCell {
                let friend = UserController.sharedInstance.requestsSent[indexPath.row]
                requestCell.updateWithFriend(friend)
                cell = requestCell
            }
        case 2:
            if let tetherCell = tableView.dequeueReusableCellWithIdentifier("TetherCell", forIndexPath: indexPath) as? TetherCell {
                let tether = UserController.sharedInstance.tethered[indexPath.row]
                tetherCell.updateWithTether(tether)
                cell = tetherCell
            }
        default:
            break
        }
        return cell
    }

    @IBAction func addNewTetherTapped(sender: AnyObject) {
        checkOrPromptForContactUse { (carryOn) -> Void in
            if carryOn {
                self.performSegueWithIdentifier("toContactTableView", sender: nil)
            }
        }
    }
    
    func checkOrPromptForContactUse(completion: (carryOn: Bool)->Void) {
        ContactController.shouldPromptForContactAuthorization({ (promptStatus) -> Void in
            switch promptStatus {
            case .Continue:
                completion(carryOn: true)
            case .RequestAuthorization:
                ContactController.requestAuthorization({ (success) -> Void in
                    if success {
                        completion(carryOn: true)
                    } else {
                        completion(carryOn: false)
                    }
                })
            case .GoToSettings:
                let alert = UIAlertController(title: "Contact use not authorized", message: "If we can't access your contacts, you can't tether with anyone...so please allow access in your settings unless you only want to see yourself on the map.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
                alert.addAction(UIAlertAction(title: "Go to Settings", style: .Cancel, handler: { (action) -> Void in
                    if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                completion(carryOn: false)
            }
        })
    }

    func setRegionForNewTether(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            location = userInfo["location"] as? CLLocation,
            number = userInfo["friendNumber"] as? String,
            numberHandle = UserController.sharedInstance.newTetherHandles[number],
            userLocation = mapView.userLocation.location {
                FirebaseController.base.childByAppendingPath("locations/\(number)").removeObserverWithHandle(numberHandle)
                UserController.sharedInstance.newTetherHandles.removeValueForKey(number)
                var distance = location.distanceFromLocation(userLocation)
                for tether in UserController.sharedInstance.tethered {
                    if let tetherLocation = tether.friend.location {
                        if tetherLocation.distanceFromLocation(userLocation) > distance {
                            distance = tetherLocation.distanceFromLocation(userLocation)
                        }
                    }
                }
                let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, distance*2.5, distance*2.5)

                mapView.setRegion(region, animated: true)
        }
    }

    func setZoomedOutView() {
        var distance: CLLocationDistance = 100
        if let userLocation = mapView.userLocation.location {
            for tether in UserController.sharedInstance.tethered {
                if let tetherLocation = tether.friend.location {
                    if tetherLocation.distanceFromLocation(userLocation) > distance {
                        distance = tetherLocation.distanceFromLocation(userLocation)
                    }
                }
            }
            if distance != 0 {
                let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, distance*2.5, distance*2.5)
                mapView.setRegion(region, animated: true)
            }
            mapView.userTrackingMode = .None
            LocationController.sharedInstance.locationManager.stopUpdatingHeading()
            state = .zoomedOut
        }
    }

    func setZoomedInView(friend: Friend) {
        if let userLocation = mapView.userLocation.location,
            friendLocation = friend.location {
                let distance = friendLocation.distanceFromLocation(userLocation)
                let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, distance*2.5, distance*2.5)
                mapView.setRegion(region, animated: true)
                state = .directions
        }
    }

    @IBAction func mapTypeButtonTapped(sender: AnyObject) {
        if mapView.mapType == MKMapType.Standard {
            mapView.mapType = MKMapType.Satellite
            mapTypeButton.image = UIImage(named: "Map")
        } else {
            mapView.mapType = MKMapType.Standard
            mapTypeButton.image = UIImage(named: "Satellite")
        }
    }

    @IBAction func zoomOutButtonTapped(sender: AnyObject) {
        setZoomedOutView()
        mapView.userTrackingMode = .None
    }

    func annotationTapped() {
        if let _ = mapView.selectedAnnotations.first as? TetherAnnotation {
            performSegueWithIdentifier("toCompassView", sender: self)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toCompassView" {
            if let compassViewController = segue.destinationViewController as? CompassViewController,
                annotation = mapView.selectedAnnotations.first as? TetherAnnotation {
                    compassViewController.tether = annotation.tether
            }
        }
    }
    func didBuyTethers(collectionIndex: Int) {
        if collectionIndex == 0 {
            //how to trigger the firebase tether change
        }
    }

    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if state == .zoomedOut {
            setZoomedOutView()
        }
        setArrowForFriend()
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        state = .userControl
    }

    func setArrowtoNorth() {
        if let userView = mapView.viewForAnnotation(mapView.userLocation) {
            userView.transform = CGAffineTransformMakeRotation(0)
        }
    }

    func setArrowForFriend() {
        guard let indexPath = selectedRow,
            cell = tableView.cellForRowAtIndexPath(indexPath) as? TetherCell,
            friend = cell.tether?.friend else {return}
        guard state == .directions else {return}
        let friendAnnotations = mapView.annotations.filter({$0 is TetherAnnotation}) as! [TetherAnnotation]
        if let friendAnnotation = friendAnnotations.filter({$0.tether.friend.number == friend.number}).first,
            userAnnotation = mapView.annotations.filter({$0 is MKUserLocation}).first,
            friendView = mapView.viewForAnnotation(friendAnnotation),
            userView = mapView.viewForAnnotation(userAnnotation) {
                let friendOrigin = friendView.frame.origin
                let friendWidth = friendView.frame.width
                let friendHeight = friendView.frame.height
                let friendPoint = CGPoint(x: friendOrigin.x + friendWidth/2, y: friendOrigin.y + friendHeight/2)

                let userOrigin = userView.frame.origin
                let userWidth = userView.frame.width
                let userHeight = userView.frame.height
                let userPoint = CGPoint(x: userOrigin.x + userWidth/2, y: userOrigin.y + userHeight/2)

                let x = userPoint.x - friendPoint.x
                let y = userPoint.y - friendPoint.y

                let angleOffsetInDegrees = (atan2(x, y) * CGFloat(180.0/M_PI))>0 ? (atan2(x, y) * CGFloat(180.0/M_PI)):(atan2(x, y) * CGFloat(180.0/M_PI))+360
                let angleOffsetInRadians = LocationController.sharedInstance.degreesToRadians(Double(angleOffsetInDegrees))

                userView.transform = CGAffineTransformMakeRotation(CGFloat(-angleOffsetInRadians))
        }
    }
    func showActions() {
        if let product = products.first {
            if TetherProducts.store.isProductPurchased(product.productIdentifier) {
                let alreadyPurchasedAlert = UIAlertController(title: "Previously Purchased Premium Package", message: "", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alreadyPurchasedAlert.addAction(okAction)
                presentViewController(alreadyPurchasedAlert, animated: true, completion: nil)
                
            } else if let price = priceFormatter.stringFromNumber(product.price){
                priceFormatter.locale = product.priceLocale
                let alert = UIAlertController(title: "Purchase Premium...\(price)", message: "You cannot have more than one Tether or outstanding Tether Request unless you upgrade.", preferredStyle: .Alert)
                let buyAction = UIAlertAction(title: "Buy", style: .Cancel) { (action) -> Void in
                    let payment = SKPayment(product: product)
                    SKPaymentQueue.defaultQueue().addPayment(payment)
                }
                let cancelAction = UIAlertAction(title: "Stick with one Tether", style: .Default) { (action) -> Void in
                }
                alert.addAction(buyAction)
                alert.addAction(cancelAction)

                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func acceptTether(friend: Friend) {
        if (UserController.sharedInstance.tethered.count > 0 || UserController.sharedInstance.requestsSent.count > 0) && !TetherProducts.store.isProductPurchased(products.first!.productIdentifier) {
            showActions()
        } else {
            TetherController.acceptRequest(friend, completion: { (success) -> Void in
                if success {
                    print("Successfully accepted request")
                }
            })
        }
    }

}












