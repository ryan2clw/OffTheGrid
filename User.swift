//
//  User.swift
//  NetDM
//
//  Created by Ryan Dines on 5/21/16.
//  Copyright © 2016 Dimezee. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class User: NSManagedObject {
    
    var profileImage:UIImage {
        
        get{
            print("Converting binary data to photo")
            // get the image by converting it from binary form of the persistent store
            return UIImage(data: self.imageData!)!
        }
        set{
            // set the image by storing its data as an attribute for a Core Data Entity
            print("Storing image as binary data")
            self.imageData! = UIImagePNGRepresentation(newValue)!
        }
    }

}
