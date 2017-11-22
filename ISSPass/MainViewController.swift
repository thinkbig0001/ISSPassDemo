//
//  MainViewController.swift
//  ISSPass
//
//  Created by TAPAN BISWAS on 11/21/17.
//  Copyright © 2017 TAPAN BISWAS. All rights reserved.
//


//IMPORTANT - (1) App needs user permission to obtain GPS location.Edit info.plist with following:
//                ADD NSLocationAlwaysAndWhenInUseUsageDescription="msg"
//                ADD NSLocationWhenInUseUsageDescription="msg"
//            (2) Ensure to allow HTTP calls. Edit info.plist with following:
//                ADD App Transport Security Settings (Allow Arbitary Loads = YES)

import UIKit
import CoreLocation

//MARK: Global Variables/Constants

//Declare public var for our DataModel we need to move this into a package later
var dataModel: [record] = [] //blank array to start with
let myNotification = Notification.Name(rawValue:"DataLoaded")
fileprivate let cellIdentifier = "cell"

class MainViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var numPasses: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var userLocation: UILabel!
    
    var location: CLLocationCoordinate2D?       //To save user's current GPS location
    var locationManager = CLLocationManager()    //Use LocationManager class to get location
    
    //MARK: Action Methods
    @IBAction func refreshData(_ sender: UIButton) {
       
        //Call RefreshData method to load the table again
        RefreshData()
    }
    
    @IBAction func setPasses(_ sender: UIStepper) {
        //Set the value in numPasses textField
        numPasses?.text = "Display \(Int(sender.value)) records"
    }

    //MARK: Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Initialize UI Controls
        initializeUI()
        
        //Add Notification Observer to handle data loading completion
        let nc = NotificationCenter.default
        nc.addObserver(forName:myNotification, object:nil, queue:nil, using:dataLoaded)
        
        //Add Target function for tableView's pulldown refresh
        tableView?.refreshControl?.addTarget(self, action: #selector(RefreshData), for: UIControlEvents.valueChanged)
        
        //Set delegates for tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        //Set delegate for LocationManager
        locationManager.delegate = self
        
        //Request User Permission and get user's location
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        //If granted permission and service is enabled
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

    }

    //MARK: Private methods
    private func initializeUI() {
        
        // Add Refresh Control to tableView for pulldown refresh
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl

        //Set border for Refresh button
        refreshButton.layer.cornerRadius = 5.0
        refreshButton.layer.borderColor = UIColor.blue.cgColor
        refreshButton.layer.borderWidth = 2.0
        
        //Set initial value in numPasses textField
        numPasses?.text = "Display 5 records"
        
        //Set stepper control's min, max and increment values
        stepper.minimumValue = 1
        stepper.maximumValue = 100
        stepper.stepValue = 1
        stepper.value = 5
        stepper.isContinuous = true
        
        //Hide user location label till data is available
        userLocation.isHidden = true
    }
    
    private func dataLoaded(notification: Notification) {
        guard let _ = notification.userInfo else {
            debugPrint("No userInfo found in notification")
            return
        }
        
        //verify this the correct notification, before taking action
        if notification.name == myNotification {
            //Stop the the tableView Refresh Control
            tableView?.refreshControl?.endRefreshing()
            
            //Load the tableView now that we have dataModel filled with data
            tableView.reloadData()
         }
        
    }

    @objc private func RefreshData() {
        //Call the data load function in ISSDataModel.swift
        var param = reqParams()
        param.longitude = String(Double((location?.longitude)!))      //"42.35814" - for Boston
        param.latitude = String(Double((location?.latitude)!))       //"71.06074" - for Boston
        param.passes = Int(stepper.value)      //take value from stepper control.
        
        //Start the tableView Refresh Control
        tableView?.refreshControl?.beginRefreshing()
        
        //Initiate data load request. Refresh table when notification arrives.
        initiateDataLoadRequest(params: param)

    }
}

//MARK: Extension to handle LocationManager delegate functions
extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //save the value in MainViewController property
        if let loc = manager.location?.coordinate {
            self.location = loc
            
            //Update location value to show current location
            userLocation.isHidden = false
            let numFormatter = NumberFormatter()
            numFormatter.maximumFractionDigits = 2
            let lat = numFormatter.string(from: NSNumber(value: loc.latitude))
            let lon = numFormatter.string(from: NSNumber(value: loc.longitude))
            
            userLocation?.text = "Current Location: Latitude:\(lat!), Longitude:\(lon!)"
        } else {
            userLocation.isHidden = true
        }
        
    }
}
//MARK: Extension to handle tableView delegate/datasource functions
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    //Necessary functions for basic functionality
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1    //We just have 1 section
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.count  //return number of rows in dataModel
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //We using standard UITableViewCell here, no need recast to custom cell class
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        //Set the values in the cell with data in dataModel
        
        //Format the date with DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MMM dd, YYYY hh:mm"
        
        let dateStr = dateFormatter.string(from: dataModel[indexPath.row].risetime!)
        cell.textLabel?.text = dateStr
        cell.detailTextLabel?.text = "\(dataModel[indexPath.row].duration!) secs"
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Date-Time                                      Duration"
    }
    
    //Enable swipe delete a row in table
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            dataModel.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
}
