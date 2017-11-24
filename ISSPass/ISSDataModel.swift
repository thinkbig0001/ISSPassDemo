//
//  ISSDataModel.swift
//  ISSPass
//
//  Created by TAPAN BISWAS on 11/21/17.
//  Copyright © 2017 TAPAN BISWAS. All rights reserved.
//


import Foundation
import Alamofire        //Install Cocoapod Alamofire before using it here. Use for Networking
import SwiftyJSON       //Install Cocoapod SwiftyJSON before using it here. Use for JSON Parsing

//Constants Defined for the app
let ISSURL = "http://api.open-notify.org/iss-pass.json"

//API call is in the format http://api.open-notify.org/iss-pass.json?lat=LAT&lon=LON&n=5&callback=?

//For URL Request we need to send the following
struct reqParams {       //Request Parameters
    var latitude : String       //Latitude  - required
    var longitude: String       //Longitude - required
    var altitude : String = ""  //Altitude  - optional
    var passes : Int = 10       //Passes    - optional (default to 10)
    
    init() {
        self.latitude = ""
        self.longitude = ""
    }
    
    init(latitude: String, longitude: String) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

struct record {      //Results received has two elements
    var risetime : Date?    //Swift Date - we will convert JSON data in this format
    var duration : Double?  //In seconds
    
    public init() { }               //Required for instantiating empty struct
        
    public init(rise: Date, dur: Double) { //We may need this to create and assign value.
        risetime = rise
        duration = dur
    }
}


func initiateDataLoadRequest(params: reqParams) {
    
//    dataModel.removeAll()
//    dataModel = loadDummyData()
//    return
    
    //convert passed parameters into a string - ensure required parameters are present
    //if time permits ensure it's in correct format
    guard !(params.latitude.isEmpty) && !(params.longitude.isEmpty) else {
        return //later implement error messaging
    }
    var urlParams = "?lat=\(params.latitude)&lon=\(params.longitude)"
    if params.passes > 0 {
        urlParams += "&n=\(params.passes)"
    }
    
    //Add parameters to the URL
    let url = ISSURL + urlParams
    
    //Use Alamofire to make the URL request. Automatically validate response 200..<300 type
    Alamofire.request(url).validate().responseJSON { (response) -> Void in
        switch response.result {
        case .success:
            //debugPrint("Validation Successful")
            break
        case .failure(let error):
            //time permits - do better error handling and user messaging
            let errMsg = "Oops! Something went wrong with ISS sending us data\n"
            debugPrint(error)
            showAlert(alertmsg: errMsg)
        }
        
        //clearout the dataModel
        dataModel.removeAll()

        //Parse JSON into our dataModel
        dataModel = parseJSON(data: response.result.value)
        
        //Sort the data received in ascending order
        dataModel.sort(by: { (a, b) -> Bool in
            a.risetime! < b.risetime!
        })
        
        //Notify that data has been loaded
        let nc = NotificationCenter.default
        nc.post(name:myNotification,
                object: nil,
                userInfo:["message":"data loaded", "date":Date()])
    }
}

func parseJSON(data: Any?) -> [record] {
    
    var model = [record]()
    
    //Check if the result has the value
    if let value = data {
        //if so, convert into JSON format
        let json = JSON(value)
        
        //debugPrint(json)
        
         //parse json into model
        let arr = json["response"]
        arr.forEach({ (key, value) in
            var thisRec = record()
            
            //debugPrint(rec.0, rec.1["duration"], rec.1["risetime"])
            
            //Ensure we can parse each value
            if let val = value["risetime"].double {
                //Convert into swift Date.
                thisRec.risetime = Date(timeIntervalSince1970: val)
            }
            if let val = value["duration"].double {
                thisRec.duration = val
            }
            //Add this record in our data model
            model.append(thisRec)
        })
     }
    
    //return our data
    return model

}

func loadDummyData() -> [record] {
    var model = [record]()
    
    let rec = record(rise: Date(),dur: 3747)
    model.append(rec)
    
    //Notify that data has been loaded
    let nc = NotificationCenter.default
    nc.post(name:myNotification,
            object: nil,
            userInfo:["message":"data loaded", "date":Date()])

    return model
}
