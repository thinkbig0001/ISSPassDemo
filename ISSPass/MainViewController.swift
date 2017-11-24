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
fileprivate let headerIdentifier = "ISSHeader"

class MainViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var lblNumPasses: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var lblUserLocation: UILabel!
    @IBOutlet weak var btnClear: UIButton!
    
    var location: CLLocationCoordinate2D?       //To save user's current GPS location
    var locationManager = CLLocationManager()    //Use LocationManager class to get location
    var toggleSecsToHour: Bool = false          //A switch to toggle duration display between seconds & hour format
    
    //MARK: Action Methods
    @IBAction func refreshData(_ sender: UIButton) {
       
        //Call RefreshData method to load the table again
        RefreshData()
    }
    
    @IBAction func setPasses(_ sender: UIStepper) {
        //Set the value in lblNumPasses textField
        lblNumPasses?.text = "Display \(Int(sender.value)) records"
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
        
        //Register reusable cell classes for cells and header
        //tableView.register(ISSTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        //tableView.register(ISSHeaderView.self, forCellReuseIdentifier: headerIdentifier)
        
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
        // Comment out the next line before running XCUITest, otherwise app never seem to idle.
        tableView.refreshControl = UIRefreshControl()
        
        //Set border for Refresh button, text color etc.
        btnRefresh.backgroundColor = UIColor.black
        btnRefresh.layer.cornerRadius = 15.0
        btnRefresh.layer.borderColor = UIColor.blue.cgColor
        btnRefresh.layer.borderWidth = 2.0
        btnRefresh.layer.shadowOffset = CGSize(width: 5, height: 5)
        btnRefresh.layer.shadowRadius = 3.0
        btnRefresh.layer.shadowOpacity = 0.6
        btnRefresh.setTitleColor(UIColor.white, for: .normal)
        
        //Set initial value in lblNumPasses textField
        lblNumPasses?.text = "Display 5 records"
        
        //Set stepper control's min, max and increment values
        stepper.minimumValue = 1
        stepper.maximumValue = 100
        stepper.stepValue = 1
        stepper.value = 5
        stepper.isContinuous = true
        
        //Hide user location label till data is available
        lblUserLocation.isHidden = true
        
        //Add a Tap Gesture Recognizer to toggle the Duration value from sec to h.m.s format
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleValues)))
        
        //Dynamically add a target function for clear button, without going through storyboard
        btnClear.addTarget(self, action: #selector(clearTable), for: .touchUpInside)

    }
    
    @objc private func clearTable(_ sender: UIButton) {
        //Clear the dataModel and reload the tableView.
        dataModel.removeAll()
        tableView.reloadData()
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
            lblUserLocation.isHidden = false
            let numFormatter = NumberFormatter()
            numFormatter.maximumFractionDigits = 2
            let lat = numFormatter.string(from: NSNumber(value: loc.latitude))
            let lon = numFormatter.string(from: NSNumber(value: loc.longitude))
            
            lblUserLocation?.text = "Your Location: Lat: \(lat!), Long: \(lon!)"
        } else {
            lblUserLocation.isHidden = true
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ISSTableViewCell
        
        //Configure the cell layout and look & feel
        cell.lblDuration.layer.cornerRadius = 3.0
        
        //Format the date with DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MMM dd, YYYY hh:mm"
        
        let dateStr = dateFormatter.string(from: dataModel[indexPath.row].risetime!)
        cell.lblRiseDateTime?.text = dateStr
        
        let duration = Int(dataModel[indexPath.row].duration!)
        if !toggleSecsToHour { //Keep display in secs
            cell.lblDuration?.text = getDurationString(isFormatInSec: true, value: duration)
        } else { //Convert secs to hour/min/sec and display
            cell.lblDuration?.text = getDurationString(isFormatInSec: false, value: duration)
        }
        
        return cell
    }
    
    //Toggle values for duration between secs and hh:mm:ss format
    @objc func toggleValues(_ sender: UITapGestureRecognizer) {
        //We will change the seconds into hours & mins & secs and vice-versa for all rows
        toggleSecsToHour = !toggleSecsToHour
        tableView.reloadData()
    }
    
    //Setup a custom headerview
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 32))
        
        //Set background color based on current date's month
        headerView.backgroundColor = monthColor(Date())
        headerView.layer.borderColor = UIColor.darkGray.cgColor
        headerView.layer.borderWidth = 1.0;

        //Add two labels Date-Time and Duration
        let dateLabel = UILabel(frame: CGRect(x: 16, y: 4, width: 120, height: 24))
        let durationLabel = UILabel(frame: CGRect(x: tableView.frame.maxX - 160, y: 4, width: 120, height: 24))
        
        dateLabel.text = "Date-Time"
        dateLabel.textColor = UIColor.white
        dateLabel.textAlignment = NSTextAlignment.center
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        
        durationLabel.text = "Duration"
        durationLabel.textColor = UIColor.white
        durationLabel.textAlignment = NSTextAlignment.center
        durationLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)

        headerView.addSubview(dateLabel)
        headerView.addSubview(durationLabel)

        return headerView
    }
    
    //Enable swipe delete a row in table
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            dataModel.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
}
