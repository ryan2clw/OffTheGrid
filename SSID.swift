//
//  SSID.swift
//  NetDM
//
//  Created by Ryan Dines on 5/7/16.
//  Copyright © 2016 Dimezee. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

public class SSID {
    class func fetchSSIDInfo() ->  String {
        var currentSSID = ""
        if let interfaces:CFArray! = CNCopySupportedInterfaces() {
            for i in 0..<CFArrayGetCount(interfaces){
                let interfaceName: UnsafePointer<Void> = CFArrayGetValueAtIndex(interfaces, i)
                let rec = unsafeBitCast(interfaceName, AnyObject.self)
                let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)")
                if unsafeInterfaceData != nil {
                    let interfaceData = unsafeInterfaceData! as Dictionary!
                    currentSSID = interfaceData["SSID"] as! String
                }
            }
        }
        return currentSSID
    }
}