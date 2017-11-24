//
//  UtilityFunctions.swift
//  ISSPass
//
//  Created by TAPAN BISWAS on 11/21/17.
//  Copyright © 2017 TAPAN BISWAS. All rights reserved.
//

import Foundation
import UIKit

func showAlert(alertmsg: String) {
    //Get topmost presentation controller and present the alert
    let alert = UIAlertController(title: "Alert", message:alertmsg, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))

    if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        // topController should now be the topmost view controller
        topController.present(alert, animated: true, completion: nil)
    }
}

func getDurationString(isFormatInSec: Bool, value: Int) -> String {
    //Check for negative values, before conversion
    guard value > 0 else { return "" }

    if isFormatInSec { //return values in seconds
        let str = "\(value) secs"
        return str
    } else { //return value in h m s format
        let hour = value/3600
        let min = (value - hour * 3600)/60
        let sec = value - hour * 3600 - min * 60
        
        let str = "\(hour)h \(min)m \(sec)s"
        
        return str
    }
}

func monthColor(_ month: Int) -> UIColor {
    let monthColor = [UIColor.blue, UIColor.green, UIColor.brown, UIColor.magenta, UIColor.yellow, UIColor.red, UIColor.black, UIColor.darkGray, UIColor.lightGray, UIColor.cyan, UIColor.orange, UIColor.purple]

    return month > 0 && month <= 12 ? monthColor[month - 1] : UIColor.gray
}

func monthColor(_ date: Date) -> UIColor {

    let calendar = Calendar.current
    let month = calendar.component(.month, from: date)
    
    return monthColor(month)
}
